class AppConfig {
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: "");
  static const String openWeatherApiKey = String.fromEnvironment('OPENWEATHER_API_KEY', defaultValue: "");
  static const String groqUrl = "https://api.groq.com/openai/v1/chat/completions";
  static const String groqModel = "llama-3.3-70b-versatile";
}