import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../ghc_constants.dart';

class AdminBookingsScreen extends StatelessWidget {
  const AdminBookingsScreen({super.key});

  String _statusLabel(String status) {
    switch (status) {
      case "waiting_payment":
        return "Waiting Payment";
      case "confirmed":
        return "Payment Confirmed";
      case "completed":
        return "Completed";
      case "cancelled":
        return "Cancelled";
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "waiting_payment":
        return Colors.orange;
      case "confirmed":
        return Colors.green;
      case "completed":
        return Colors.blue;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateBooking(
      BuildContext context,
      String bookingId,
      Map<String, dynamic> data,
      ) async {
    try {
      await FirebaseFirestore.instance.collection("bookings").doc(bookingId).update(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking updated ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsStream = FirebaseFirestore.instance
        .collection("bookings")
        .orderBy("createdAt", descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: GHC.primary,
        title: const Text("Admin Bookings"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingsStream,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No bookings yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i];
              final data = (d.data() as Map<String, dynamic>);

              final serviceName = (data["serviceName"] ?? "-").toString();
              final cityId = (data["cityId"] ?? "-").toString();
              final date = (data["appointmentDate"] ?? "-").toString();
              final time = (data["appointmentTime"] ?? "-").toString();

              final status = (data["status"] ?? "waiting_payment").toString();
              final paymentStatus = (data["paymentStatus"] ?? "unpaid").toString();

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Booking ID: ${d.id}",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text("Service: $serviceName"),
                      Text("City: $cityId"),
                      Text("Date: $date   Time: $time"),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Chip(
                            label: Text(_statusLabel(status)),
                            backgroundColor: _statusColor(status).withOpacity(0.15),
                            labelStyle: TextStyle(color: _statusColor(status)),
                          ),
                          const SizedBox(width: 10),
                          Chip(
                            label: Text(paymentStatus == "paid" ? "Paid" : "Unpaid"),
                            backgroundColor: paymentStatus == "paid"
                                ? Colors.green.withOpacity(0.15)
                                : Colors.orange.withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: paymentStatus == "paid" ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 20),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: (paymentStatus == "paid")
                                ? null
                                : () => _updateBooking(context, d.id, {
                              "paymentStatus": "paid",
                              "status": "confirmed",
                              "paidAt": FieldValue.serverTimestamp(),
                            }),
                            child: const Text("Confirm Payment"),
                          ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                            onPressed: (status == "completed" || status == "cancelled")
                                ? null
                                : () => _updateBooking(context, d.id, {
                              "status": "completed",
                              "completedAt": FieldValue.serverTimestamp(),
                            }),
                            child: const Text("Mark Completed"),
                          ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: (status == "cancelled" || status == "completed")
                                ? null
                                : () => _updateBooking(context, d.id, {
                              "status": "cancelled",
                              "cancelledAt": FieldValue.serverTimestamp(),
                            }),
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}