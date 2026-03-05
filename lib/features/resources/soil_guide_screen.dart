import 'package:flutter/material.dart';
import 'models/soil_model.dart';
import 'soil_detail_screen.dart';

class SoilGuideScreen extends StatefulWidget {
  const SoilGuideScreen({super.key});

  @override
  State<SoilGuideScreen> createState() => _SoilGuideScreenState();
}

class _SoilGuideScreenState extends State<SoilGuideScreen> {
  late List<SoilType> _filteredSoils;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredSoils = mockSoilTypes;
  }

  void _filterSoils(String query) {
    setState(() {
      _filteredSoils = mockSoilTypes
          .where((s) =>
              s.name.toLowerCase().contains(query.toLowerCase()) ||
              s.description.toLowerCase().contains(query.toLowerCase()) ||
              s.suitableCrops.any((c) => c.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1F0B) : const Color(0xFFF5F7F3),
      appBar: AppBar(
        title: const Text("Soil Information Guide", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSoils,
              decoration: InputDecoration(
                hintText: "Search soil types or crops...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredSoils.isEmpty
                ? const Center(child: Text("No soil information found."))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredSoils.length,
                    itemBuilder: (context, index) {
                      final soil = _filteredSoils[index];
                      return _buildSoilCard(context, soil, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilCard(BuildContext context, SoilType soil, bool isDark) {
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
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            soil.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          soil.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              soil.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: soil.suitableCrops.take(3).map((crop) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  crop,
                  style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )).toList(),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SoilDetailScreen(soil: soil),
            ),
          );
        },
      ),
    );
  }
}
