import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'doctors_list_page.dart';

import '../ghc_constants.dart';
import 'booking_received_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedServiceId;
  String? selectedServiceName;

  // NEW
  int? selectedServiceFee;
  String? selectedServiceType;

  String? selectedCityId;

  DateTime? selectedDate;
  String? selectedTime;

  final noteController = TextEditingController();
  bool loading = false;

  final List<String> timeSlots = const [
    "08:00", "08:30", "09:00", "09:30",
    "10:00", "10:30", "11:00", "11:30",
    "13:00", "13:30", "14:00", "14:30",
    "15:00", "15:30", "16:00", "16:30",
  ];

  String _dateString(DateTime d) {
    final dd = d.day.toString().padLeft(2, "0");
    final mm = d.month.toString().padLeft(2, "0");
    final yy = d.year.toString();
    return "$dd/$mm/$yy";
  }

  Future<String> _loadFullName() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return "Patient";

    final doc = await FirebaseFirestore.instance.collection("users").doc(u.uid).get();
    final data = doc.data();
    final name = (data?["fullName"] ?? "Patient").toString();
    return name.isEmpty ? "Patient" : name;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => selectedDate = picked);
  }

  Future<void> _confirmBooking() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;

    if (selectedServiceId == null || selectedServiceName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a service")),
      );
      return;
    }

    // NEW: ensure fee loaded
    if (selectedServiceFee == null || selectedServiceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Service fee not found. Please re-select service.")),
      );
      return;
    }

    if (selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your city")),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date")),
      );
      return;
    }

    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a time")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final fullName = await _loadFullName();
      final dateStr = _dateString(selectedDate!);

      final docRef = await FirebaseFirestore.instance.collection("bookings").add({
        "userId": u.uid,
        "serviceName": selectedServiceName,
        "serviceId": selectedServiceId,
        "serviceType": selectedServiceType, // NEW
        "fee": selectedServiceFee, // NEW
        "currency": "XAF",
        "cityId": selectedCityId,
        "appointmentDate": dateStr,
        "appointmentTime": selectedTime,
        "note": noteController.text.trim(),
        "status": "waiting_payment",
        "paymentStatus": "unpaid",
        "createdAt": FieldValue.serverTimestamp(),
      });

      final bookingId = docRef.id;
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingReceivedScreen(
            bookingId: bookingId,
            cityId: selectedCityId!,
            fullName: fullName,
            serviceName: selectedServiceName!,
            date: dateStr,
            time: selectedTime!,
            fee: selectedServiceFee!,     // NEW
            // NEW
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create booking: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servicesStream = FirebaseFirestore.instance
        .collection("services")
        .where("active", isEqualTo: true)
        .snapshots();

    final citiesStream = FirebaseFirestore.instance
        .collection("support_numbers")
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: GHC.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: GHC.primary,
        elevation: 0,
        title: const Text(
          "Book Appointment",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Service", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),

          StreamBuilder<QuerySnapshot>(
            stream: servicesStream,
            builder: (context, snap) {
              final docs = snap.data?.docs ?? [];

              return DropdownButtonFormField<String>(
                value: selectedServiceId,
                items: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = (data["name"] ?? "Service").toString();
                  return DropdownMenuItem(
                    value: d.id,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id == null) return;
                  final doc = docs.firstWhere((x) => x.id == id);
                  final data = doc.data() as Map<String, dynamic>;

                  setState(() {
                    selectedServiceId = id;
                    selectedServiceName = (data["name"] ?? "Service").toString();

                    // NEW: read fee + type
                    selectedServiceFee = (data["fee"] is int)
                        ? data["fee"] as int
                        : int.tryParse((data["fee"] ?? "0").toString());

                    selectedServiceType = (data["type"] ?? "").toString();
                  });
                },
                decoration: const InputDecoration(
                  hintText: "Select a service",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              );
            },
          ),

          // NEW: show fee preview under service
          if (selectedServiceFee != null) ...[
            const SizedBox(height: 8),
            Text(
              "Consultation Fee: ${selectedServiceFee!} XAF",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],

          const SizedBox(height: 16),
          const Text("City", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: citiesStream,
            builder: (context, snap) {
              final docs = snap.data?.docs ?? [];
              return DropdownButtonFormField<String>(
                value: selectedCityId,
                items: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final cityName = (data["cityName"] ?? d.id).toString();
                  return DropdownMenuItem(
                    value: d.id,
                    child: Text(cityName),
                  );
                }).toList(),
                onChanged: (id) => setState(() => selectedCityId = id),
                decoration: const InputDecoration(
                  hintText: "Select your city",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          const Text("Appointment Date", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month),
                  const SizedBox(width: 10),
                  Text(selectedDate == null ? "Tap to select date" : _dateString(selectedDate!)),
                  const Spacer(),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text("Time Slot", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: timeSlots.map((t) {
              final active = selectedTime == t;
              return ChoiceChip(
                label: Text(t),
                selected: active,
                onSelected: (_) => setState(() => selectedTime = t),
                selectedColor: GHC.primary,
                labelStyle: TextStyle(color: active ? Colors.white : Colors.black87),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          const Text("Note (optional)", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Describe symptoms or request...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 18),
          const SizedBox(height: 20),

          ElevatedButton(
            child: const Text("Find Doctor"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorsListPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GHC.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: loading ? null : _confirmBooking,
            child: loading
                ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Text(
              "Confirm Booking",
              style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}