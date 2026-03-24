import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ghc_constants.dart';
import 'booking_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final String serviceId;
  const ServiceDetailsScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('services').doc(serviceId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GHC.primary,
        title: const Text("Service Details"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: ref.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final name = (data['name'] ?? 'Service').toString();
          final category = (data['category'] ?? '').toString();
          final description = (data['description'] ?? '').toString();
          final active = (data['active'] ?? true) == true;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(label: Text(category.isEmpty ? "service" : category)),
                    const SizedBox(width: 10),
                    Chip(
                      label: Text(active ? "Active" : "Inactive"),
                      backgroundColor: active
                          ? Colors.green.withOpacity(0.12)
                          : Colors.red.withOpacity(0.12),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(description.isEmpty ? "No description yet." : description),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GHC.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text("Book this Service"),
                    onPressed: active
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingScreen(prefillServiceId: serviceId),
                        ),
                      );
                    }
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}