import 'package:flutter/material.dart';
import '../../../core/services/weather_service.dart';
import '../../weather/weather_screen.dart';

class WeatherOverviewCard extends StatefulWidget {
  const WeatherOverviewCard({super.key});

  @override
  State<WeatherOverviewCard> createState() => _WeatherOverviewCardState();
}

class _WeatherOverviewCardState extends State<WeatherOverviewCard> {
  bool _isPressed = false;
  WeatherData? _weatherData;
  bool _isLoading = true;
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _loadInitialWeather();
  }

  Future<void> _loadInitialWeather() async {
    // 1. Try to load from cache first for instant UI
    final cachedData = await _weatherService.getCachedWeather();
    if (cachedData != null && mounted) {
      setState(() {
        _weatherData = cachedData;
        _isLoading = false;
      });
    }

    // 2. Fetch fresh data in the background
    _refreshWeather();
  }

  Future<void> _refreshWeather() async {
    final freshData = await _weatherService.fetchProductionWeather("General");
    if (freshData != null && mounted) {
      setState(() {
        _weatherData = freshData;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _weatherData == null) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(color: Colors.green),
      ));
    }

    if (_weatherData == null) return const SizedBox.shrink();

    final bool isRainy = _weatherData!.condition.toLowerCase().contains("rain");

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const WeatherScreen()));
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            ),
            boxShadow: [
              BoxShadow(
                color: isRainy 
                    ? Colors.amber.withOpacity(0.3) 
                    : Colors.black.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
            border: isRainy 
                ? Border.all(color: Colors.amber.withOpacity(0.5), width: 2)
                : null,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_weatherData!.temperature.toInt()}°C",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${_weatherData!.condition[0].toUpperCase()}${_weatherData!.condition.substring(1)} • ${_weatherData!.city}",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Image.network(
                          "https://openweathermap.org/img/wn/${_weatherData!.iconCode}@4x.png",
                          height: 80,
                          width: 80,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(
                        _weatherData!.forecast.length, 
                        (index) => _buildForecastItem(index, _weatherData!.forecast[index])
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _weatherData!.recommendation,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Subtle loading indicator at the top if background refresh is active
              if (_isLoading && _weatherData != null)
                const Positioned(
                  top: 10,
                  right: 10,
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForecastItem(int index, Map<String, dynamic> f) {
    return Container(
      margin: const EdgeInsets.only(right: 16, bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            f["time"],
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Image.network(
            "https://openweathermap.org/img/wn/${f["icon"]}.png",
            height: 24,
            width: 24,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            "${f["temp"].toInt()}°",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
