import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_openai_stream/env.dart';

class ApiService {
  // This class will handle API requests and responses.
  static const baseUrl = apiUrl;

  Future<String> sendRequest({
    required String text,
    required String modelName,
    Uint8List? imageBytes,  // This mean image is optional
  }) async {
    final url = Uri.parse('$baseUrl/predict');

    final body = {
      'text': text,
      'model_name': modelName,
    };

    if (imageBytes != null) {
      final base64Image = base64Encode(imageBytes);
      body['images'] = base64Image;
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
    final responseData = jsonDecode(response.body);

    return responseData['outputs'] ?? '';
  }

  // This method fake streaming response 
  static Stream<String> getChatResponseStream({
    required String text,
    required String modelName,
    Uint8List? imageBytes,
  }) async* {
    try {
      // Get full response from API
      final apiService = ApiService();
      final fullResponse = await apiService.sendRequest(
        text: text,
        modelName: modelName,
        imageBytes: imageBytes,
      );

      // Stream the response in chunks for better UX
      final chunks = _splitIntoChunks(fullResponse);
      
      for (var chunk in chunks) {
        await Future.delayed(const Duration(milliseconds: 80));
        yield chunk;
      }
    } catch (e) {
      yield 'Error: Connection failed. Please check your internet connection.\nDetails: $e';
    }
  }

  static List<String> _splitIntoChunks(String text) {
    if (text.isEmpty) return [];
    
    final chunks = <String>[];
    final words = text.split(' ');
    
    String currentChunk = '';
    for (var word in words) {
      currentChunk += '$word ';
      
      // Create chunks of reasonable size (about 5-8 words)
      if (currentChunk.split(' ').length >= 6 ||
          word.endsWith('.') ||
          word.endsWith('!') ||
          word.endsWith('?') ||
          word.endsWith(':') ||
          word.endsWith(';')) {
        chunks.add(currentChunk.trim());
        currentChunk = '';
      }
    }
    
    // Add any remaining text
    if (currentChunk.trim().isNotEmpty) {
      chunks.add(currentChunk.trim());
    }
    
    return chunks.map((chunk) => '$chunk ').toList();
  }


  // Method for sending image + text (medical analysis)
  Future<String> sendMedicalRequest({
    required String text,
    required String modelName,
    required Uint8List imageBytes,
  }) async {
    return await sendRequest(
      text: text,
      modelName: modelName,
      imageBytes: imageBytes,
    );
  }

  // Streaming version for medical analysis
  static Stream<String> getMedicalResponseStream({
    required String text,
    required String modelName,
    required Uint8List imageBytes,
  }) async* {
    yield* getChatResponseStream(
      text: text,
      modelName: modelName,
      imageBytes: imageBytes,
    );
  }
}