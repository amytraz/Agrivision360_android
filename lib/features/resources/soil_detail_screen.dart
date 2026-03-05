import 'package:flutter/material.dart';
import '../../core/services/groq_service.dart';
import 'models/soil_model.dart';

class SoilDetailScreen extends StatefulWidget {
  final SoilType soil;
  const SoilDetailScreen({super.key, required this.soil});

  @override
  State<SoilDetailScreen> createState() => _SoilDetailScreenState();
}

class _SoilDetailScreenState extends State<SoilDetailScreen> {
  String? _aiSoilAdvice;
  bool _isLoadingAi = false;
  final GroqService _groqService = GroqService();

  @override
  void initState() {
    super.initState();
    _fetchAiAdvice();
  }

  Future<void> _fetchAiAdvice() async {
    setState(() => _isLoadingAi = true);
    try {
      final prompt = "Provide specific agricultural advice for ${widget.soil.name}. "
          "The characteristics are: ${widget.soil.characteristics}. "
          "Suitable crops include ${widget.soil.suitableCrops.join(', ')}. "
          "Focus on organic amendments and sustainable yield improvement.";
      final response = await _groqService.sendMessageToGroq(prompt);
      if (mounted) {
        setState(() {
          _aiSoilAdvice = response;
          _isLoadingAi = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiSoilAdvice = "Failed to load AI advice. Please check your connection.";
          _isLoadingAi = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Color(int.parse(widget.soil.color));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1F0B) : const Color(0xFFF5F7F3),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.soil.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.soil.imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Description", Icons.info_outline, accentColor),
                  Text(widget.soil.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),

                  _buildSectionHeader("Key Characteristics", Icons.list_alt, accentColor),
                  Text(widget.soil.characteristics, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),

                  _buildSectionHeader("Suitable Crops", Icons.agriculture, accentColor),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.soil.suitableCrops.map((crop) => Chip(
                      label: Text(crop),
                      backgroundColor: accentColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
                      side: BorderSide(color: accentColor.withOpacity(0.2)),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader("Management Tips", Icons.handyman_outlined, accentColor),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: accentColor.withOpacity(0.3)),
                    ),
                    child: Text(widget.soil.managementTips, style: const TextStyle(fontSize: 16, height: 1.5)),
                  ),
                  const SizedBox(height: 32),

                  // AI Advice Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade800, Colors.green.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "AI Soil Expert Insight",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isLoadingAi)
                          const Center(child: CircularProgressIndicator(color: Colors.white))
                        else
                          Text(
                            _aiSoilAdvice ?? "Analyzing soil data...",
                            style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
          ),
        ],
      ),
    );
  }
}
