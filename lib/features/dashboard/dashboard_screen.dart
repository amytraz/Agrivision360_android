import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/weather_overview_card.dart';
import 'widgets/tool_grid.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Size size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;
    final double horizontalPadding = isTablet ? 40 : 20;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0A1F0B), const Color(0xFF050F05)]
                : [const Color(0xFFF5F7F3), Colors.white],
          ),
        ),
        child: Stack(
          children: [
            // Scrollable Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 120), // Top padding for sticky header

                  // 1. Weather Insight Section
                  const WeatherOverviewCard(),
                  
                  const SizedBox(height: 32),

                  // 2. Central Hub Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Farm Command Center",
                          style: TextStyle(
                            fontSize: isTablet ? 26 : 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // 3. Grouped Modular Tool Sections
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                    child: const ToolGrid(),
                  ),

                  const SizedBox(height: 32),

                  // 4. Intelligent Analytics Overview
                  _buildInteractiveYieldAnalytics(context, isTablet),

                  const SizedBox(height: 140), // Bottom padding for Nav Bar
                ],
              ),
            ),

            // Sticky Header (Floating Glassmorphism)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: DashboardHeader(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveYieldAnalytics(BuildContext context, bool isTablet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double horizontalPadding = isTablet ? 40 : 20;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Seasonal Performance",
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B2E1C) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: isTablet ? 250 : 180,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 3),
                            FlSpot(2.6, 2),
                            FlSpot(4.9, 5),
                            FlSpot(6.8, 3.1),
                            FlSpot(8, 4),
                            FlSpot(9.5, 3),
                            FlSpot(11, 4),
                          ],
                          isCurved: true,
                          color: Colors.greenAccent,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.greenAccent.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric("Soil Moisture", "68%", Icons.water_drop, Colors.blue, isTablet),
                    _buildMetric("Growth Rate", "+12%", Icons.trending_up, Colors.green, isTablet),
                    _buildMetric("NPK Level", "Optimal", Icons.science, Colors.orange, isTablet),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Your farm is performing 12% better than the local average this month.",
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color, bool isTablet) {
    return Column(
      children: [
        Icon(icon, color: color, size: isTablet ? 32 : 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: isTablet ? 22 : 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: isTablet ? 12 : 10, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
