import 'package:flutter/material.dart';
import '../../core/services/weather_service.dart';

class BestPracticesScreen extends StatefulWidget {
  const BestPracticesScreen({super.key});

  @override
  State<BestPracticesScreen> createState() => _BestPracticesScreenState();
}

class _BestPracticesScreenState extends State<BestPracticesScreen> {
  WeatherData? _weatherData;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final data = await WeatherService().fetchProductionWeather("Wheat");
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1F0B) : const Color(0xFFF5F7F3),
      appBar: AppBar(
        title: const Text("Farming Best Practices", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isLoadingWeather && _weatherData != null)
              _buildSmartWeatherAlert(_weatherData!, isDark),
            
            _buildIntroduction(isDark),
            const SizedBox(height: 24),
            
            _buildCategorySection(
              "Soil Health & Nutrients",
              [
                _Practice(
                  "Optimizing Nitrogen Levels",
                  "Nitrogen is essential for leafy growth and overall plant vigor.",
                  [
                    "Grow leguminous crops like beans or peas to fix nitrogen naturally.",
                    "Apply nitrogen fertilizers in multiple small doses rather than one large dose.",
                    "Use organic manures like compost or well-rotted cow dung."
                  ],
                  Icons.grass,
                  Colors.green,
                ),
                _Practice(
                  "Soil Testing & pH Balance",
                  "Understanding your soil's chemical makeup is the first step to a high yield.",
                  [
                    "Test soil every 2-3 years before the sowing season.",
                    "Maintain pH between 6.0 and 7.0 for most crops.",
                    "Add lime to acidic soil or sulfur to alkaline soil as recommended."
                  ],
                  Icons.science_outlined,
                  Colors.brown,
                ),
              ],
              isDark,
            ),
            
            const SizedBox(height: 24),
            _buildCategorySection(
              "Water & Irrigation Management",
              [
                _Practice(
                  "Precision Drip Irrigation",
                  "Save water and reduce weed growth by targeting only the plant roots.",
                  [
                    "Install drip lines close to the plant base.",
                    "Check for clogs in emitters regularly.",
                    "Irrigate during early morning or late evening to reduce evaporation."
                  ],
                  Icons.water_drop,
                  Colors.blue,
                ),
                _Practice(
                  "Mulching Techniques",
                  "Keep the soil moist and cool while suppressing weeds.",
                  [
                    "Use organic mulch like straw, dry leaves, or wood chips.",
                    "Apply a 2-3 inch layer around plants but not touching the stems.",
                    "Replace mulch as it decomposes to keep adding nutrients to the soil."
                  ],
                  Icons.layers,
                  Colors.cyan,
                ),
              ],
              isDark,
            ),

            const SizedBox(height: 24),
            _buildCategorySection(
              "Pest & Disease Control",
              [
                _Practice(
                  "Integrated Pest Management (IPM)",
                  "A sustainable approach to managing pests using biological and physical methods.",
                  [
                    "Encourage natural predators like ladybugs and spiders.",
                    "Use pheromone traps to monitor pest populations.",
                    "Apply chemical pesticides only as a last resort and follow safety guidelines."
                  ],
                  Icons.bug_report,
                  Colors.orange,
                ),
                _Practice(
                  "Crop Rotation",
                  "Breaking the cycle of pests and diseases while balancing soil nutrients.",
                  [
                    "Never plant the same crop family in the same spot two years in a row.",
                    "Follow heavy feeders (corn) with nitrogen fixers (beans).",
                    "Include deep-rooted crops to improve soil structure."
                  ],
                  Icons.loop,
                  Colors.deepOrange,
                ),
              ],
              isDark,
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroduction(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.green, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Expert Advice",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                ),
                const SizedBox(height: 4),
                Text(
                  "Follow these science-backed practices to improve your farm's productivity and sustainability.",
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<_Practice> practices, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
        ),
        ...practices.map((p) => _buildExpandablePracticeCard(p, isDark)),
      ],
    );
  }

  Widget _buildExpandablePracticeCard(_Practice practice, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2E1C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: practice.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(practice.icon, color: practice.color, size: 24),
          ),
          title: Text(
            practice.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            practice.shortDesc,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    "Actionable Steps:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  ...practice.steps.map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step,
                            style: TextStyle(fontSize: 14, height: 1.4, color: isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartWeatherAlert(WeatherData weather, bool isDark) {
    bool showDrainageAlert = weather.condition.toLowerCase().contains("rain") || weather.rainChance > 50;
    bool showHeatAlert = weather.temperature > 32;

    if (!showDrainageAlert && !showHeatAlert) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.orange.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "WEATHER ADVISORY",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white, letterSpacing: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  showDrainageAlert 
                    ? "Heavy rain expected. Check your field drainage systems immediately to prevent waterlogging and root rot." 
                    : "Intense heat detected. Consider extra irrigation during evening hours and use mulching to protect soil moisture.",
                  style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Practice {
  final String title;
  final String shortDesc;
  final List<String> steps;
  final IconData icon;
  final Color color;

  _Practice(this.title, this.shortDesc, this.steps, this.icon, this.color);
}
