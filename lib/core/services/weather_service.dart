import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherAlert {
  final String type;
  final String severity;
  final String message;
  WeatherAlert({required this.type, required this.severity, required this.message});

  Map<String, dynamic> toJson() => {'type': type, 'severity': severity, 'message': message};
  factory WeatherAlert.fromJson(Map<String, dynamic> json) => WeatherAlert(type: json['type'], severity: json['severity'], message: json['message']);
}

class WeatherData {
  final double temperature;
  final String condition;
  final String iconCode;
  final String city;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final double rainChance;
  final double visibility;
  final int pressure;
  final double uvIndex;
  final DateTime sunrise;
  final DateTime sunset;
  final int aqi;
  final Map<String, double> aqiBreakdown;
  final List<WeatherAlert> alerts;
  final String recommendation;
  final List<Map<String, dynamic>> forecast;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.city,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.rainChance,
    required this.visibility,
    required this.pressure,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.aqi,
    required this.aqiBreakdown,
    required this.alerts,
    required this.recommendation,
    required this.forecast,
  });

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'condition': condition,
    'iconCode': iconCode,
    'city': city,
    'humidity': humidity,
    'windSpeed': windSpeed,
    'windDeg': windDeg,
    'rainChance': rainChance,
    'visibility': visibility,
    'pressure': pressure,
    'uvIndex': uvIndex,
    'sunrise': sunrise.toIso8601String(),
    'sunset': sunset.toIso8601String(),
    'aqi': aqi,
    'aqiBreakdown': aqiBreakdown,
    'alerts': alerts.map((e) => e.toJson()).toList(),
    'recommendation': recommendation,
    'forecast': forecast,
  };

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
    temperature: (json['temperature'] as num).toDouble(),
    condition: json['condition'],
    iconCode: json['iconCode'],
    city: json['city'],
    humidity: json['humidity'],
    windSpeed: (json['windSpeed'] as num).toDouble(),
    windDeg: json['windDeg'],
    rainChance: (json['rainChance'] as num).toDouble(),
    visibility: (json['visibility'] as num).toDouble(),
    pressure: json['pressure'],
    uvIndex: (json['uvIndex'] as num).toDouble(),
    sunrise: DateTime.parse(json['sunrise']),
    sunset: DateTime.parse(json['sunset']),
    aqi: json['aqi'],
    aqiBreakdown: Map<String, double>.from(json['aqiBreakdown']),
    alerts: (json['alerts'] as List).map((e) => WeatherAlert.fromJson(e)).toList(),
    recommendation: json['recommendation'],
    forecast: List<Map<String, dynamic>>.from(json['forecast']),
  );
}

class WeatherService {
  final String apiKey = "63f99a14ebffaf70f4731b83a7270e08";
  static const String _cacheKey = "cached_weather_data";

  Future<WeatherData?> getCachedWeather() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cached = prefs.getString(_cacheKey);
      if (cached != null) {
        return WeatherData.fromJson(jsonDecode(cached));
      }
    } catch (e) {
      print("Cache read error: $e");
    }
    return null;
  }

  Future<void> _cacheWeather(WeatherData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(data.toJson()));
    } catch (e) {
      print("Cache write error: $e");
    }
  }

  Future<WeatherData?> fetchProductionWeather(String cropType, {String? city}) async {
    try {
      double lat = 18.5204; // Default Pune
      double lon = 73.8567;

      // Start fetching position in background or use a faster timeout
      Position? position;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low, // Lower accuracy for speed
              timeLimit: const Duration(seconds: 2), // Aggressive timeout
            );
            lat = position.latitude;
            lon = position.longitude;
          }
        }
      } catch (e) {
        print("Fast location fetch failed, using default/cached: $e");
      }

      final String baseUrl = "https://api.openweathermap.org/data/2.5";
      final String query = (city != null && city.isNotEmpty) ? "q=$city" : "lat=$lat&lon=$lon";
      
      // Parallelize API calls for speed
      final currentUrl = "$baseUrl/weather?$query&appid=$apiKey&units=metric";
      final forecastUrl = "$baseUrl/forecast?$query&appid=$apiKey&units=metric";

      final responses = await Future.wait([
        http.get(Uri.parse(currentUrl)).timeout(const Duration(seconds: 5)),
        http.get(Uri.parse(forecastUrl)).timeout(const Duration(seconds: 5)),
      ]);

      if (responses[0].statusCode != 200 || responses[1].statusCode != 200) return null;
      
      final curData = jsonDecode(responses[0].body);
      final forData = jsonDecode(responses[1].body);

      double temp = (curData["main"]["temp"] as num).toDouble();
      String condMain = curData["weather"][0]["main"];
      
      List<WeatherAlert> alerts = [];
      String rec = "Stable conditions. Ideal for standard farm maintenance.";
      
      if (condMain.toLowerCase().contains("rain")) {
        rec = "Rain detected. Delay irrigation and check field drainage.";
        alerts.add(WeatherAlert(type: "Rain", severity: "Medium", message: "Waterlogging risk."));
      } else if (temp > 35) {
        rec = "High heat risk. Increase water supply to prevent crop wilting.";
        alerts.add(WeatherAlert(type: "Heat", severity: "High", message: "Stress risk."));
      }

      List<Map<String, dynamic>> forecastItems = [];
      int count = math.min(forData["list"].length as int, 8);
      for (var i = 0; i < count; i++) {
        forecastItems.add({
          "time": forData["list"][i]["dt_txt"].split(" ")[1].substring(0, 5),
          "temp": (forData["list"][i]["main"]["temp"] as num).toDouble(),
          "icon": forData["list"][i]["weather"][0]["icon"],
          "pop": (forData["list"][i]["pop"] as num).toDouble() * 100,
        });
      }

      final result = WeatherData(
        temperature: temp,
        condition: curData["weather"][0]["description"],
        iconCode: curData["weather"][0]["icon"],
        city: curData["name"],
        humidity: curData["main"]["humidity"],
        windSpeed: (curData["wind"]["speed"] as num).toDouble(),
        windDeg: curData["wind"]["deg"] ?? 0,
        rainChance: (forData["list"][0]["pop"] as num).toDouble() * 100,
        visibility: (curData["visibility"] as num).toDouble() / 1000,
        pressure: curData["main"]["pressure"],
        uvIndex: 3.0,
        sunrise: DateTime.fromMillisecondsSinceEpoch(curData["sys"]["sunrise"] * 1000),
        sunset: DateTime.fromMillisecondsSinceEpoch(curData["sys"]["sunset"] * 1000),
        aqi: 1,
        aqiBreakdown: {"PM2.5": 12, "PM10": 20, "NO2": 5, "O3": 30},
        alerts: alerts,
        recommendation: rec,
        forecast: forecastItems,
      );

      _cacheWeather(result); // Cache the successful result
      return result;

    } catch (e) {
      print("CRITICAL SERVICE ERROR: $e");
    }
    return null;
  }
}
