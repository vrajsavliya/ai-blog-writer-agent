import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/article_model.dart';
import '../providers/blog_provider.dart';

// ── Color Palette ─────────────────────────────────────────────────────────────
const Color kBg = Color(0xFF0D0F1A);
const Color kSurface = Color(0xFF161929);
const Color kCardBg = Color(0xFF1E2235);
const Color kBorder = Color(0xFF2A2F4A);
const Color kAccent = Color(0xFF6C63FF);
const Color kAccentLight = Color(0xFF9B95FF);
const Color kGreen = Color(0xFF00E5A0);
const Color kOrange = Color(0xFFFF8C42);
const Color kRed = Color(0xFFFF4D6D);
const Color kTextPrimary = Color(0xFFF0F2FF);
const Color kTextSecondary = Color(0xFF8892B0);

// ── Gradient Presets ──────────────────────────────────────────────────────────
const LinearGradient kAccentGradient = LinearGradient(
  colors: [Color(0xFF6C63FF), Color(0xFF48A9FE)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const LinearGradient kHeaderGradient = LinearGradient(
  colors: [Color(0xFF1A1A3E), Color(0xFF0D0F1A)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// ── Gradient Button ───────────────────────────────────────────────────────────
class GradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final LinearGradient? gradient;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.gradient,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: widget.width,
          height: 52,
          decoration: BoxDecoration(
            gradient: widget.onPressed == null
                ? const LinearGradient(
                    colors: [Color(0xFF3A3A5C), Color(0xFF3A3A5C)])
                : (widget.gradient ?? kAccentGradient),
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: kAccent.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final PublishStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case PublishStatus.published:
        color = kGreen;
        label = 'Published';
        icon = Icons.check_circle_rounded;
        break;
      case PublishStatus.saved:
        color = kAccentLight;
        label = 'Saved';
        icon = Icons.cloud_done_rounded;
        break;
      case PublishStatus.failed:
        color = kRed;
        label = 'Failed';
        icon = Icons.error_rounded;
        break;
      case PublishStatus.draft:
        color = kOrange;
        label = 'Draft';
        icon = Icons.edit_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
                color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Article Card ──────────────────────────────────────────────────────────────
class ArticleCard extends StatefulWidget {
  final Article article;
  final VoidCallback? onTap;

  const ArticleCard({super.key, required this.article, this.onTap});

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _hovered ? kCardBg.withValues(alpha: 0.9) : kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered ? kAccent.withValues(alpha: 0.5) : kBorder,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: kAccent.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + badge row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.article.content.title.isEmpty
                          ? widget.article.topic.title
                          : widget.article.content.title,
                      style: GoogleFonts.inter(
                        color: kTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusBadge(status: widget.article.status),
                ],
              ),
              const SizedBox(height: 8),
              // Meta description
              if (widget.article.seo.metaDescription.isNotEmpty)
                Text(
                  widget.article.seo.metaDescription,
                  style: GoogleFonts.inter(
                      color: kTextSecondary, fontSize: 12, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              // Keywords chips + date
              Row(
                children: [
                  if (widget.article.seo.primaryKeyword.isNotEmpty)
                    _KeywordChip(widget.article.seo.primaryKeyword),
                  const Spacer(),
                  const Icon(Icons.access_time_rounded,
                      color: kTextSecondary, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(widget.article.createdAt),
                    style: GoogleFonts.inter(
                        color: kTextSecondary, fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: kAccentLight, size: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }
}

class _KeywordChip extends StatelessWidget {
  final String label;
  const _KeywordChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kAccent.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
            color: kAccentLight, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────
class StepIndicator extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final bool isActive;
  final bool isDone;
  final bool isError;

  const StepIndicator({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.isDone,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    Color circleColor;
    Widget circleChild;

    if (isError) {
      circleColor = kRed;
      circleChild = const Icon(Icons.close_rounded, color: Colors.white, size: 14);
    } else if (isDone) {
      circleColor = kGreen;
      circleChild = const Icon(Icons.check_rounded, color: Colors.white, size: 14);
    } else if (isActive) {
      circleColor = kAccent;
      circleChild = const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );
    } else {
      circleColor = kBorder;
      circleChild = Text(
        '$stepNumber',
        style: GoogleFonts.inter(
            color: kTextSecondary, fontSize: 11, fontWeight: FontWeight.w600),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isActive
            ? kAccent.withValues(alpha: 0.08)
            : isDone
                ? kGreen.withValues(alpha: 0.05)
                : kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? kAccent.withValues(alpha: 0.4)
              : isDone
                  ? kGreen.withValues(alpha: 0.3)
                  : kBorder,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Center(child: circleChild),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: isActive || isDone ? kTextPrimary : kTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                      color: kTextSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── SEO Meta Panel ─────────────────────────────────────────────────────────────
class SeoMetaPanel extends StatelessWidget {
  final dynamic seo; // SeoData

  const SeoMetaPanel({super.key, required this.seo});

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
          const _SectionLabel('SEO Overview'),
          const SizedBox(height: 12),
          _MetaRow('Primary Keyword', seo.primaryKeyword),
          const SizedBox(height: 8),
          _MetaRow('URL Slug', '/${seo.urlSlug}'),
          const SizedBox(height: 8),
          _MetaRow('Search Intent', seo.searchIntent),
          const SizedBox(height: 12),
          const _SectionLabel('Keywords'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...seo.secondaryKeywords.map<Widget>((k) => _KeywordChip(k)),
            ],
          ),
          const SizedBox(height: 12),
          const _SectionLabel('Long-Tail Keywords'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...seo.longTailKeywords
                  .take(6)
                  .map<Widget>((k) => _LongTailChip(k)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
          color: kAccentLight,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: GoogleFonts.inter(
                  color: kTextSecondary, fontSize: 12)),
        ),
        Expanded(
          child: Text(value,
              style: GoogleFonts.inter(
                  color: kTextPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

class _LongTailChip extends StatelessWidget {
  final String label;
  const _LongTailChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kOrange.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              color: kOrange, fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }
}

// ── Pipeline step helper ──────────────────────────────────────────────────────
int pipelineStepIndex(PipelineStep step) {
  switch (step) {
    case PipelineStep.idle:
      return -1;
    case PipelineStep.fetchingTopics:
      return 0;
    case PipelineStep.evaluatingTopics:
      return 1;
    case PipelineStep.awaitingTopicSelection:
      return 1;
    case PipelineStep.generatingSeo:
      return 2;
    case PipelineStep.generatingContent:
      return 3;
    case PipelineStep.generatingMetadata:
      return 4;
    case PipelineStep.generatingImages:
      return 5;
    case PipelineStep.saving:
      return 6;
    case PipelineStep.done:
      return 7;
    case PipelineStep.error:
      return -1;
  }
}
