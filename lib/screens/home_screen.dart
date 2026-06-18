import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/blog_provider.dart';
import '../models/article_model.dart';
import '../widgets/reusable_widgets.dart';
import 'blog_writer_screen.dart';
import 'article_preview_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: kSurface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: kHeaderGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: kAccentGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.auto_awesome,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'AI Blog Agent',
                              style: GoogleFonts.inter(
                                color: kTextPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Generated Articles',
                          style: GoogleFonts.inter(
                            color: kTextPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Powered by Groq AI & Tavily Search',
                          style: GoogleFonts.inter(
                              color: kTextSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Stats row ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: StreamBuilder<List<Article>>(
              stream: context.read<BlogProvider>().articlesStream,
              builder: (context, snapshot) {
                final articles = snapshot.data ?? [];
                final published = articles
                    .where((a) => a.status == PublishStatus.published)
                    .length;
                final saved = articles
                    .where((a) => a.status == PublishStatus.saved)
                    .length;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    children: [
                      _StatCard(
                          label: 'Total', value: '${articles.length}',
                          color: kAccent),
                      const SizedBox(width: 12),
                      _StatCard(
                          label: 'Published', value: '$published',
                          color: kGreen),
                      const SizedBox(width: 12),
                      _StatCard(
                          label: 'Saved', value: '$saved',
                          color: kOrange),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Article list ──────────────────────────────────────────────────────
          StreamBuilder<List<Article>>(
            stream: context.read<BlogProvider>().articlesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: kAccent),
                  ),
                );
              }

              if (snapshot.hasError) {
                final err = snapshot.error;
                final uid = FirebaseAuth.instance.currentUser?.uid;
                final path = uid != null
                    ? 'users/$uid/articles'
                    : '(no user — not authenticated)';

                // Log to console for debugging
                debugPrint('═══ FIRESTORE ERROR ═══');
                debugPrint('Error type : ${err.runtimeType}');
                debugPrint('Error msg  : $err');
                debugPrint('Collection : $path');
                debugPrint('Auth user  : $uid');
                debugPrint('══════════════════════');

                return SliverFillRemaining(
                  child: _FirestoreErrorState(
                    error: err.toString(),
                    collectionPath: path,
                    uid: uid,
                  ),
                );
              }

              final articles = snapshot.data ?? [];

              if (articles.isEmpty) {
                return const SliverFillRemaining(
                  child: _EmptyState(
                    icon: Icons.edit_note_rounded,
                    title: 'No Articles Yet',
                    subtitle:
                        'Tap the button below to generate your first AI blog article.',
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ArticleCard(
                      article: articles[index],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ArticlePreviewScreen(
                              article: articles[index]),
                        ),
                      ),
                    ),
                    childCount: articles.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // ── FAB ────────────────────────────────────────────────────────────────────
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: kAccentGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kAccent.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BlogWriterScreen()),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Generate New Blog',
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                  color: kTextSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Firestore Error State ─────────────────────────────────────────────────────
class _FirestoreErrorState extends StatelessWidget {
  final String error;
  final String collectionPath;
  final String? uid;

  const _FirestoreErrorState({
    required this.error,
    required this.collectionPath,
    required this.uid,
  });

  String get _diagnosis {
    final e = error.toLowerCase();
    if (e.contains('permission-denied') || e.contains('insufficient permissions')) {
      return '🔒 PERMISSION DENIED — Firestore rules are blocking access. Publish the security rules in your Firebase Console.';
    } else if (e.contains('not authenticated') || uid == null) {
      return '🔑 NOT AUTHENTICATED — No user is logged in. Please sign in first.';
    } else if (e.contains('unavailable') || e.contains('network')) {
      return '📡 NETWORK ERROR — Check your internet connection.';
    } else if (e.contains('not-found')) {
      return '📂 NOT FOUND — Collection or document does not exist yet.';
    }
    return '⚠️ UNKNOWN ERROR — See full message below.';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + title
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: kRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_off_rounded,
                        color: kRed, size: 30),
                  ),
                  const SizedBox(height: 12),
                  Text('Firestore Error',
                      style: GoogleFonts.inter(
                          color: kTextPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Diagnosis
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kOrange.withValues(alpha: 0.3)),
              ),
              child: Text(_diagnosis,
                  style: GoogleFonts.inter(
                      color: kOrange, fontSize: 12, height: 1.5)),
            ),
            const SizedBox(height: 16),

            // Debug details
            _DebugRow('Auth UID', uid ?? '⚠️ null (not logged in)'),
            _DebugRow('Collection', collectionPath),
            _DebugRow('Error', error),
            const SizedBox(height: 16),

            // Copy button
            GestureDetector(
              onTap: () => Clipboard.setData(ClipboardData(
                  text: 'UID: $uid\nPath: $collectionPath\nError: $error')),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorder),
                ),
                child: Center(
                  child: Text('Copy Debug Info',
                      style: GoogleFonts.inter(
                          color: kAccentLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebugRow extends StatelessWidget {
  final String label;
  final String value;
  const _DebugRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.inter(
                  color: kTextSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBorder),
            ),
            child: SelectableText(
              value,
              style: GoogleFonts.sourceCodePro(
                  color: kRed, fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: kAccentLight, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.inter(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: kTextSecondary, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
