import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/topic_model.dart';
import '../models/article_model.dart';
import '../data/prompts.dart';

class GroqService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.groq.com/openai/v1',
    headers: {
      'Content-Type': 'application/json',
    },
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  GroqService() {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? dotenv.env['GROK_API_KEY'] ?? '';
    _dio.options.headers['Authorization'] = 'Bearer $apiKey';
  }

  Future<String> _generateResponse(String prompt) async {
    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'llama-3.3-70b-versatile',
          'response_format': {'type': 'json_object'},
          'temperature': 0.7,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ]
        },
      );
      return response.data['choices'][0]['message']['content'] as String;
    } on DioException catch (e) {
      throw Exception('Groq API Error: ${e.response?.data ?? e.message}');
    }
  }

  /// Strips Markdown code fences if present and parses JSON
  dynamic _parseJson(String raw) {
    String cleaned = raw.trim();
    // Remove ```json ... ``` or ``` ... ```
    cleaned = cleaned.replaceAll(RegExp(r'^```json\s*', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^```\s*', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'```$', multiLine: true), '');
    return jsonDecode(cleaned.trim());
  }

  /// Step 2: Evaluate and score raw topics
  Future<List<Topic>> evaluateTopics(List<String> rawTopics) async {
    final prompt = Prompts.trendEvaluationPrompt(rawTopics);
    final text = await _generateResponse(prompt);

    final Map<String, dynamic> jsonMap = _parseJson(text) as Map<String, dynamic>;
    final List<dynamic> jsonList = jsonMap['topics'] as List<dynamic>? ?? [];
    return jsonList.map((e) => Topic.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }

  /// Step 3: Generate SEO data for a topic
  Future<SeoData> generateSeoData(Topic topic) async {
    final prompt = Prompts.seoResearchPrompt(topic.title);
    final text = await _generateResponse(prompt);
    return SeoData.fromJson(_parseJson(text) as Map<String, dynamic>);
  }

  /// Step 4: Generate full blog content
  Future<BlogContent> generateBlogContent(Topic topic, SeoData seo) async {
    final prompt = Prompts.blogGenerationPrompt(
      topic.title,
      seo.primaryKeyword,
      seo.secondaryKeywords,
    );
    final text = await _generateResponse(prompt);
    return BlogContent.fromJson(_parseJson(text) as Map<String, dynamic>);
  }

  /// Step 5: Generate article metadata
  Future<ArticleMetadata> generateMetadata(Article article) async {
    final prompt = Prompts.metadataPrompt(
      article.content.title,
      article.seo.primaryKeyword,
      article.topic.keywords.isNotEmpty ? article.topic.keywords.first : '',
    );
    final text = await _generateResponse(prompt);
    return ArticleMetadata.fromJson(_parseJson(text) as Map<String, dynamic>);
  }

  /// Step 6: Generate image prompts
  Future<ImagePackage> generateImagePackage(Topic topic) async {
    final prompt = Prompts.imagePromptGenerationPrompt(topic.title);
    final text = await _generateResponse(prompt);
    return ImagePackage.fromJson(_parseJson(text) as Map<String, dynamic>);
  }

  /// Step 7: AI Search Optimization — E-E-A-T, AEO, GEO, AISEO, LLMO
  Future<AiSearchOptimizationData> generateAiSearchOptimization({
    required String articleTitle,
    required String primaryKeyword,
    required String fullArticleMarkdown,
  }) async {
    final prompt = Prompts.aiSearchOptimizationPrompt(
      articleTitle,
      primaryKeyword,
      fullArticleMarkdown,
    );
    final text = await _generateResponse(prompt);
    return AiSearchOptimizationData.fromJson(
        _parseJson(text) as Map<String, dynamic>);
  }
}
