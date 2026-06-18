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
  late Article _article;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _articleScroll.dispose();
    _seoScroll.dispose();
    _imagesScroll.dispose();
    _metaScroll.dispose();
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
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1A3E), Color(0xFF0D0F1A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
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
                  indicatorColor: kAccent,
                  indicatorWeight: 2,
                  tabs: const [
                    Tab(text: 'Article'),
                    Tab(text: 'SEO'),
                    Tab(text: 'Images'),
                    Tab(text: 'Meta'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ArticleTab(article: _article, controller: _articleScroll),
            _SeoTab(article: _article, onCopy: _copyToClipboard, controller: _seoScroll),
            _ImagesTab(article: _article, controller: _imagesScroll),
            _MetaTab(article: _article, onCopy: _copyToClipboard, controller: _metaScroll),
          ],
        ),
      ),
    );
  }
}

// ── Article Tab ───────────────────────────────────────────────────────────────
class _ArticleTab extends StatelessWidget {
  final Article article;
  final ScrollController controller;
  const _ArticleTab({required this.article, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Markdown(
      controller: controller,
      data: article.content.fullArticleMarkdown.isEmpty
          ? '*No article content generated yet.*'
          : article.content.fullArticleMarkdown,
      padding: const EdgeInsets.all(20),
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
  final ScrollController controller;
  const _ImagesTab({required this.article, required this.controller});

  @override
  Widget build(BuildContext context) {
    final pkg = article.images;
    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImageCard(image: pkg.featuredImage, label: 'FEATURED IMAGE'),
          const SizedBox(height: 14),
          ...pkg.supportingImages.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ImageCard(
                    image: e.value,
                    label: 'SUPPORTING IMAGE ${e.key + 1}',
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

  const _ImageCard({required this.image, required this.label});

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
          Text(
            label,
            style: GoogleFonts.inter(
                color: kAccentLight,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          // Prompt box
          Container(
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
