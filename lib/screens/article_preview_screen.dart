import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/article_model.dart';
import '../widgets/reusable_widgets.dart';

class ArticlePreviewScreen extends StatefulWidget {
  final Article article;

  const ArticlePreviewScreen({super.key, required this.article});

  @override
  State<ArticlePreviewScreen> createState() => _ArticlePreviewScreenState();
}

class _ArticlePreviewScreenState extends State<ArticlePreviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _articleScroll = ScrollController();
  final ScrollController _seoScroll = ScrollController();
  final ScrollController _imagesScroll = ScrollController();
  final ScrollController _metaScroll = ScrollController();
  final ScrollController _aiSeoScroll = ScrollController();
  late Article _article;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _articleScroll.dispose();
    _seoScroll.dispose();
    _imagesScroll.dispose();
    _metaScroll.dispose();
    _aiSeoScroll.dispose();
    super.dispose();
  }


  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
        backgroundColor: color.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('$label copied!', kAccent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: kSurface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: kTextPrimary, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.copy_rounded,
                    color: kTextSecondary, size: 20),
                tooltip: 'Copy article markdown',
                onPressed: () => _copyToClipboard(
                    _article.content.fullArticleMarkdown, 'Article'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: kHeaderGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusBadge(status: _article.status),
                        const SizedBox(height: 10),
                        Text(
                          _article.content.title.isEmpty
                              ? _article.topic.title
                              : _article.content.title,
                          style: GoogleFonts.inter(
                            color: kTextPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.text_fields_rounded,
                                color: kTextSecondary, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${_article.content.wordCount} words',
                              style: GoogleFonts.inter(
                                  color: kTextSecondary, fontSize: 11),
                            ),
                            const SizedBox(width: 14),
                            const Icon(Icons.key_rounded,
                                color: kTextSecondary, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              _article.seo.primaryKeyword,
                              style: GoogleFonts.inter(
                                  color: kTextSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: kSurface,
                child: TabBar(
                  controller: _tabController,
                  labelStyle: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600),
                  unselectedLabelStyle:
                      GoogleFonts.inter(fontSize: 12),
                  labelColor: kAccentLight,
                  unselectedLabelColor: kTextSecondary,
                  indicatorWeight: 2,
                  tabs: const [
                    Tab(text: 'Article'),
                    Tab(text: 'SEO'),
                    Tab(text: 'Images'),
                    Tab(text: 'Meta'),
                    Tab(text: 'Optimization'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ArticleTab(article: _article, onCopy: _copyToClipboard, controller: _articleScroll),
            _SeoTab(article: _article, onCopy: _copyToClipboard, controller: _seoScroll),
            _ImagesTab(article: _article, onCopy: _copyToClipboard, controller: _imagesScroll),
            _MetaTab(article: _article, onCopy: _copyToClipboard, controller: _metaScroll),
            _AiSeoTab(article: _article, onCopy: _copyToClipboard, controller: _aiSeoScroll),
          ],
        ),
      ),
    );
  }
}

// ── Article Tab ───────────────────────────────────────────────────────────────
class _ArticleTab extends StatelessWidget {
  final Article article;
  final void Function(String, String) onCopy;
  final ScrollController controller;
  const _ArticleTab({required this.article, required this.onCopy, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MasterCopyButton(
            label: 'Copy Full Article Markdown',
            onTap: () => onCopy(
              article.content.fullArticleMarkdown.isEmpty
                  ? '*No article content generated yet.*'
                  : article.content.fullArticleMarkdown,
              'Full Article Markdown',
            ),
          ),
          const SizedBox(height: 20),
          MarkdownBody(
            data: article.content.fullArticleMarkdown.isEmpty
                ? '*No article content generated yet.*'
                : article.content.fullArticleMarkdown,
            styleSheet: MarkdownStyleSheet(
        h1: GoogleFonts.inter(
            color: kTextPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.3),
        h2: GoogleFonts.inter(
            color: kTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.4),
        h3: GoogleFonts.inter(
            color: kTextPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600),
        p: GoogleFonts.inter(
            color: kTextSecondary, fontSize: 13, height: 1.7),
        listBullet: GoogleFonts.inter(
            color: kTextSecondary, fontSize: 13, height: 1.7),
        strong: GoogleFonts.inter(
            color: kTextPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600),
        blockquoteDecoration: BoxDecoration(
          color: kAccent.withValues(alpha: 0.08),
          border: const Border(left: BorderSide(color: kAccent, width: 3)),
          borderRadius: BorderRadius.circular(4),
        ),
        codeblockDecoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kBorder),
        ),
        code: GoogleFonts.sourceCodePro(
            color: kAccentLight,
            fontSize: 12,
            backgroundColor: kCardBg),
      ),
    ),
  ],
),
);
  }
}

