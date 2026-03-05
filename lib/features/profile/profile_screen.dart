import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1F0B) : const Color(0xFFF5F7F3),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverHeader(authService, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Farm Details"),
                  const SizedBox(height: 12),
                  _buildFarmDetailsCard(isDark),
                  
                  const SizedBox(height: 28),
                  _buildSectionTitle("Farm Insights"),
                  const SizedBox(height: 12),
                  _buildInsightsRow(),
                  
                  const SizedBox(height: 28),
                  _buildSectionTitle("Saved & Activity"),
                  const SizedBox(height: 12),
                  _buildActivitySection(isDark),
                  
                  const SizedBox(height: 28),
                  _buildSectionTitle("Preferences"),
                  const SizedBox(height: 12),
                  _buildPreferencesCard(themeService, isDark),
                  
                  const SizedBox(height: 28),
                  _buildSectionTitle("Account"),
                  const SizedBox(height: 12),
                  _buildAccountSection(context, authService, isDark),
                  
                  const SizedBox(height: 120), // Bottom padding for nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(AuthService authService, bool isDark) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF1B5E20) : const Color(0xFF2E7D32),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Faint background pattern (Simulated with icons)
            Positioned(
              right: -30,
              top: -20,
              child: Opacity(
                opacity: 0.05,
                child: Icon(Icons.eco, size: 250, color: Colors.white),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white24,
                      backgroundImage: authService.userPhoto != null 
                          ? NetworkImage(authService.userPhoto!) 
                          : null,
                      child: authService.userPhoto == null 
                          ? const Icon(Icons.person, size: 50, color: Colors.white) 
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authService.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Pune, Maharashtra",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Member since Oct 2023",
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildFarmDetailsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2E1C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFarmRow(Icons.landscape_outlined, "Total Land Area", "5.2 Hectares", Colors.brown),
          const Divider(height: 32, thickness: 0.5),
          _buildFarmRow(Icons.eco_outlined, "Primary Crops", "Wheat, Sugarcane", Colors.green),
          const Divider(height: 32, thickness: 0.5),
          _buildFarmRow(Icons.layers_outlined, "Soil Type", "Alluvial / Black", Colors.orange),
          const Divider(height: 32, thickness: 0.5),
          _buildFarmRow(Icons.water_drop_outlined, "Irrigation Type", "Drip System", Colors.blue),
          const Divider(height: 32, thickness: 0.5),
          _buildFarmRow(Icons.grass_outlined, "Farming Type", "Organic Certified", Colors.teal),
        ],
      ),
    );
  }

  Widget _buildFarmRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ],
    );
  }

  Widget _buildInsightsRow() {
    return Row(
      children: [
        _buildInsightItem("Predicted Yield", "14.2 T", Icons.auto_graph, Colors.green),
        const SizedBox(width: 12),
        _buildInsightItem("Govt Schemes", "3 Active", Icons.account_balance, Colors.red),
        const SizedBox(width: 12),
        _buildInsightItem("Weather Alerts", "2 Today", Icons.warning_amber_rounded, Colors.orange),
      ],
    );
  }

  Widget _buildInsightItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(bool isDark) {
    return Column(
      children: [
        _buildCollapsibleTile(Icons.history, "AI Conversations History", isDark),
        const SizedBox(height: 12),
        _buildCollapsibleTile(Icons.bookmark_outline, "Saved Govt Schemes", isDark),
        const SizedBox(height: 12),
        _buildCollapsibleTile(Icons.storefront_outlined, "Marketplace Listings", isDark),
      ],
    );
  }

  Widget _buildCollapsibleTile(IconData icon, String title, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2E1C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.add_circle_outline, size: 20, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  Widget _buildPreferencesCard(ThemeService themeService, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2E1C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.translate, color: Colors.blue),
            title: const Text("Language", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            trailing: const Text("English", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.straighten, color: Colors.orange),
            title: const Text("Units", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            trailing: const Text("Hectare", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            onTap: () {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined, color: Colors.purple),
            title: const Text("Dark Mode", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            value: themeService.isDarkMode,
            activeColor: Colors.green,
            onChanged: (val) => themeService.toggleTheme(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, AuthService authService, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2E1C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildActionRow(Icons.person_outline, "Edit Profile", Colors.green),
          _buildActionRow(Icons.lock_outline, "Change Password", Colors.grey),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String title, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}
