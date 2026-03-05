import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/yield_service.dart';
import '../../core/services/theme_service.dart';

class YieldPredictionScreen extends StatefulWidget {
  const YieldPredictionScreen({super.key});

  @override
  State<YieldPredictionScreen> createState() => _YieldPredictionScreenState();
}

class _YieldPredictionScreenState extends State<YieldPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _cropController = TextEditingController();
  final _varietyController = TextEditingController();
  final _areaController = TextEditingController();
  final _npkController = TextEditingController();
  final _phController = TextEditingController();
  final _managementController = TextEditingController();
  
  String _areaUnit = 'Acres';
  DateTime? _sowingDate;
  String? _selectedSoilType;
  String? _selectedIrrigation;
  
  bool _isLoading = false;
  YieldPrediction? _result;

  final List<String> _crops = [
    'Rice', 'Wheat', 'Maize', 'Cotton', 'Sugarcane', 
    'Soybean', 'Groundnut', 'Mustard', 'Potato', 'Tomato'
  ];

  final List<String> _soilTypes = ['Loamy', 'Sandy', 'Clayey', 'Silt', 'Peaty', 'Saline'];
  final List<String> _irrigationMethods = ['Rain-fed', 'Drip', 'Sprinkler', 'Flood'];

  final YieldService _yieldService = YieldService();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _sowingDate) {
      setState(() {
        _sowingDate = picked;
      });
    }
  }

  Future<void> _calculateYield() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    final prediction = await _yieldService.getYieldEstimate(
      cropType: _cropController.text,
      area: double.parse(_areaController.text),
      areaUnit: _areaUnit,
      cropVariety: _varietyController.text.isEmpty ? null : _varietyController.text,
      sowingDate: _sowingDate,
      soilType: _selectedSoilType,
      npk: _npkController.text.isEmpty ? null : _npkController.text,
      soilPh: double.tryParse(_phController.text),
      irrigationMethod: _selectedIrrigation,
      fertilizerUsage: _managementController.text.isEmpty ? null : _managementController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _result = prediction;
      });
      
      if (prediction == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Analysis failed. Check your internet connection.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeService>(context).isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Yield Predictor AI", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1B5E20), const Color(0xFF0A1F0B), Colors.black]
                : [const Color(0xFF2E7D32), const Color(0xFFF1F8E9), Colors.white],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Crop Details", Icons.grass),
                  _buildCropInputs(isDark),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Location & Land", Icons.landscape),
                  _buildLandInputs(isDark),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Soil Information (Optional)", Icons.layers),
                  _buildSoilInputs(isDark),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Management Practices", Icons.settings_suggest),
                  _buildManagementInputs(isDark),
                  const SizedBox(height: 40),
                  _isLoading
                      ? const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: Colors.greenAccent),
                              SizedBox(height: 16),
                              Text("AI is analyzing local climate & soil data...", 
                                style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                            ],
                          ),
                        )
                      : _buildActionButton(),
                  const SizedBox(height: 32),
                  if (_result != null) ...[
                    _buildResultCard(),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.psychology_outlined, color: Colors.greenAccent, size: 40),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AI Yield Engine", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Smart estimation for higher productivity.", style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Column(
        children: [
          const Text("ESTIMATED PRODUCTION", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text("${_result!.tons}", style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.w900, height: 1)),
              const SizedBox(width: 8),
              const Text("TONS", style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _result!.reasoning,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text("Confidence: ${_result!.confidence.toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildCropInputs(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') return const Iterable<String>.empty();
              return _crops.where((String option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              _cropController.text = selection;
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              _cropController.text = controller.text; // Sync
              controller.addListener(() {
                 _cropController.text = controller.text;
              });
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(
                  labelText: "Crop Type (e.g. Rice, Wheat)",
                  prefixIcon: Icon(Icons.search, color: Colors.green),
                ),
                validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
              );
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _varietyController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: const InputDecoration(
              labelText: "Crop Variety (Optional)",
              hintText: "e.g., Basmati, Hybrid-7",
              prefixIcon: Icon(Icons.info_outline, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandInputs(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _areaController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: const InputDecoration(
                    labelText: "Field Area",
                    prefixIcon: Icon(Icons.straighten, color: Colors.green),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _areaUnit,
                  dropdownColor: isDark ? const Color(0xFF1B2E1C) : Colors.white,
                  items: ['Acres', 'Hectares'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) => setState(() => _areaUnit = v!),
                  decoration: const InputDecoration(labelText: "Unit"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Sowing Date",
                prefixIcon: Icon(Icons.calendar_today, color: Colors.green),
              ),
              child: Text(
                _sowingDate == null ? "Select Date" : DateFormat('yyyy-MM-dd').format(_sowingDate!),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilInputs(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedSoilType,
            hint: const Text("Select Soil Type"),
            dropdownColor: isDark ? const Color(0xFF1B2E1C) : Colors.white,
            items: _soilTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _selectedSoilType = v),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.terrain, color: Colors.green)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _npkController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: const InputDecoration(
              labelText: "Nutrient Levels (NPK)",
              hintText: "e.g., 40:20:20",
              prefixIcon: Icon(Icons.science_outlined, color: Colors.green),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: const InputDecoration(
              labelText: "Soil pH (Optional)",
              hintText: "e.g., 6.5",
              prefixIcon: Icon(Icons.water_drop_outlined, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementInputs(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedIrrigation,
            hint: const Text("Irrigation Method"),
            dropdownColor: isDark ? const Color(0xFF1B2E1C) : Colors.white,
            items: _irrigationMethods.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: (v) => setState(() => _selectedIrrigation = v),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.waves, color: Colors.green)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _managementController,
            maxLines: 2,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: const InputDecoration(
              labelText: "Fertilizer & Pesticide Usage",
              hintText: "Specify amount and timing...",
              prefixIcon: Icon(Icons.edit_note, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)]),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton(
        onPressed: _calculateYield,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: const Text("GENERATE AI PREDICTION", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
      ),
    );
  }
}
