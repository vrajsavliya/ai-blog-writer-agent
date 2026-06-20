import 'dart:convert';
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

  /// Upload Media to WordPress
  Future<Map<String, dynamic>> uploadMedia(String localImagePath, {String? title, String? altText, String? caption}) async {
    try {
      final fileName = localImagePath.split('/').last;
      // Handle Web base64 images or Native file paths
      MultipartFile file;
      if (localImagePath.startsWith('data:image/')) {
        final bytes = base64Decode(localImagePath.split(',').last);
        file = MultipartFile.fromBytes(bytes, filename: fileName);
      } else {
        file = await MultipartFile.fromFile(localImagePath, filename: fileName);
      }

      final formData = FormData.fromMap({
        'title': title,
        'alt_text': altText,
        'caption': caption,
        'file': file,
      });

      final response = await _dio.post(
        '/upload-media',
        data: formData,
        options: Options(
          headers: {
            // override the default content type
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return {
        'mediaId': response.data['mediaId']?.toString() ?? '',
        'url': response.data['url']?.toString() ?? '',
      };
    } on DioException catch (e) {
      print('Dio error uploading media: ${e.response?.data ?? e.message}');
      throw Exception('Failed to upload media: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to upload media: $e');
    }
  }

  /// Publish article to WordPress via Custom REST API
  Future<String> publishToWordPress(Article article) async {
    try {
      String htmlContent = _markdownToHtml(article.content.fullArticleMarkdown);
      String? featuredMediaId;

      // 1. Upload Featured Image
      if (article.images.featuredImage.localImagePath != null) {
        final res = await uploadMedia(article.images.featuredImage.localImagePath!);
        featuredMediaId = res['mediaId'];
      }

      // 2. Upload Supporting Images & inject into HTML
      for (final img in article.images.supportingImages) {
        if (img.localImagePath != null) {
          final res = await uploadMedia(img.localImagePath!);
          final imgUrl = res['url'];
          if (imgUrl.isNotEmpty) {
            // Append images at the end of the post for now, or you can implement
            // logic to replace specific placeholders in the markdown if they exist.
            htmlContent += '\n<figure><img src="$imgUrl" alt="${img.altText}"><figcaption>${img.caption}</figcaption></figure>';
          }
        }
      }

      final response = await _dio.post(
        '/publish',
        data: {
          'title': article.content.title.isEmpty ? article.topic.title : article.content.title,
          'content': htmlContent,
          'status': 'publish',
          'slug': article.seo.urlSlug,
          'excerpt': article.seo.metaDescription,
          'categories': article.metadata.categories,
          'tags': article.metadata.tags,
          'meta': {
            '_yoast_wpseo_title': article.metadata.metaTitle,
            '_yoast_wpseo_metadesc': article.metadata.metaDescription,
          },
          if (featuredMediaId != null) 'featured_media': featuredMediaId,
        },
      );

      final postId = response.data['postId']?.toString() ?? '';
      return postId;
    } on DioException catch (e) {
      print('Dio error publishing to WP: ${e.response?.data ?? e.message}');
      throw Exception('Failed to publish: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to publish: $e');
    }
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
