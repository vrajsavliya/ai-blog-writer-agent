import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/blog_provider.dart';
import '../models/topic_model.dart';
import '../widgets/reusable_widgets.dart';
import 'article_preview_screen.dart';

class BlogWriterScreen extends StatefulWidget {
  const BlogWriterScreen({super.key});

  @override
  State<BlogWriterScreen> createState() => _BlogWriterScreenState();
}

class _BlogWriterScreenState extends State<BlogWriterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlogProvider>().reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: kTextPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Blog Writer Agent',
          style: GoogleFonts.inter(
              color: kTextPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Consumer<BlogProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header card ───────────────────────────────────────────────
                _HeaderCard(provider: provider),
                const SizedBox(height: 24),

                // ── Progress bar ──────────────────────────────────────────────
                if (provider.isRunning ||
                    provider.isAwaitingSelection ||
                    provider.currentStep == PipelineStep.done)
                  _ProgressSection(provider: provider),

                // ── Pipeline steps ────────────────────────────────────────────
                Text(
                  'PIPELINE STEPS',
                  style: GoogleFonts.inter(
                      color: kTextSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2),
                ),
                const SizedBox(height: 12),
                ..._buildStepIndicators(provider),
                const SizedBox(height: 24),

                // ── Topic Selection (shown after topics are fetched) ───────────
                if (provider.isAwaitingSelection)
                  _TopicSelectionPanel(provider: provider),

                // ── Action buttons ────────────────────────────────────────────
                _ActionButtons(provider: provider),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildStepIndicators(BlogProvider provider) {
    final currentIndex = pipelineStepIndex(provider.currentStep);
    final isDone = provider.currentStep == PipelineStep.done;
    final isError = provider.currentStep == PipelineStep.error;

    final steps = [
      ('Fetch Trending Topics', 'Tavily Search API → web trends'),
      ('Evaluate & Score Topics', 'Groq AI → opportunity scoring'),
      ('SEO Research', 'Groq AI → keywords & meta tags'),
      ('Generate Blog Content', 'Groq AI → full article + FAQ'),
      ('Generate Metadata', 'Groq AI → tags, categories, OG'),
      ('Create Image Prompts', 'Groq AI → featured & supporting'),
      ('Save to Firestore', 'Cloud Firestore → persist article'),
    ];

    return steps.asMap().entries.map((entry) {
      final i = entry.key;
      final (title, subtitle) = entry.value;
      final isActive = currentIndex == i && !isDone;
      final isStepDone = isDone || currentIndex > i;
      final isStepError = isError && currentIndex == i;

      return StepIndicator(
        stepNumber: i + 1,
        title: title,
        subtitle: subtitle,
        isActive: isActive,
        isDone: isStepDone,
        isError: isStepError,
      );
    }).toList();
  }
}

