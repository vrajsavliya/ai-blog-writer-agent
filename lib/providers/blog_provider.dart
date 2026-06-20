import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/topic_model.dart';
import '../models/article_model.dart';
import '../services/tavily_service.dart';
import '../services/groq_service.dart';
import '../services/firestore_service.dart';
import '../services/publishing_service.dart';
import '../services/flux_service.dart';
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
  optimizingContent, // NEW — AI Search Optimization layer
  saving,
  done,
  error,
}

class BlogProvider extends ChangeNotifier {
  final TavilyService _tavilyService = TavilyService();
  final GroqService _groqService = GroqService();
  final FirestoreService _firestoreService = FirestoreService();
  final PublishingService _publishingService = PublishingService();
  final FluxService _fluxService = FluxService();

  // ── State ────────────────────────────────────────────────────────────────────
  PipelineStep _currentStep = PipelineStep.idle;
  String _errorMessage = '';
  List<Topic> _topics = [];
  Topic? _selectedTopic;
  Article? _article;
  String? _savedArticleId;
  bool _isPublishing = false;

  // ── Getters ──────────────────────────────────────────────────────────────────
  PipelineStep get currentStep => _currentStep;
  String get errorMessage => _errorMessage;
  List<Topic> get topics => _topics;
  Topic? get selectedTopic => _selectedTopic;
  Article? get article => _article;
  String? get savedArticleId => _savedArticleId;
  bool get isPublishing => _isPublishing;

  double get progress {
    switch (_currentStep) {
      case PipelineStep.idle:
        return 0.0;
      case PipelineStep.fetchingTopics:
        return 1 / 8;
      case PipelineStep.evaluatingTopics:
        return 2 / 8;
      case PipelineStep.awaitingTopicSelection:
        return 2 / 8;
      case PipelineStep.generatingSeo:
        return 3 / 8;
      case PipelineStep.generatingContent:
        return 4 / 8;
      case PipelineStep.generatingMetadata:
        return 5 / 8;
      case PipelineStep.generatingImages:
        return 6 / 8;
      case PipelineStep.optimizingContent:
        return 7 / 8;
      case PipelineStep.saving:
        return 7.5 / 8;
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
      case PipelineStep.evaluatingTopics:
        return 'Step 1/4 — Collecting trending topics...';
      case PipelineStep.awaitingTopicSelection:
        return 'Step 2/4 — Select a topic to continue.';
      case PipelineStep.generatingSeo:
      case PipelineStep.generatingContent:
      case PipelineStep.generatingMetadata:
      case PipelineStep.generatingImages:
      case PipelineStep.optimizingContent:
      case PipelineStep.saving:
        return 'Step 3/4 — Generating blog...';
      case PipelineStep.done:
        return 'Step 4/4 — Completed!';
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
    _isPublishing = false;
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

      // ── Step 6: Generate Image Package & Actual Images ─────────────────────
      _setStep(PipelineStep.generatingImages);
      final rawImagePackage =
          await _groqService.generateImagePackage(_selectedTopic!);

      final featuredImagePath = await _fluxService.generateAndDownloadImage(
          rawImagePackage.featuredImage.prompt, 'featured');
          
      final featuredImage = rawImagePackage.featuredImage.copyWith(
          localImagePath: featuredImagePath);
          
      final supportingImages = <BlogImageInfo>[];
      for (int i = 0; i < rawImagePackage.supportingImages.length; i++) {
        final img = rawImagePackage.supportingImages[i];
        final path = await _fluxService.generateAndDownloadImage(
            img.prompt, 'supporting_$i');
        supportingImages.add(img.copyWith(localImagePath: path));
      }
      
      final imagePackage = ImagePackage(
          featuredImage: featuredImage, 
          supportingImages: supportingImages);

      // ── Step 7: AI Search Optimization ───────────────────────────────────────
      _setStep(PipelineStep.optimizingContent);
      final aiOptimization = await _groqService.generateAiSearchOptimization(
        articleTitle: blogContent.title.isNotEmpty
            ? blogContent.title
            : _selectedTopic!.title,
        primaryKeyword: seoData.primaryKeyword,
        fullArticleMarkdown: blogContent.fullArticleMarkdown,
      );

      // ── Step 8: Save to Firestore ─────────────────────────────────────────────
      _setStep(PipelineStep.saving);
      _article = Article(
        id: partialArticle.id,
        topic: _selectedTopic!,
        seo: seoData,
        content: blogContent,
        images: imagePackage,
        metadata: metadata,
        aiOptimization: aiOptimization,
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

  Future<bool> publishToWordPress() async {
    if (_article == null) return false;
    _isPublishing = true;
    notifyListeners();
    try {
      await _publishingService.publishToWordPress(_article!);
      _isPublishing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isPublishing = false;
      _errorMessage = e.toString();
      _setStep(PipelineStep.error);
      return false;
    }
  }

  Stream<List<Article>> get articlesStream => _firestoreService.getArticles();
}
