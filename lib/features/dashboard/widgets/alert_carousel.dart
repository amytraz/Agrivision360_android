import 'package:flutter/material.dart';

class AlertCarousel extends StatelessWidget {
  const AlertCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: PageView(
        children: const [
          AlertCard(
            title: "Heavy Rain Alert",
            subtitle: "Expected in next 24 hours",
          ),
          AlertCard(
            title: "Market Price Spike",
            subtitle: "Wheat price increased 12%",
          ),
        ],
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const AlertCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle),
        ],
      ),
    );
  }
}