// ── SEO Tab ───────────────────────────────────────────────────────────────────
class _SeoTab extends StatelessWidget {
  final Article article;
  final void Function(String, String) onCopy;
  final ScrollController controller;

  const _SeoTab({required this.article, required this.onCopy, required this.controller});

  @override
  Widget build(BuildContext context) {
    final seo = article.seo;
    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MasterCopyButton(
            label: 'Copy All SEO Data',
            onTap: () => onCopy(
              'SEO TITLE:\n${seo.seoTitle}\n\nMETA DESCRIPTION:\n${seo.metaDescription}\n\nURL SLUG:\n/${seo.urlSlug}\n\nOPEN GRAPH TITLE:\n${seo.ogTitle}\n\nTWITTER TITLE:\n${seo.twitterTitle}',
              'All SEO Data',
            ),
          ),
          const SizedBox(height: 20),
          SeoMetaPanel(seo: seo),
          const SizedBox(height: 16),
          _CopyableCard(
            label: 'SEO TITLE',
            value: seo.seoTitle,
            onCopy: () => onCopy(seo.seoTitle, 'SEO Title'),
          ),
          const SizedBox(height: 12),
          _CopyableCard(
            label: 'META DESCRIPTION',
            value: seo.metaDescription,
            onCopy: () => onCopy(seo.metaDescription, 'Meta Description'),
          ),
          const SizedBox(height: 12),
          _CopyableCard(
            label: 'URL SLUG',
            value: '/${seo.urlSlug}',
            onCopy: () => onCopy(seo.urlSlug, 'URL Slug'),
          ),
          const SizedBox(height: 12),
          _CopyableCard(
            label: 'OPEN GRAPH TITLE',
            value: seo.ogTitle,
            onCopy: () => onCopy(seo.ogTitle, 'OG Title'),
          ),
          const SizedBox(height: 12),
          _CopyableCard(
            label: 'TWITTER TITLE',
            value: seo.twitterTitle,
            onCopy: () => onCopy(seo.twitterTitle, 'Twitter Title'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Images Tab ────────────────────────────────────────────────────────────────
class _ImagesTab extends StatelessWidget {
  final Article article;
  final void Function(String, String) onCopy;
  final ScrollController controller;
  const _ImagesTab({required this.article, required this.onCopy, required this.controller});

  @override
  Widget build(BuildContext context) {
    final pkg = article.images;
    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MasterCopyButton(
            label: 'Copy All Image Prompts',
            onTap: () {
              final prompts = [pkg.featuredImage, ...pkg.supportingImages]
                  .map((img) => img.prompt)
                  .where((p) => p.isNotEmpty)
                  .join('\n\n---\n\n');
              onCopy(prompts.isEmpty ? 'No prompts available' : prompts, 'All Image Prompts');
            },
          ),
          const SizedBox(height: 20),
          _ImageCard(image: pkg.featuredImage, label: 'FEATURED IMAGE', onCopy: onCopy),
          const SizedBox(height: 14),
          ...pkg.supportingImages.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ImageCard(
                    image: e.value,
                    label: 'SUPPORTING IMAGE ${e.key + 1}',
                    onCopy: onCopy,
                  ),
                ),
              ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final BlogImageInfo image;
  final String label;
  final void Function(String, String) onCopy;

  const _ImageCard({required this.image, required this.label, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                    color: kAccentLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2),
              ),
              GestureDetector(
                onTap: () => onCopy(image.prompt, '$label Prompt'),
                child: const Icon(Icons.copy_rounded, color: kTextSecondary, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Prompt box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder),
            ),
            child: Text(
              image.prompt.isEmpty ? 'No prompt generated' : image.prompt,
              style: GoogleFonts.inter(
                  color: kTextPrimary, fontSize: 12, height: 1.6),
            ),
          ),
          const SizedBox(height: 12),
          _ImageMeta('Alt Text', image.altText),
          const SizedBox(height: 6),
          _ImageMeta('Caption', image.caption),
          const SizedBox(height: 6),
          _ImageMeta('Placement', image.placement),
        ],
      ),
    );
  }
}

