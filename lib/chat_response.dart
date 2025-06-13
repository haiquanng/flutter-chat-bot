import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Stream<String> getChatResponse(String userMessage) async* {
  final apiKey = dotenv.env['GEMINI_API_KEY'];

  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
  );

  final body = jsonEncode({
    "contents": [
      {
        "parts": [
          {"text": userMessage}
        ]
      }
    ]
  });

  final response = await http.post(url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final candidates = data["candidates"];
    if (candidates != null && candidates.isNotEmpty) {
      final text = candidates[0]["content"]["parts"][0]["text"];
      for (var word in text.split(' ')) {
        await Future.delayed(Duration(milliseconds: 10));
        yield word + ' ';
      }
    }
  } else {
    print('❌ Error: ${response.statusCode}');
    print(response.body);
  }
}
