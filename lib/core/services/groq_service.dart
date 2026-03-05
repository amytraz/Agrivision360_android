import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../constants/system_prompt.dart';

class GroqService {
  final List<Map<String, String>> _history = [
    {"role": "system", "content": systemPrompt},
  ];

  Future<String> sendMessageToGroq(String userMessage) async {
    // Check if API key is loaded
    if (AppConfig.groqApiKey.isEmpty) {
      debugPrint("GROQ_API_KEY is empty. Ensure you ran with --dart-define-from-file=env/config.json");
      throw Exception("AI Setup Required: API Key not found. Please restart the app fully.");
    }

    _history.add({"role": "user", "content": userMessage});

    if (_history.length > 20) {
      _history.removeRange(1, 3);
    }

    try {
      final response = await http.post(
        Uri.parse(AppConfig.groqUrl),
        headers: {
          "Authorization": "Bearer ${AppConfig.groqApiKey}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": AppConfig.groqModel,
          "messages": _history,
          "temperature": 0.7,
          "max_tokens": 1024,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String assistantReply = data["choices"][0]["message"]["content"] ?? "";
        _history.add({"role": "assistant", "content": assistantReply});
        return assistantReply;
      } else {
        final errorData = jsonDecode(response.body);
        String errMsg = errorData["error"]["message"] ?? "Failed to connect to AI engine";
        
        if (errMsg.toLowerCase().contains("api key")) {
          debugPrint("Full Error from Groq: $errMsg");
          throw Exception("The API Key provided is being rejected by Groq. Please check your config.json.");
        }
        
        throw Exception(errMsg);
      }
    } on http.ClientException {
      throw Exception("Network error. Please check your internet connection.");
    } catch (e) {
      if (e.toString().contains("TimeoutException")) {
        throw Exception("Request timed out. Please try again.");
      }
      rethrow;
    }
  }
}
