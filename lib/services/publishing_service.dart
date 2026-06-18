
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/article_model.dart';

class PublishingService {
  late final Dio _dio;

  PublishingService() {
    final wordpressUrl = dotenv.env['WORDPRESS_URL'] ?? '';
    final apiKey = dotenv.env['WORDPRESS_API_KEY'] ?? dotenv.env['WORDPRESS_APP_PASSWORD'] ?? '';

    final baseUrl = wordpressUrl.endsWith('/')
        ? wordpressUrl.substring(0, wordpressUrl.length - 1)
        : wordpressUrl;

    _dio = Dio(BaseOptions(
      baseUrl: '$baseUrl/wp-json/ai-blog/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'x-api-key': apiKey,
        'Content-Type': 'application/json',
      },
    ));
  }

  /// Publish article to WordPress via Custom REST API
  Future<String> publishToWordPress(Article article) async {
    final response = await _dio.post(
      '/publish',
      data: {
        'title': article.content.title,
        'content': _markdownToHtml(article.content.fullArticleMarkdown),
        'status': 'publish',
        'slug': article.seo.urlSlug,
        'excerpt': article.seo.metaDescription,
        'categories': article.metadata.categories,
        'tags': article.metadata.tags,
        'meta': {
          '_yoast_wpseo_title': article.metadata.metaTitle,
          '_yoast_wpseo_metadesc': article.metadata.metaDescription,
        },
      },
    );

    final postId = response.data['postId']?.toString() ?? '';
    return postId;
  }

  /// Simple Markdown to HTML conversion for WordPress
  String _markdownToHtml(String markdown) {
    String html = markdown;

    // Headers
    html = html.replaceAllMapped(
        RegExp(r'^### (.+)$', multiLine: true), (m) => '<h3>${m[1]}</h3>');
    html = html.replaceAllMapped(
        RegExp(r'^## (.+)$', multiLine: true), (m) => '<h2>${m[1]}</h2>');
    html = html.replaceAllMapped(
        RegExp(r'^# (.+)$', multiLine: true), (m) => '<h1>${m[1]}</h1>');

    // Bold and italic
    html = html.replaceAllMapped(
        RegExp(r'\*\*(.+?)\*\*'), (m) => '<strong>${m[1]}</strong>');
    html = html.replaceAllMapped(
        RegExp(r'\*(.+?)\*'), (m) => '<em>${m[1]}</em>');

    // Bullet lists
    html = html.replaceAllMapped(
        RegExp(r'^[*-] (.+)$', multiLine: true), (m) => '<li>${m[1]}</li>');

    // Paragraphs
    html = html.replaceAll(RegExp(r'\n\n'), '</p><p>');
    html = '<p>$html</p>';

    return html;
  }
}
