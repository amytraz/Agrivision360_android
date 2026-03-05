class FertilizerInfo {
  final String name;
  final String type; // Organic, Inorganic
  final String npkRatio;
  final String bestFor;
  final String applicationMethod;

  FertilizerInfo({
    required this.name,
    required this.type,
    required this.npkRatio,
    required this.bestFor,
    required this.applicationMethod,
  });
}

final List<FertilizerInfo> commonFertilizers = [
  FertilizerInfo(
    name: "Urea",
    type: "Inorganic",
    npkRatio: "46-0-0",
    bestFor: "Nitrogen boost, leafy growth",
    applicationMethod: "Broadcasting or top dressing",
  ),
  FertilizerInfo(
    name: "DAP (Diammonium Phosphate)",
    type: "Inorganic",
    npkRatio: "18-46-0",
    bestFor: "Root development, early growth",
    applicationMethod: "Basal application at sowing",
  ),
  FertilizerInfo(
    name: "MOP (Muriate of Potash)",
    type: "Inorganic",
    npkRatio: "0-0-60",
    bestFor: "Fruit quality, disease resistance",
    applicationMethod: "Basal or top dressing",
  ),
  FertilizerInfo(
    name: "Vermicompost",
    type: "Organic",
    npkRatio: "2-1-1 (approx)",
    bestFor: "Soil health, long-term fertility",
    applicationMethod: "Soil mixing or mulching",
  ),
  FertilizerInfo(
    name: "Neem Cake",
    type: "Organic",
    npkRatio: "5-1-1",
    bestFor: "Pest control + Nitrogen",
    applicationMethod: "Soil incorporation",
  ),
];
