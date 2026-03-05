import 'package:flutter/material.dart';
import '../../core/services/groq_service.dart';
import 'models/disease_model.dart';

class DiseaseDetailScreen extends StatefulWidget {
  final CropDisease disease;
  const DiseaseDetailScreen({super.key, required this.disease});

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> {
  String? _aiTreatmentPlan;
  bool _isLoadingAi = false;
  final GroqService _groqService = GroqService();

  @override
  void initState() {
    super.initState();
    _fetchAiTreatment();
  }

  Future<void> _fetchAiTreatment() async {
    setState(() => _isLoadingAi = true);
    try {
      final prompt = "Generate a detailed treatment plan for the crop disease: ${widget.disease.name}. "
          "Affected crops are ${widget.disease.cropAffected}. Provide actionable steps for a farmer.";
      final response = await _groqService.sendMessageToGroq(prompt);
      if (mounted) {
        setState(() {
          _aiTreatmentPlan = response;
          _isLoadingAi = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiTreatmentPlan = "Failed to load AI treatment plan. Please check your connection.";
          _isLoadingAi = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1F0B) : const Color(0xFFF5F7F3),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.disease.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              background: Image.network(
                widget.disease.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined, size: 64, color: Colors.grey),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Crop Affected", Icons.agriculture),
                  Text(widget.disease.cropAffected, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  
                  _buildSectionHeader("Symptoms", Icons.bug_report_outlined),
                  Text(widget.disease.symptoms, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 20),
                  
                  _buildSectionHeader("Prevention", Icons.shield_outlined),
                  Text(widget.disease.prevention, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 32),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text(
                              "AI Recommended Treatment",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isLoadingAi)
                          const Center(child: CircularProgressIndicator(color: Colors.green))
                        else
                          Text(
                            _aiTreatmentPlan ?? "Generating treatment plan...",
                            style: const TextStyle(fontSize: 15, height: 1.6),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
