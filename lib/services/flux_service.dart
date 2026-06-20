import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class FluxService {
  late final Dio _dio;
  
  FluxService() {
    // Use the API key provided in .env for NVIDIA NIM
    final apiKey = dotenv.env['FLUX.1-schnell-API'] ?? dotenv.env['FLUX_API_KEY'] ?? dotenv.env['GROK_API_KEY'] ?? '';

    _dio = Dio(BaseOptions(
      baseUrl: 'https://ai.api.nvidia.com/v1/genai',
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
    ));
  }

  Future<String?> generateAndDownloadImage(String prompt, String filenamePrefix) async {
    try {
      // Generate image via NVIDIA NIM API
      final randomSeed = Random().nextInt(1000000) + 1;
      final safePrompt = '$prompt, family friendly, safe for work, high quality';
      
      final response = await _dio.post(
        '/black-forest-labs/flux.1-schnell',
        data: {
          'prompt': safePrompt,
          'seed': randomSeed,
          'steps': 4,
          'width': 1344,
          'height': 1024,
        },
      );

      final List<dynamic> artifacts = response.data['artifacts'] ?? [];
      if (artifacts.isEmpty) {
        throw Exception('No image data returned from Flux API');
      }

      final String base64Image = artifacts[0]['base64'];

      // Decode the base64 image
      final Uint8List imageBytes = base64Decode(base64Image);
      
      if (kIsWeb) {
        // On web we cannot save to the local file system using dart:io,
        // so we return the image as a base64 data URI.
        return 'data:image/png;base64,$base64Image';
      }

      // On native platforms, save it to a temporary file
      final dir = await getTemporaryDirectory();
      final String uuid = const Uuid().v4();
      final String savePath = '${dir.path}/${filenamePrefix}_$uuid.png';

      final File file = File(savePath);
      await file.writeAsBytes(imageBytes);

      return savePath;
    } on DioException catch (e) {
      print('FluxService DioError: ${e.response?.data ?? e.message}');
      return null;
    } catch (e) {
      print('FluxService Error: $e');
      return null;
    }
  }
}
