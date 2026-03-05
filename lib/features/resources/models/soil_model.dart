class SoilType {
  final String id;
  final String name;
  final String description;
  final List<String> suitableCrops;
  final String characteristics;
  final String managementTips;
  final String imageUrl;
  final String color; // For UI accenting

  SoilType({
    required this.id,
    required this.name,
    required this.description,
    required this.suitableCrops,
    required this.characteristics,
    required this.managementTips,
    required this.imageUrl,
    required this.color,
  });
}

final List<SoilType> mockSoilTypes = [
  SoilType(
    id: "1",
    name: "Alluvial Soil",
    description: "The most fertile and widespread soil found in the river basins and plains.",
    suitableCrops: ["Wheat", "Rice", "Sugar cane", "Cotton", "Jute"],
    characteristics: "Rich in potash and lime but poor in nitrogen and phosphorous. Fine-grained and highly fertile.",
    managementTips: "Responds well to irrigation and fertilizers. Crop rotation is recommended to maintain nutrient levels.",
    imageUrl: "https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&q=80&w=500",
    color: "0xFF8D6E63",
  ),
  SoilType(
    id: "2",
    name: "Black Soil (Regur)",
    description: "Deep, clayey soil that is ideal for cotton cultivation.",
    suitableCrops: ["Cotton", "Soybean", "Wheat", "Linseed", "Castor"],
    characteristics: "High clay content, develops deep cracks during dry season. Highly moisture-retentive.",
    managementTips: "Requires careful drainage management during heavy rains. Avoid over-tilling when wet.",
    imageUrl: "https://images.unsplash.com/photo-1464226184884-fa280b87c399?auto=format&fit=crop&q=80&w=500",
    color: "0xFF212121",
  ),
  SoilType(
    id: "3",
    name: "Red Soil",
    description: "Formed by weathering of crystalline and metamorphic rocks.",
    suitableCrops: ["Pulses", "Millets", "Tobacco", "Oilseeds", "Potatoes"],
    characteristics: "Reddish color due to iron diffusion. Generally porous and friable. Low in nitrogen and humus.",
    managementTips: "Needs regular application of fertilizers and organic manure. Best with supplemental irrigation.",
    imageUrl: "https://images.unsplash.com/photo-1524486361537-8ad15938e1a3?auto=format&fit=crop&q=80&w=500",
    color: "0xFFD84315",
  ),
  SoilType(
    id: "4",
    name: "Laterite Soil",
    description: "Found in tropical regions with high rainfall and high temperature.",
    suitableCrops: ["Cashew nuts", "Tea", "Coffee", "Rubber", "Coconut"],
    characteristics: "Rich in iron and aluminum. Highly leached, acidic, and low in organic matter.",
    managementTips: "Requires heavy manuring and fertilizer application. Ideal for plantation crops after proper treatment.",
    imageUrl: "https://images.unsplash.com/photo-1596436889106-be35e843f974?auto=format&fit=crop&q=80&w=500",
    color: "0xFFBF360C",
  ),
];
