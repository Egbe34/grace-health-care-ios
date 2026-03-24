import 'package:flutter/material.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pricing")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            _PriceCard(title: "Telemedicine Consultation", price: "Coming soon"),
            _PriceCard(title: "Home Visit", price: "Coming soon"),
            _PriceCard(title: "Lab Test Booking", price: "Coming soon"),
            SizedBox(height: 12),
            Text("You will send the real prices later ✅", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String title;
  final String price;
  const _PriceCard({required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}