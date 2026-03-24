import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingReceivedScreen extends StatelessWidget {
  final String bookingId;
  final String cityId; // IMPORTANT: should be the Firestore doc id like "buea"
  final String fullName;
  final String serviceName;
  final String date;
  final String time;
  final num fee; // <-- NEW

  const BookingReceivedScreen({
    super.key,
    required this.bookingId,
    required this.cityId,
    required this.fullName,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.fee,
  });

  // Convert "Buea" -> "buea", "Yaounde " -> "yaounde"
  String _cityKey(String input) => input.trim().toLowerCase();

  // Remove + and spaces for wa.me
  String _sanitizePhone(String phone) {
    return phone.replaceAll("+", "").replaceAll(" ", "").trim();
  }

  Future<Map<String, dynamic>?> _loadSupport(String cityId) async {
    // Try doc id directly (normalized)
    final doc = await FirebaseFirestore.instance
        .collection("support_numbers")
        .doc(_cityKey(cityId))
        .get();

    if (doc.exists) return doc.data();

    // Fallback: maybe they passed cityName instead of docId
    final q = await FirebaseFirestore.instance
        .collection("support_numbers")
        .where("cityName", isEqualTo: cityId)
        .limit(1)
        .get();

    if (q.docs.isEmpty) return null;
    return q.docs.first.data();
  }

  Future<void> _openWhatsApp({
    required String phone,
    required String message,
  }) async {
    final p = _sanitizePhone(phone);
    final text = Uri.encodeComponent(message);

    final url = Uri.parse("https://wa.me/$p?text=$text");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw "Could not open WhatsApp";
    }
  }

  Future<void> _callNumber(String phone) async {
    final url = Uri.parse("tel:$phone");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5ED8),
        title: const Text("Booking Received"),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadSupport(cityId),
        builder: (context, snap) {
          final support = snap.data;

          final whatsapp = (support?["whatsapp"] ?? "").toString();
          final call = (support?["call"] ?? "").toString();
          final cityName = (support?["cityName"] ?? cityId).toString();

          // Common booking summary
          final bookingSummary = """
Booking ID: $bookingId
Name: $fullName
Service: $serviceName
City: $cityName
Date: $date
Time: $time
Fee: ${fee.toString()} XAF
""";

          final msgMtn = """
Hello GHC Support,

I just booked an appointment and I want to pay using MTN Mobile Money.

$bookingSummary

Please send me payment instructions. Thank you.
""";

          final msgOrange = """
Hello GHC Support,

I just booked an appointment and I want to pay using Orange Money.

$bookingSummary

Please send me payment instructions. Thank you.
""";

          final msgHelp = """
Hello GHC Support,

I just booked an appointment.

$bookingSummary

Please assist me with completing the payment. Thank you.
""";

          final canTap = whatsapp.isNotEmpty; // buttons enabled only if support whatsapp exists

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "✅ Booking Received",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("Booking ID: $bookingId",
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text("Service: $serviceName"),
                      Text("City: $cityName"),
                      Text("Date: $date  •  Time: $time"),

                      const SizedBox(height: 14),
                      const Divider(),

                      const SizedBox(height: 10),
                      const Text(
                        "Confirm Your Appointment",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "To secure your consultation with the doctor, please complete the consultation payment.",
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.75),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Consultation Fee: ${fee.toString()} XAF",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Appointments are only confirmed after payment.",
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // MTN button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5ED8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: !canTap
                      ? null
                      : () async {
                    await _openWhatsApp(phone: whatsapp, message: msgMtn);
                  },
                  child: const Text(
                    "Pay with MTN Mobile Money",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),

                const SizedBox(height: 10),

                // Orange button
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: !canTap
                      ? null
                      : () async {
                    await _openWhatsApp(phone: whatsapp, message: msgOrange);
                  },
                  child: const Text("Pay with Orange Money"),
                ),

                const SizedBox(height: 10),

                // WhatsApp support
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text("Contact Support on WhatsApp"),
                  onPressed: !canTap
                      ? null
                      : () async {
                    await _openWhatsApp(phone: whatsapp, message: msgHelp);
                  },
                ),

                const SizedBox(height: 10),

                // Call support
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.call),
                  label: const Text("Call Support Instead"),
                  onPressed: call.isEmpty ? null : () => _callNumber(call),
                ),

                const SizedBox(height: 12),

                if (!canTap)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Support WhatsApp number is not set for this city yet. Please update Firestore: support_numbers/{cityId} -> whatsapp.",
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