class _ImageMeta extends StatelessWidget {
  final String label;
  final String value;
  const _ImageMeta(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: GoogleFonts.inter(
                  color: kTextSecondary, fontSize: 11)),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: GoogleFonts.inter(
                color: kTextPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// ── Meta Tab ──────────────────────────────────────────────────────────────────
class _MetaTab extends StatelessWidget {
  final Article article;
  final void Function(String, String) onCopy;
  final ScrollController controller;

  const _MetaTab({required this.article, required this.onCopy, required this.controller});

  @override
  Widget build(BuildContext context) {
    final meta = article.metadata;
    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MasterCopyButton(
            label: 'Copy All Meta Data',
            onTap: () => onCopy(
              'META TITLE:\n${meta.metaTitle}\n\nMETA DESCRIPTION:\n${meta.metaDescription}\n\nCATEGORIES:\n${meta.categories.join(', ')}\n\nTAGS:\n${meta.tags.join(', ')}',
              'All Meta Data',
            ),
          ),
          const SizedBox(height: 20),
          _CopyableCard(
            label: 'META TITLE',
            value: meta.metaTitle,
            onCopy: () => onCopy(meta.metaTitle, 'Meta Title'),
          ),
          const SizedBox(height: 12),
          _CopyableCard(
            label: 'META DESCRIPTION',
            value: meta.metaDescription,
            onCopy: () => onCopy(meta.metaDescription, 'Meta Description'),
          ),
          const SizedBox(height: 16),
          _TagsSection('CATEGORIES', meta.categories, kAccent),
          const SizedBox(height: 16),
          _TagsSection('TAGS', meta.tags, kOrange),
          const SizedBox(height: 16),
          if (meta.openGraphData.isNotEmpty) ...[
            const _SectionTitle('OPEN GRAPH DATA'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                children: meta.openGraphData.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(e.key,
                              style: GoogleFonts.inter(
                                  color: kTextSecondary,
                                  fontSize: 11)),
                        ),
                        Expanded(
                          child: Text(e.value,
                              style: GoogleFonts.inter(
                                  color: kTextPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _TagsSection extends StatelessWidget {
  final String label;
  final List<String> items;
  final Color color;

  const _TagsSection(this.label, this.items, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(label),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((item) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(item,
                        style: GoogleFonts.inter(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
          color: kTextSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2),
    );
  }
}

class _CopyableCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _CopyableCard(
      {required this.label, required this.value, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      color: kAccentLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2)),
              GestureDetector(
                onTap: onCopy,
                child: const Icon(Icons.copy_rounded,
                    color: kTextSecondary, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? '—' : value,
            style: GoogleFonts.inter(
                color: kTextPrimary, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── AI SEO Tab ───────────────────────────────────────────────────────────────────────────────

class _AiSeoTab extends StatelessWidget {
  final Article article;
  final void Function(String, String) onCopy;
  final ScrollController controller;

  const _AiSeoTab(
      {required this.article,
      required this.onCopy,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    final ai = article.aiOptimization;

    if (ai == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: kCardBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(Icons.insights_rounded,
                    color: kTextSecondary, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                'No Optimization Data',
                style: GoogleFonts.inter(
                    color: kTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'This article was generated before Search Optimization was added. Regenerate an article to see optimization data.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: kTextSecondary, fontSize: 12, height: 1.6),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MasterCopyButton(
            label: 'Copy All Optimization Data',
            onTap: () {
              final content = 'OPTIMIZED META TITLE:\n${ai.optimizedSeoTitle}\n\n'
                  'OPTIMIZED META DESCRIPTION:\n${ai.optimizedMetaDescription}\n\n'
                  'FEATURED SNIPPET:\n${ai.featuredSnippetAnswer}\n\n'
                  'DIRECT ANSWER:\n${ai.directAnswerSection}\n\n'
                  'FAQ:\n${ai.faqSection.join('\n\n')}\n\n'
                  'SOURCES:\n${ai.sourcesAndReferences.join('\n')}\n\n'
                  'KEY TAKEAWAYS:\n${ai.keyTakeaways.join('\n')}\n\n'
                  'STRUCTURE:\n${ai.llmFriendlyStructure.entries.map((e) => '${e.key}: ${e.value}').join('\n')}';
              onCopy(content, 'Optimization Data');
            },
          ),
          const SizedBox(height: 20),

          // ── Quality Dashboard ────────────────────────────────────────────────
          if (ai.qualityScores.isNotEmpty || ai.qualityChecklist.isNotEmpty) ...[
            _QualityDashboard(
              scores: ai.qualityScores,
              checklist: ai.qualityChecklist,
            ),
            const SizedBox(height: 32),
          ],

          // ── AISEO Meta Overrides ─────────────────────────────────────────────
          const _AiSeoSectionHeader(
            icon: Icons.search_rounded,
            label: 'OPTIMIZED META',
            color: kAccent,
          ),
          const SizedBox(height: 10),
          _CopyableCard(
            label: 'SEO TITLE',
            value: ai.optimizedSeoTitle,
            onCopy: () => onCopy(ai.optimizedSeoTitle, 'SEO Title'),
          ),
          const SizedBox(height: 10),
          _CopyableCard(
            label: 'META DESCRIPTION',
            value: ai.optimizedMetaDescription,
            onCopy: () =>
                onCopy(ai.optimizedMetaDescription, 'Meta Description'),
          ),
          const SizedBox(height: 10),
          _CopyableCard(
            label: 'URL SLUG',
            value: '/${ai.optimizedUrlSlug}',
            onCopy: () => onCopy(ai.optimizedUrlSlug, 'URL Slug'),
          ),
          const SizedBox(height: 24),

          // ── AEO: Answer Engine Optimization ───────────────────────────────────
          const _AiSeoSectionHeader(
            icon: Icons.quickreply_rounded,
            label: 'ANSWER ENGINE OPTIMIZATION',
            color: kOrange,
          ),
          const SizedBox(height: 10),
          _CopyableCard(
            label: 'FEATURED SNIPPET ANSWER',
            value: ai.featuredSnippetAnswer,
            onCopy: () =>
                onCopy(ai.featuredSnippetAnswer, 'Featured Snippet Answer'),
          ),
          const SizedBox(height: 10),
          _CopyableCard(
            label: 'DIRECT ANSWER SECTION',
            value: ai.directAnswerSection,
            onCopy: () =>
                onCopy(ai.directAnswerSection, 'Direct Answer Section'),
          ),
          const SizedBox(height: 24),

          // ── Summary & Key Takeaways ──────────────────────────────────────────
          const _AiSeoSectionHeader(
            icon: Icons.summarize_rounded,
            label: 'ARTICLE SUMMARY & KEY TAKEAWAYS',
            color: Color(0xFF00C896),
          ),
          const SizedBox(height: 10),
          _CopyableCard(
            label: 'ARTICLE SUMMARY',
            value: ai.articleSummary,
            onCopy: () => onCopy(ai.articleSummary, 'Article Summary'),
          ),
          const SizedBox(height: 10),
          _AiSeoListCard(
            label: 'KEY TAKEAWAYS',
            items: ai.keyTakeaways,
            bulletIcon: Icons.check_circle_outline_rounded,
            bulletColor: const Color(0xFF00C896),
            onCopy: () => onCopy(ai.keyTakeaways.join('\n'), 'Key Takeaways'),
          ),
          const SizedBox(height: 24),

          // ── FAQ ────────────────────────────────────────────────────────
          const _AiSeoSectionHeader(
            icon: Icons.help_outline_rounded,
            label: 'FAQ SECTION',
            color: Color(0xFF00A0E9),
          ),
          const SizedBox(height: 10),
          _AiSeoFaqCard(
            faqItems: ai.faqSection,
            onCopy: () => onCopy(ai.faqSection.join('\n\n'), 'FAQ Section'),
          ),
          const SizedBox(height: 24),

          // ── Sources & References ────────────────────────────────────────
          const _AiSeoSectionHeader(
            icon: Icons.library_books_rounded,
            label: 'SOURCES & REFERENCES',
            color: Color(0xFFE05CFF),
          ),
          const SizedBox(height: 10),
          _AiSeoListCard(
            label: 'CITATION-WORTHY REFERENCES',
            items: ai.sourcesAndReferences,
            bulletIcon: Icons.link_rounded,
            bulletColor: const Color(0xFFE05CFF),
            onCopy: () => onCopy(
                ai.sourcesAndReferences.join('\n'), 'Sources & References'),
          ),
          const SizedBox(height: 24),

          // ── E-E-A-T Signals ──────────────────────────────────────────────────
          const _AiSeoSectionHeader(
            icon: Icons.verified_rounded,
            label: 'E-E-A-T SIGNALS',
            color: Color(0xFFFF6B6B),
          ),
          const SizedBox(height: 10),
          _AiSeoKeyValueCard(
            data: ai.eatSignals,
            onCopy: () => onCopy(
              ai.eatSignals.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join('\n\n'),
              'E-E-A-T Signals',
            ),
          ),
          const SizedBox(height: 24),

          // ── Schema Markup ────────────────────────────────────────────────────
          const _AiSeoSectionHeader(
            icon: Icons.code_rounded,
            label: 'SCHEMA MARKUP (JSON-LD)',
            color: Color(0xFF6C63FF),
          ),
          const SizedBox(height: 10),
          _AiSeoSchemaCard(
            schema: ai.schemaMarkup,
            onCopy: () => onCopy(
              const JsonEncoder.withIndent('  ').convert(ai.schemaMarkup),
              'Schema Markup',
            ),
          ),
          const SizedBox(height: 24),

          // ── SEMANTIC STRUCTURE ──────────────────────────────────────────────
          const _AiSeoSectionHeader(
            icon: Icons.hub_rounded,
            label: 'SEMANTIC STRUCTURE',
            color: kRed,
          ),
          const SizedBox(height: 10),
          _AiSeoKeyValueCard(
            data: ai.llmFriendlyStructure,
            onCopy: () => onCopy(
              ai.llmFriendlyStructure.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join('\n\n'),
              'LLM-Friendly Structure',
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── AI SEO Section Header ───────────────────────────────────────────────────────
class _AiSeoSectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _AiSeoSectionHeader(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Icon(icon, color: kTextPrimary, size: 14),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.inter(
              color: kTextPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2),
        ),
      ],
    );
  }
}

// ── AI SEO List Card ────────────────────────────────────────────────────────────
class _AiSeoListCard extends StatelessWidget {
  final String label;
  final List<String> items;
  final IconData bulletIcon;
  final Color bulletColor;
  final VoidCallback onCopy;

  const _AiSeoListCard({
    required this.label,
    required this.items,
    required this.bulletIcon,
    required this.bulletColor,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      color: kAccentLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2)),
              GestureDetector(
                onTap: onCopy,
                child: const Icon(Icons.copy_rounded,
                    color: kTextSecondary, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(bulletIcon, color: bulletColor, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                          color: kTextPrimary, fontSize: 12, height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── AI SEO FAQ Card ─────────────────────────────────────────────────────────────
class _AiSeoFaqCard extends StatelessWidget {
  final List<String> faqItems;
  final VoidCallback onCopy;

  const _AiSeoFaqCard({required this.faqItems, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FAQ ITEMS',
                  style: GoogleFonts.inter(
                      color: kAccentLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2)),
              GestureDetector(
                onTap: onCopy,
                child: const Icon(Icons.copy_rounded,
                    color: kTextSecondary, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...faqItems.asMap().entries.map((entry) {
            final parts = entry.value.split('\nA:');
            final question =
                parts.isNotEmpty ? parts[0].replaceFirst('Q:', '').trim() : entry.value;
            final answer = parts.length > 1 ? parts[1].trim() : '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A0E9).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF00A0E9).withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      'Q: $question',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF00A0E9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.4),
                    ),
                  ),
                  if (answer.isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(10, 6, 0, 0),
                      child: Text(
                        answer,
                        style: GoogleFonts.inter(
                            color: kTextSecondary,
                            fontSize: 12,
                            height: 1.6),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── AI SEO Key-Value Card ───────────────────────────────────────────────────────
class _AiSeoKeyValueCard extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onCopy;

  const _AiSeoKeyValueCard({required this.data, required this.onCopy});

  String _formatKey(String raw) {
    // camelCase → Title Case with spaces
    return raw
        .replaceAllMapped(
            RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .trim()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onCopy,
              child: const Icon(Icons.copy_rounded,
                  color: kTextSecondary, size: 14),
            ),
          ),
          ...data.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatKey(e.key),
                    style: GoogleFonts.inter(
                        color: kAccentLight,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.value.isEmpty ? '—' : e.value,
                    style: GoogleFonts.inter(
                        color: kTextPrimary, fontSize: 12, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── AI SEO Schema Card ──────────────────────────────────────────────────────────
class _AiSeoSchemaCard extends StatelessWidget {
  final Map<String, dynamic> schema;
  final VoidCallback onCopy;

  const _AiSeoSchemaCard({required this.schema, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final prettyJson =
        const JsonEncoder.withIndent('  ').convert(schema);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('JSON-LD SCHEMA',
                  style: GoogleFonts.inter(
                      color: kAccentLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2)),
              GestureDetector(
                onTap: onCopy,
                child: const Icon(Icons.copy_rounded,
                    color: kTextSecondary, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBorder),
            ),
            child: Text(
              prettyJson,
              style: GoogleFonts.sourceCodePro(
                  color: kAccentLight, fontSize: 11, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quality Dashboard ──────────────────────────────────────────────────────────
class _QualityDashboard extends StatelessWidget {
  final Map<String, num> scores;
  final Map<String, bool> checklist;

  const _QualityDashboard({required this.scores, required this.checklist});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                'CONTENT QUALITY SCORES',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (scores.isNotEmpty)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: scores.entries.map((e) => _ScoreGauge(label: e.key, score: e.value)).toList(),
            ),
          if (scores.isNotEmpty && checklist.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: kBorder, height: 1),
            ),
          if (checklist.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VALIDATION CHECKLIST',
                  style: GoogleFonts.inter(
                      color: kAccentLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  children: checklist.entries.map((e) => _ChecklistItem(label: e.key, isPassed: e.value)).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ScoreGauge extends StatelessWidget {
  final String label;
  final num score;

  const _ScoreGauge({required this.label, required this.score});

  Color _getColor(num s) {
    if (s >= 8) return kGreen;
    if (s >= 6) return kOrange;
    return kRed;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(score);
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            score.toStringAsFixed(1),
            style: GoogleFonts.inter(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              color: kTextSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String label;
  final bool isPassed;

  const _ChecklistItem({required this.label, required this.isPassed});

  String _formatLabel(String raw) {
    // hasInlineCitations -> Inline Citations
    String s = raw.replaceFirst('has', '');
    return s.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}').trim();
  }

  @override
  Widget build(BuildContext context) {
    final color = isPassed ? kGreen : kRed;
    final icon = isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(
          _formatLabel(label),
          style: GoogleFonts.inter(
            color: isPassed ? kTextPrimary : kTextSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ── Master Copy Button ────────────────────────────────────────────────────────
class _MasterCopyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MasterCopyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: kAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kAccent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.copy_rounded, color: kAccent, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: kAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
