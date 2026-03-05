import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> with TickerProviderStateMixin {
  WeatherData? _weatherData;
  bool _isLoading = true;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)),
    );

    _loadProductionWeather();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _loadProductionWeather() async {
    setState(() => _isLoading = true);
    final data = await WeatherService().fetchProductionWeather("Wheat");
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
      _entranceController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Agri-Climate AI",
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState(isDark)
          : _weatherData == null
              ? const Center(child: Text("Unable to sync climate data"))
              : _buildMainContent(isDark),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF1B5E20), const Color(0xFF0A1F0B)]
              : [const Color(0xFF2E7D32), const Color(0xFFF5F7F3)],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white70),
      ),
    );
  }

  Widget _buildMainContent(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF1B5E20), const Color(0xFF0A1F0B)]
              : [const Color(0xFF2E7D32), const Color(0xFFF5F7F3)],
          stops: const [0.0, 0.5],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _loadProductionWeather,
        color: Colors.greenAccent,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 110, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImmersiveSummary(isDark),
                  const SizedBox(height: 24),
                  _buildIntelligentAdvisory(isDark),
                  const SizedBox(height: 32),
                  _buildSectionHeader("7-Day Forecast", isDark),
                  const SizedBox(height: 16),
                  _buildForecastRow(isDark),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Climate Analytics", isDark),
                  const SizedBox(height: 16),
                  _buildMetricsGrid(isDark),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Rainfall Timeline", isDark),
                  const SizedBox(height: 16),
                  _buildRainfallChart(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : const Color(0xFF1B5E20),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildImmersiveSummary(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            _weatherData!.city,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AnimatedWeatherIcon(iconCode: _weatherData!.iconCode),
              const SizedBox(width: 24),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _weatherData!.temperature),
                duration: const Duration(seconds: 1),
                builder: (context, val, child) {
                  return Text(
                    "${val.toInt()}°",
                    style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.w200, height: 1.1),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _weatherData!.condition.toUpperCase(),
            style: const TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 4, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildIntelligentAdvisory(bool isDark) {
    bool isAlert = _weatherData!.alerts.any((a) => a.severity == "High");
    bool isCaution = _weatherData!.alerts.any((a) => a.severity == "Medium");

    Color accentColor = isAlert ? Colors.redAccent : (isCaution ? Colors.amberAccent : Colors.greenAccent);

    return _GlowWrapper(
      color: accentColor,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: accentColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FARMING ADVISORY",
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _weatherData!.recommendation,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastRow(bool isDark) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _weatherData!.forecast.length,
        itemBuilder: (context, index) {
          final f = _weatherData!.forecast[index];
          return _InteractiveForecastCard(forecast: f, isDark: isDark);
        },
      ),
    );
  }

  Widget _buildMetricsGrid(bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildMetricCard("Humidity", "${_weatherData!.humidity}%", Icons.water_drop_outlined, Colors.blueAccent, isDark, progress: _weatherData!.humidity / 100),
        _buildMetricCard("Wind Speed", "${_weatherData!.windSpeed.toInt()} km/h", Icons.air_rounded, Colors.orangeAccent, isDark),
        _buildMetricCard("Rain Chance", "${_weatherData!.rainChance.toInt()}%", Icons.umbrella_rounded, Colors.tealAccent, isDark, progress: _weatherData!.rainChance / 100),
        _buildMetricCard("UV Index", _weatherData!.uvIndex.toString(), Icons.wb_sunny_outlined, Colors.deepOrangeAccent, isDark, progress: _weatherData!.uvIndex / 11),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, bool isDark, {double? progress}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6)),
        ],
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 22),
              if (progress != null)
                SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRainfallChart(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 240,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  if (val.toInt() % 2 != 0) return const SizedBox();
                  int index = val.toInt();
                  if (index >= _weatherData!.forecast.length) return const SizedBox();
                  return Text(
                    _weatherData!.forecast[index]["time"],
                    style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400], fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _weatherData!.forecast.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value["pop"])).toList(),
              isCurved: true,
              color: Colors.greenAccent.shade400,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.greenAccent.shade400,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.greenAccent.shade400.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedWeatherIcon extends StatefulWidget {
  final String iconCode;
  const _AnimatedWeatherIcon({required this.iconCode});

  @override
  State<_AnimatedWeatherIcon> createState() => _AnimatedWeatherIconState();
}

class _AnimatedWeatherIconState extends State<_AnimatedWeatherIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floating;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _floating = Tween<double>(begin: 0, end: 10).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floating,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floating.value),
          child: Image.network(
            "https://openweathermap.org/img/wn/${widget.iconCode}@4x.png",
            height: 100,
            width: 100,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

class _GlowWrapper extends StatefulWidget {
  final Widget child;
  final Color color;
  const _GlowWrapper({required this.child, required this.color});

  @override
  State<_GlowWrapper> createState() => _GlowWrapperState();
}

class _GlowWrapperState extends State<_GlowWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _glow = Tween<double>(begin: 2.0, end: 12.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.2),
                blurRadius: _glow.value,
                spreadRadius: _glow.value / 4,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _InteractiveForecastCard extends StatefulWidget {
  final Map<String, dynamic> forecast;
  final bool isDark;
  const _InteractiveForecastCard({required this.forecast, required this.isDark});

  @override
  State<_InteractiveForecastCard> createState() => _InteractiveForecastCardState();
}

class _InteractiveForecastCardState extends State<_InteractiveForecastCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 90,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.white.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
            border: Border.all(color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.forecast["time"], style: TextStyle(color: widget.isDark ? Colors.white54 : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Image.network("https://openweathermap.org/img/wn/${widget.forecast["icon"]}.png", height: 36),
              const SizedBox(height: 8),
              Text("${widget.forecast["temp"].toInt()}°", style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
