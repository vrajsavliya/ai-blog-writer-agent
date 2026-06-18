import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/topic_model.dart';
import '../models/article_model.dart';
import '../services/tavily_service.dart';
import '../services/groq_service.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum PipelineStep {
  idle,
  fetchingTopics,
  evaluatingTopics,
  awaitingTopicSelection, // NEW — paused, waiting for user to pick a topic
  generatingSeo,
  generatingContent,
  generatingMetadata,
  generatingImages,
  saving,
  done,
  error,
}

class BlogProvider extends ChangeNotifier {
  final TavilyService _tavilyService = TavilyService();
  final GroqService _groqService = GroqService();
  final FirestoreService _firestoreService = FirestoreService();

  // ── State ────────────────────────────────────────────────────────────────────
  PipelineStep _currentStep = PipelineStep.idle;
  String _errorMessage = '';
  List<Topic> _topics = [];
  Topic? _selectedTopic;
  Article? _article;
  String? _savedArticleId;

  // ── Getters ──────────────────────────────────────────────────────────────────
  PipelineStep get currentStep => _currentStep;
  String get errorMessage => _errorMessage;
  List<Topic> get topics => _topics;
  Topic? get selectedTopic => _selectedTopic;
  Article? get article => _article;
  String? get savedArticleId => _savedArticleId;

  double get progress {
    switch (_currentStep) {
      case PipelineStep.idle:
        return 0.0;
      case PipelineStep.fetchingTopics:
        return 1 / 7;
      case PipelineStep.evaluatingTopics:
        return 2 / 7;
      case PipelineStep.awaitingTopicSelection:
        return 2 / 7;
      case PipelineStep.generatingSeo:
        return 3 / 7;
      case PipelineStep.generatingContent:
        return 4 / 7;
      case PipelineStep.generatingMetadata:
        return 5 / 7;
      case PipelineStep.generatingImages:
        return 6 / 7;
      case PipelineStep.saving:
        return 6.5 / 7;
      case PipelineStep.done:
        return 1.0;
      case PipelineStep.error:
        return 0.0;
    }
  }

  bool get isRunning =>
      _currentStep != PipelineStep.idle &&
      _currentStep != PipelineStep.done &&
      _currentStep != PipelineStep.error &&
      _currentStep != PipelineStep.awaitingTopicSelection;

  bool get isAwaitingSelection =>
      _currentStep == PipelineStep.awaitingTopicSelection;

  String get stepLabel {
    switch (_currentStep) {
      case PipelineStep.idle:
        return 'Ready to generate';
      case PipelineStep.fetchingTopics:
        return 'Step 1/7 — Fetching trending topics...';
      case PipelineStep.evaluatingTopics:
        return 'Step 2/7 — Evaluating & scoring topics...';
      case PipelineStep.awaitingTopicSelection:
        return 'Topics found! Select a topic to continue.';
      case PipelineStep.generatingSeo:
        return 'Step 3/7 — Researching SEO keywords...';
      case PipelineStep.generatingContent:
        return 'Step 4/7 — Writing full blog article...';
      case PipelineStep.generatingMetadata:
        return 'Step 5/7 — Generating metadata...';
      case PipelineStep.generatingImages:
        return 'Step 6/7 — Creating image prompts...';
      case PipelineStep.saving:
        return 'Step 7/7 — Saving to Firestore...';
      case PipelineStep.done:
        return 'Article generated successfully!';
      case PipelineStep.error:
        return 'Error: $_errorMessage';
    }
  }

  // ── Pipeline ─────────────────────────────────────────────────────────────────

  void reset() {
    _currentStep = PipelineStep.idle;
    _errorMessage = '';
    _topics = [];
    _selectedTopic = null;
    _article = null;
    _savedArticleId = null;
    notifyListeners();
  }

  /// Phase 1: Fetch and evaluate topics then PAUSE for user selection
  Future<void> fetchAndEvaluateTopics() async {
    reset();

    try {
      // ── Step 1: Fetch Trending Topics ─────────────────────────────────────────
      _setStep(PipelineStep.fetchingTopics);
      final rawTopics = await _tavilyService.fetchTrendingTopics();

      // ── Step 2: Evaluate Topics ───────────────────────────────────────────────
      _setStep(PipelineStep.evaluatingTopics);
      _topics = await _groqService.evaluateTopics(rawTopics);

      if (_topics.isEmpty) {
        throw Exception('No topics could be evaluated.');
      }

      // Auto-select the best topic by default (user can override)
      _selectedTopic = _topics.first;

      // Pause here — wait for user to confirm or pick another topic
      _setStep(PipelineStep.awaitingTopicSelection);
    } catch (e) {
      _errorMessage = e.toString();
      _setStep(PipelineStep.error);
    }
  }

  /// Set the user-selected topic (for manual selection)
  void selectTopic(Topic topic) {
    _selectedTopic = topic;
    notifyListeners();
  }

  /// Phase 2: Continue pipeline from the selected topic (Steps 3–7)
  Future<void> continueFromTopic() async {
    if (_selectedTopic == null) return;

    try {
      // ── Step 3: SEO Research ──────────────────────────────────────────────────
      _setStep(PipelineStep.generatingSeo);
      final seoData = await _groqService.generateSeoData(_selectedTopic!);

      // ── Step 4: Generate Blog Content ─────────────────────────────────────────
      _setStep(PipelineStep.generatingContent);
      final blogContent =
          await _groqService.generateBlogContent(_selectedTopic!, seoData);

      // Create partial article for metadata step
      final partialArticle = Article(
        id: const Uuid().v4(),
        topic: _selectedTopic!,
        seo: seoData,
        content: blogContent,
        images: ImagePackage(
          featuredImage: BlogImageInfo(
              prompt: '', altText: '', caption: '', placement: ''),
          supportingImages: [],
        ),
        metadata: ArticleMetadata(
          metaTitle: '',
          metaDescription: '',
          tags: [],
          categories: [],
          openGraphData: {},
        ),
        status: PublishStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      // ── Step 5: Generate Metadata ─────────────────────────────────────────────
      _setStep(PipelineStep.generatingMetadata);
      final metadata = await _groqService.generateMetadata(partialArticle);

      // ── Step 6: Generate Image Package ───────────────────────────────────────
      _setStep(PipelineStep.generatingImages);
      final imagePackage =
          await _groqService.generateImagePackage(_selectedTopic!);

      // ── Step 7: Save to Firestore ─────────────────────────────────────────────
      _setStep(PipelineStep.saving);
      _article = Article(
        id: partialArticle.id,
        topic: _selectedTopic!,
        seo: seoData,
        content: blogContent,
        images: imagePackage,
        metadata: metadata,
        status: PublishStatus.saved,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      _savedArticleId = await _firestoreService.saveArticle(_article!);

      _setStep(PipelineStep.done);
    } catch (e) {
      _errorMessage = e.toString();
      _setStep(PipelineStep.error);
    }
  }

  void _setStep(PipelineStep step) {
    _currentStep = step;
    notifyListeners();
  }

  Stream<List<Article>> get articlesStream => _firestoreService.getArticles();
}
