class CropDisease {
  final String id;
  final String name;
  final String cropAffected;
  final String symptoms;
  final String prevention;
  final String imageUrl;
  final String category; // e.g., Fungal, Bacterial, Viral

  CropDisease({
    required this.id,
    required this.name,
    required this.cropAffected,
    required this.symptoms,
    required this.prevention,
    required this.imageUrl,
    required this.category,
  });

  factory CropDisease.fromJson(Map<String, dynamic> json) {
    return CropDisease(
      id: json['id'],
      name: json['name'],
      cropAffected: json['crop_affected'],
      symptoms: json['symptoms'],
      prevention: json['prevention'],
      imageUrl: json['image_url'],
      category: json['category'],
    );
  }
}

final List<CropDisease> mockDiseases = [
  CropDisease(
    id: "1",
    name: "Rice Blast (Pyricularia oryzae)",
    cropAffected: "Rice (Dhan)",
    category: "Fungal",
    symptoms: "Diamond or spindle-shaped lesions on leaves with gray centers and brown borders. It can also affect the neck (Neck Blast), causing the panicle to fall over.",
    prevention: "Use resistant varieties. Avoid excessive nitrogen fertilizer. Treat seeds with fungicides like Carbendazim or Tricyclazole.",
    imageUrl: "https://images.unsplash.com/photo-1536633100371-33230a38615b?auto=format&fit=crop&q=80&w=1000",
  ),
  CropDisease(
    id: "2",
    name: "Wheat Stem Rust (Puccinia graminis)",
    cropAffected: "Wheat (Gahun)",
    category: "Fungal",
    symptoms: "Dark reddish-brown pustules (uredinia) on stems and leaf sheaths. These pustules contain a powdery mass of spores that can be rubbed off.",
    prevention: "Plant resistant varieties (e.g., HD 2967, WB 2). Early sowing. Apply fungicides like Propiconazole (Tilt) if symptoms appear early.",
    imageUrl: "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&q=80&w=1000",
  ),
  CropDisease(
    id: "3",
    name: "Potato Late Blight",
    cropAffected: "Potato (Alu), Tomato",
    category: "Fungal",
    symptoms: "Irregular water-soaked spots on leaves that rapidly turn brown or black. In humid weather, white cottony growth appears on the leaf underside.",
    prevention: "Use healthy, certified seed tubers. Maintain proper ridges. Spray contact fungicides like Mancozeb preventively before the rainy season.",
    imageUrl: "https://images.unsplash.com/photo-1592878904946-b3cd8ae243d0?auto=format&fit=crop&q=80&w=1000",
  ),
  CropDisease(
    id: "4",
    name: "Red Rot of Sugarcane",
    cropAffected: "Sugarcane (Ukhu)",
    category: "Fungal",
    symptoms: "The third or fourth leaf starts yellowing at the edges. Internal tissues turn red with distinct white transverse bands. Stalks emit an alcoholic smell.",
    prevention: "Use healthy sets for planting. Treat sets with hot water or fungicides. Practice crop rotation and avoid waterlogging in the field.",
    imageUrl: "https://images.unsplash.com/photo-1596436889106-be35e843f974?auto=format&fit=crop&q=80&w=1000",
  ),
  CropDisease(
    id: "5",
    name: "Citrus Canker",
    cropAffected: "Lemon (Nimbu), Orange, Lime",
    category: "Bacterial",
    symptoms: "Small, raised, corky brown lesions on leaves, twigs, and fruit. Lesions on leaves are often surrounded by a prominent yellow halo.",
    prevention: "Prune and burn infected twigs. Spray Bordeaux mixture or Copper Oxychloride. Manage leaf miners as they spread the bacteria through wounds.",
    imageUrl: "https://images.unsplash.com/photo-1590124230722-dfb8df5b3003?auto=format&fit=crop&q=80&w=1000",
  ),
  CropDisease(
    id: "6",
    name: "Mango Malformation",
    cropAffected: "Mango (Aamp)",
    category: "Fungal/Mite complex",
    symptoms: "Shortened internodes with small, crowded leaves (Vegetative). Floral clusters become heavy, crowded, and green with no fruit set (Floral).",
    prevention: "Prune malformed parts 15-20 cm below the affected area. Spray NAA (Naphthalene Acetic Acid) at 200 ppm in October to reduce incidence.",
    imageUrl: "https://images.unsplash.com/photo-1557844352-761f2565b576?auto=format&fit=crop&q=80&w=1000",
  ),
  CropDisease(
    id: "7",
    name: "Bacterial Leaf Blight (BLB)",
    cropAffected: "Rice (Dhan)",
    category: "Bacterial",
    symptoms: "Yellow to white wavy-edged stripes along the leaf margins, usually starting from the tip. Seedlings may wilt (Kresek) and die.",
    prevention: "Avoid nitrogen overdose. Maintain field sanitation. Use resistant varieties like Samba Mahsuri or IR64. Treat seeds with Streptocycline.",
    imageUrl: "https://images.unsplash.com/photo-1591857177580-dc82b9ac4e17?auto=format&fit=crop&q=80&w=1000",
  ),
  CropDisease(
    id: "8",
    name: "Pigeon Pea Sterility Mosaic",
    cropAffected: "Pigeon Pea (Arhar / Rahari)",
    category: "Viral",
    symptoms: "Light green or yellow mosaic patterns on leaves. Leaves become smaller and plants fail to produce flowers, leading to total sterility.",
    prevention: "Control the eriophyid mite vector by spraying Sulfur or Dicofol. Use resistant varieties like Asha or Maruti. Uproot infected plants early.",
    imageUrl: "https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&q=80&w=1000",
  ),
];
