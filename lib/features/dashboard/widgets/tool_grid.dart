import 'package:flutter/material.dart';
import '../../weather/weather_screen.dart';
import '../../ai/ai_screen.dart';
import '../../farm_calendar/farm_calendar_screen.dart';
import '../../yield_prediction/yield_prediction_screen.dart';
import '../../resources/disease_library_screen.dart';
import '../../resources/best_practices_screen.dart';
import '../../marketplace/marketplace_screen.dart';
import '../../resources/soil_guide_screen.dart';
import '../../resources/fertilizer_recommendation_screen.dart';

class ToolGrid extends StatelessWidget {
  const ToolGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;
    final bool isDesktop = size.width > 1000;

    return Column(
      children: [
        _buildPremiumSection(
          context,
          "Smart Advisory",
          [
            _ToolItem("Weather Insights", Icons.wb_sunny_outlined, Colors.orange, const WeatherScreen()),
            _ToolItem("AI Assistant", Icons.smart_toy_outlined, Colors.indigo, const AiAssistantScreen()),
            _ToolItem("Soil Guide", Icons.layers_outlined, Colors.brown, const SoilGuideScreen()),
            _ToolItem("Fertilizer Rec.", Icons.science_outlined, Colors.cyan, const FertilizerRecommendationScreen()),
          ],
          delay: 0,
          crossAxisCount: isDesktop ? 4 : (isTablet ? 3 : 2),
        ),
        const SizedBox(height: 20),
        _buildCropHealthModule(context, delay: 200, isTablet: isTablet),
        const SizedBox(height: 20),
        _buildPremiumSection(
          context,
          "Planning & Tools",
          [
            _ToolItem("Crop Calendar", Icons.calendar_today_outlined, Colors.blueGrey, const FarmCalendarScreen()),
            _ToolItem("Yield Prediction", Icons.trending_up, Colors.green, const YieldPredictionScreen()),
            _ToolItem("Market Prices", Icons.analytics_outlined, Colors.teal, const MarketplaceScreen()),
          ],
          delay: 400,
          crossAxisCount: isDesktop ? 3 : (isTablet ? 3 : 2),
        ),
        const SizedBox(height: 20),
        _buildPremiumSection(
          context,
          "Resources",
          [
            _ToolItem("Farming Tips", Icons.lightbulb_outline, Colors.amber, const BestPracticesScreen()),
            _ToolItem("Govt Schemes", Icons.account_balance_outlined, Colors.red, null),
            _ToolItem("Equipment Rental", Icons.construction_outlined, Colors.grey, null),
          ],
          delay: 600,
          crossAxisCount: isDesktop ? 3 : (isTablet ? 3 : 2),
        ),
      ],
    );
  }

  Widget _buildPremiumSection(BuildContext context, String title, List<_ToolItem> items, {required int delay, required int crossAxisCount}) {
    return _FadeInWrapper(
      delay: delay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) => _buildGlassToolCard(context, items[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
              color: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropHealthModule(BuildContext context, {required int delay, required bool isTablet}) {
    return _FadeInWrapper(
      delay: delay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Crop Health"),
          const SizedBox(height: 12),
          if (isTablet)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildAuraHeroCard(context)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      _buildGlassToolCard(context, _ToolItem("Best Practices", Icons.verified_user_outlined, Colors.blue, const BestPracticesScreen())),
                      const SizedBox(height: 12),
                      _buildGlassToolCard(context, _ToolItem("Disease Library", Icons.library_books_outlined, Colors.deepOrange, const DiseaseLibraryScreen())),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildAuraHeroCard(context),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildGlassToolCard(context, _ToolItem("Best Practices", Icons.verified_user_outlined, Colors.blue, const BestPracticesScreen()))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildGlassToolCard(context, _ToolItem("Disease Library", Icons.library_books_outlined, Colors.deepOrange, const DiseaseLibraryScreen()))),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAuraHeroCard(BuildContext context) {
    return _InteractiveWrapper(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Launching Crop AI Scanner...")),
        );
      },
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [Colors.green.shade800, Colors.green.shade600, Colors.green.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Ambient Glowing Orb
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              // Scanning Effect
              const _AdvancedScanningLine(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.center_focus_strong_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Smart Crop Scan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Instant AI Diagnostics",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassToolCard(BuildContext context, _ToolItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _InteractiveWrapper(
      onTap: () {
        if (item.screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen!));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B2E1C) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.1,
                  color: isDark ? Colors.white : const Color(0xFF263238),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget? screen;
  _ToolItem(this.title, this.icon, this.color, this.screen);
}

class _InteractiveWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _InteractiveWrapper({required this.child, required this.onTap});

  @override
  State<_InteractiveWrapper> createState() => _InteractiveWrapperState();
}

class _InteractiveWrapperState extends State<_InteractiveWrapper> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _AdvancedScanningLine extends StatefulWidget {
  const _AdvancedScanningLine();

  @override
  State<_AdvancedScanningLine> createState() => _AdvancedScanningLineState();
}

class _AdvancedScanningLineState extends State<_AdvancedScanningLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _animation = Tween<double>(begin: -0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: 0,
          right: 0,
          top: 130 * _animation.value,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  Colors.greenAccent.withOpacity(0),
                  Colors.greenAccent.withOpacity(0.8),
                  Colors.greenAccent.withOpacity(0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FadeInWrapper extends StatefulWidget {
  final Widget child;
  final int delay;
  const _FadeInWrapper({required this.child, required this.delay});

  @override
  State<_FadeInWrapper> createState() => _FadeInWrapperState();
}

class _FadeInWrapperState extends State<_FadeInWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.easeOut)),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic)),
    );
    
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