// ── Header Card ───────────────────────────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
  final BlogProvider provider;
  const _HeaderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kAccent.withValues(alpha: 0.15),
            kCardBg,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: kAccentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.psychology_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('7-Step AI Pipeline',
                        style: GoogleFonts.inter(
                            color: kTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    Text(
                      'Trend Discovery → SEO → Content → Save',
                      style: GoogleFonts.inter(
                          color: kTextSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            provider.stepLabel,
            style: GoogleFonts.inter(
              color: provider.currentStep == PipelineStep.error
                  ? kRed
                  : provider.currentStep == PipelineStep.done
                      ? kGreen
                      : provider.isAwaitingSelection
                          ? kOrange
                          : kTextSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress Section ──────────────────────────────────────────────────────────
class _ProgressSection extends StatelessWidget {
  final BlogProvider provider;
  const _ProgressSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress',
                  style: GoogleFonts.inter(
                      color: kTextSecondary, fontSize: 12)),
              Text('${(provider.progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                      color: kAccentLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: provider.progress,
              backgroundColor: kBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(kAccent),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Topic Selection Panel (Auto & Manual) ─────────────────────────────────────
class _TopicSelectionPanel extends StatefulWidget {
  final BlogProvider provider;
  const _TopicSelectionPanel({required this.provider});

  @override
  State<_TopicSelectionPanel> createState() => _TopicSelectionPanelState();
}

class _TopicSelectionPanelState extends State<_TopicSelectionPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section label ───────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.topic_rounded, color: kOrange, size: 16),
              const SizedBox(width: 8),
              Text(
                'SELECT TOPIC',
                style: GoogleFonts.inter(
                    color: kOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Tab switcher (Auto / Manual) ────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              children: [
                // Tab bar
                Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    controller: _tabs,
                    labelStyle: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
                    labelColor: Colors.white,
                    unselectedLabelColor: kTextSecondary,
                    indicator: BoxDecoration(
                      gradient: kAccentGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 14),
                            SizedBox(width: 6),
                            Text('Auto Select'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app_rounded, size: 14),
                            SizedBox(width: 6),
                            Text('Manual Select'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab content
                SizedBox(
                  height: 280,
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      // ── AUTO SELECT TAB ─────────────────────────────────────
                      _AutoSelectTab(provider: provider),

                      // ── MANUAL SELECT TAB ───────────────────────────────────
                      _ManualSelectTab(provider: provider),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Auto Select Tab ───────────────────────────────────────────────────────────
class _AutoSelectTab extends StatelessWidget {
  final BlogProvider provider;
  const _AutoSelectTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final topic = provider.topics.isNotEmpty ? provider.topics.first : null;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI picked the highest-scoring topic for you:',
            style: GoogleFonts.inter(color: kTextSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (topic != null)
            _TopicCard(
              topic: topic,
              isSelected: true,
              showBadge: true,
              badgeLabel: '🏆 Top Pick',
              onTap: null,
            ),
          const Spacer(),
          Text(
            'Switch to "Manual Select" to choose a different topic.',
            style: GoogleFonts.inter(color: kTextSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Manual Select Tab ─────────────────────────────────────────────────────────
class _ManualSelectTab extends StatelessWidget {
  final BlogProvider provider;
  const _ManualSelectTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: provider.topics.length,
      itemBuilder: (context, i) {
        final topic = provider.topics[i];
        final isSelected = provider.selectedTopic?.title == topic.title;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _TopicCard(
            topic: topic,
            isSelected: isSelected,
            showBadge: false,
            badgeLabel: '',
            onTap: () => provider.selectTopic(topic),
          ),
        );
      },
    );
  }
}

// ── Topic Card ────────────────────────────────────────────────────────────────
class _TopicCard extends StatelessWidget {
  final Topic topic;
  final bool isSelected;
  final bool showBadge;
  final String badgeLabel;
  final VoidCallback? onTap;

  const _TopicCard({
    required this.topic,
    required this.isSelected,
    required this.showBadge,
    required this.badgeLabel,
    required this.onTap,
  });

  Color _scoreColor(double score) {
    if (score >= 0.7) return kGreen;
    if (score >= 0.45) return kOrange;
    return kRed;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? kAccent.withValues(alpha: 0.08)
              : kBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kAccent : kBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected ? kAccentGradient : null,
                border: Border.all(
                  color: isSelected ? Colors.transparent : kBorder,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 11)
                  : null,
            ),

            // Topic info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          topic.title,
                          style: GoogleFonts.inter(
                            color: kTextPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (showBadge)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: kOrange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeLabel,
                            style: GoogleFonts.inter(
                                color: kOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                  if (topic.keywords.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        topic.keywords.take(3).join(' · '),
                        style: GoogleFonts.inter(
                            color: kTextSecondary, fontSize: 11),
                      ),
                    ),
                ],
              ),
            ),

            // Score badge
            Container(
              margin: const EdgeInsets.only(left: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _scoreColor(topic.score).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (topic.score * 100).toStringAsFixed(0),
                style: GoogleFonts.inter(
                  color: _scoreColor(topic.score),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action Buttons ────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final BlogProvider provider;
  const _ActionButtons({required this.provider});

  @override
  Widget build(BuildContext context) {
    // ── Done state ────────────────────────────────────────────────────────────
    if (provider.currentStep == PipelineStep.done && provider.article != null) {
      return Column(
        children: [
          GradientButton(
            label: 'View Generated Article',
            icon: Icons.article_rounded,
            width: double.infinity,
            gradient: const LinearGradient(
                colors: [Color(0xFF00C896), Color(0xFF00A0E9)]),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    ArticlePreviewScreen(article: provider.article!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GradientButton(
            label: 'Generate Another',
            icon: Icons.refresh_rounded,
            width: double.infinity,
            gradient: const LinearGradient(
                colors: [Color(0xFF3A3A6A), Color(0xFF2A2A4A)]),
            onPressed: () => provider.fetchAndEvaluateTopics(),
          ),
        ],
      );
    }

    // ── Error state ───────────────────────────────────────────────────────────
    if (provider.currentStep == PipelineStep.error) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kRed.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: kRed, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    provider.errorMessage,
                    style: GoogleFonts.inter(color: kRed, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GradientButton(
            label: 'Retry',
            icon: Icons.refresh_rounded,
            width: double.infinity,
            onPressed: () => provider.fetchAndEvaluateTopics(),
          ),
        ],
      );
    }

    // ── Awaiting topic selection ───────────────────────────────────────────────
    if (provider.isAwaitingSelection) {
      return GradientButton(
        label: 'Generate Article for Selected Topic',
        icon: Icons.rocket_launch_rounded,
        width: double.infinity,
        gradient: const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)]),
        onPressed: () => provider.continueFromTopic(),
      );
    }

    // ── Idle / Running state ──────────────────────────────────────────────────
    return GradientButton(
      label: provider.isRunning ? 'Running Pipeline...' : 'Discover Topics',
      icon: provider.isRunning ? null : Icons.search_rounded,
      width: double.infinity,
      isLoading: provider.isRunning,
      onPressed: provider.isRunning
          ? null
          : () => provider.fetchAndEvaluateTopics(),
    );
  }
}
