import 'dart:ui';
import 'package:flutter/material.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/ai/ai_screen.dart';
import '../../features/marketplace/marketplace_screen.dart';
import '../../features/resources/disease_library_screen.dart';
import '../../features/resources/best_practices_screen.dart';
import '../../features/resources/soil_guide_screen.dart';
import '../../features/resources/fertilizer_recommendation_screen.dart';
import '../../features/resources/govt_schemes_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MarketplaceScreen(),
    Center(child: Text("Crop Analytics")), // Camera placeholder
    AiAssistantScreen(),
    FarmingResourcesScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) return; // Don't switch tab for the camera FAB
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: 85,
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF0A1F0B).withOpacity(0.8) 
                      : Colors.white.withOpacity(0.85),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.grid_view_outlined, Icons.grid_view_rounded, "Hub"),
                    _buildNavItem(1, Icons.shopping_basket_outlined, Icons.shopping_basket, "Market"),
                    const SizedBox(width: 48), // Space for Camera FAB
                    _buildNavItem(3, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, "Ask AI"),
                    _buildNavItem(4, Icons.auto_stories_outlined, Icons.auto_stories, "Library"),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 35,
            child: _buildCameraFAB(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? Colors.green.shade700 : Colors.grey.shade500;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? filledIcon : outlineIcon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraFAB() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Launching AI Crop Scanner...")),
        );
      },
      child: Container(
        height: 68,
        width: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade400, Colors.green.shade800],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.camera_alt_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

class FarmingResourcesScreen extends StatelessWidget {
  const FarmingResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Farming Library", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildResourceCard(
            context,
            "Government Schemes",
            "Latest subsidies and support for India & Nepal.",
            Icons.account_balance_outlined,
            Colors.red,
            const GovtSchemesScreen(),
          ),
          _buildResourceCard(
            context,
            "Best Farming Practices",
            "Seasonal and crop-specific advice.",
            Icons.verified_user_outlined,
            Colors.blue,
            const BestPracticesScreen(),
          ),
          _buildResourceCard(
            context,
            "Soil Information Guide",
            "Learn about soil types and properties.",
            Icons.layers_outlined,
            Colors.brown,
            const SoilGuideScreen(),
          ),
          _buildResourceCard(
            context,
            "Fertilizer Recommendations",
            "Optimal nutrient balance for crops.",
            Icons.science_outlined,
            Colors.cyan,
            const FertilizerRecommendationScreen(),
          ),
          _buildResourceCard(
            context,
            "Crop Disease Library",
            "COMING SOON",
            Icons.library_books_outlined,
            Colors.orange,
            null,
            isComingSoon: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, String title, String desc, IconData icon, Color color, Widget? screen, {bool isComingSoon = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        onTap: screen != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)) : null,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: isComingSoon 
          ? Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Text(
                "COMING SOON",
                style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            )
          : Text(
              desc,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
        trailing: isComingSoon ? null : const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
