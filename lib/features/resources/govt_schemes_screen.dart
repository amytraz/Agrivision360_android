import 'package:flutter/material.dart';
import 'models/scheme_model.dart';
// Note: In a real app, you'd add url_launcher to pubspec.yaml
// import 'package:url_launcher/url_launcher.dart';

class GovtSchemesScreen extends StatefulWidget {
  const GovtSchemesScreen({super.key});

  @override
  State<GovtSchemesScreen> createState() => _GovtSchemesScreenState();
}

class _GovtSchemesScreenState extends State<GovtSchemesScreen> {
  String _selectedCountry = "All";
  late List<GovtScheme> _filteredSchemes;

  @override
  void initState() {
    super.initState();
    _filteredSchemes = mockSchemes;
  }

  void _filterSchemes(String country) {
    setState(() {
      _selectedCountry = country;
      if (country == "All") {
        _filteredSchemes = mockSchemes;
      } else {
        _filteredSchemes = mockSchemes.where((s) => s.country == country).toList();
      }
    });
  }

  Future<void> _launchUrl(String url) async {
    // This is a placeholder for url_launcher logic
    // In a real environment, you would use launchUrl(Uri.parse(url))
    debugPrint("Opening scheme website: $url");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Redirecting to: $url")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1F0B) : const Color(0xFFF5F7F3),
      appBar: AppBar(
        title: const Text("Government Schemes", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterChips(isDark),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredSchemes.length,
              itemBuilder: (context, index) {
                return _buildSchemeCard(_filteredSchemes[index], isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final countries = ["All", "India", "Nepal"];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: countries.map((c) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FilterChip(
            label: Text(c),
            selected: _selectedCountry == c,
            onSelected: (_) => _filterSchemes(c),
            selectedColor: Colors.green.withOpacity(0.2),
            checkmarkColor: Colors.green,
            labelStyle: TextStyle(
              color: _selectedCountry == c ? Colors.green : (isDark ? Colors.white70 : Colors.black87),
              fontWeight: _selectedCountry == c ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSchemeCard(GovtScheme scheme, bool isDark) {
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_outlined, color: Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "${scheme.country} • ${scheme.region}",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              scheme.description,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(scheme.websiteUrl),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text("View Details on Official Site"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
