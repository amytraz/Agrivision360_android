class GovtScheme {
  final String id;
  final String title;
  final String description;
  final String country; // India, Nepal, or Global
  final String region; // Specific state or "All"
  final String websiteUrl;
  final String icon;

  GovtScheme({
    required this.id,
    required this.title,
    required this.description,
    required this.country,
    required this.region,
    required this.websiteUrl,
    this.icon = "https://cdn-icons-png.flaticon.com/512/2830/2830312.png",
  });
}

final List<GovtScheme> mockSchemes = [
  // India
  GovtScheme(
    id: "1",
    title: "PM-KISAN Samman Nidhi",
    description: "Income support of ₹6,000 per year in three installments to all landholding farmer families.",
    country: "India",
    region: "All",
    websiteUrl: "https://pmkisan.gov.in/",
  ),
  GovtScheme(
    id: "2",
    title: "Pradhan Mantri Fasal Bima Yojana (PMFBY)",
    description: "Crop insurance scheme to provide financial support to farmers suffering from crop loss/damage.",
    country: "India",
    region: "All",
    websiteUrl: "https://pmfby.gov.in/",
  ),
  GovtScheme(
    id: "3",
    title: "Soil Health Card Scheme",
    description: "Helps farmers to know the nutrient status of their soil and receive dosage recommendations.",
    country: "India",
    region: "All",
    websiteUrl: "https://www.soilhealth.dac.gov.in/",
  ),
  // Nepal
  GovtScheme(
    id: "4",
    title: "PM Agriculture Modernization Project (PMAMP)",
    description: "A project aimed at making Nepal self-reliant in agriculture by increasing productivity and modernization.",
    country: "Nepal",
    region: "All",
    websiteUrl: "https://pmamp.gov.np/",
  ),
  GovtScheme(
    id: "5",
    title: "Agriculture Development Strategy (ADS)",
    description: "A 20-year strategy to guide the development of the agriculture sector in Nepal.",
    country: "Nepal",
    region: "All",
    websiteUrl: "https://moald.gov.np/",
  ),
  GovtScheme(
    id: "6",
    title: "Subsidy on Fertilizers & Seeds",
    description: "Government provided subsidies for improved seeds and essential fertilizers.",
    country: "Nepal",
    region: "All",
    websiteUrl: "https://moald.gov.np/",
  ),
];
