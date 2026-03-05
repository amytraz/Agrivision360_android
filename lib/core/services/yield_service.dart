import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'weather_service.dart';

class YieldPrediction {
  final double tons;
  final String reasoning;
  final double confidence;

  YieldPrediction({required this.tons, required this.reasoning, required this.confidence});
}

class YieldService {
  final WeatherService _weatherService = WeatherService();

  Future<YieldPrediction?> getYieldEstimate({
    required String cropType,
    required double area,
    required String areaUnit,
    String? cropVariety,
    DateTime? sowingDate,
    String? soilType,
    String? npk,
    double? soilPh,
    String? irrigationMethod,
    String? fertilizerUsage,
  }) async {
    try {
      // 1. Fetch Real-time Weather Data (Context)
      final weatherData = await _weatherService.fetchProductionWeather(cropType);
      if (weatherData == null) throw "Weather data unavailable for analysis.";

      // 2. Prepare the AI Prompt (Inference Logic)
      final String prompt = """
      You are an expert Agronomist. Calculate the estimated crop yield based on these parameters:
      - Crop: $cropType
      - Variety/Genotype: ${cropVariety ?? 'Not specified'}
      - Area: $area $areaUnit
      - Sowing Date: ${sowingDate?.toIso8601String().split('T')[0] ?? 'Not specified'}
      - Soil Type: ${soilType ?? 'Not specified'}
      - Soil Nutrients (NPK): ${npk ?? 'Not specified'}
      - Soil pH: ${soilPh ?? 'Not specified'}
      - Irrigation: ${irrigationMethod ?? 'Not specified'}
      - Fertilizer/Pesticide Usage: ${fertilizerUsage ?? 'Not specified'}
      
      Environmental Context:
      - Current Temperature: ${weatherData.temperature}°C
      - Humidity: ${weatherData.humidity}%
      - Current Condition: ${weatherData.condition}
      
      Instructions:
      1. Provide an estimated yield in Metric Tons for the total area.
      2. Provide a short agricultural reasoning (max 3 sentences) considering the specific inputs like variety and soil if provided.
      3. Provide a confidence percentage (0-100).
      
      Response Format (JSON only):
      {
        "tons": 12.5,
        "reasoning": "Yield estimate reflects the variety's potential and current soil conditions.",
        "confidence": 85
      }
      """;

      // 3. Call Groq AI API
      final response = await http.post(
        Uri.parse(AppConfig.groqUrl),
        headers: {
          "Authorization": "Bearer ${AppConfig.groqApiKey}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": AppConfig.groqModel,
          "messages": [
            {"role": "system", "content": "You are a precise agricultural data analyst specializing in yield prediction."},
            {"role": "user", "content": prompt}
          ],
          "response_format": {"type": "json_object"},
          "temperature": 0.1,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = jsonDecode(data["choices"][0]["message"]["content"]);
        
        return YieldPrediction(
          tons: (content["tons"] as num).toDouble(),
          reasoning: content["reasoning"],
          confidence: (content["confidence"] as num).toDouble(),
        );
      }
    } catch (e) {
      print("YIELD ENGINE ERROR: $e");
    }
    return null;
  }
}
