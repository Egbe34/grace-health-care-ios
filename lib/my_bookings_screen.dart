import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ghc_constants.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final Map<String, String> _lastSeenStatus = {};

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: GHC.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Bookings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: user == null
          ? const Center(
        child: Text("Not logged in"),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorBox(message: snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const _EmptyState();
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            for (final d in docs) {
              final data = (d.data() as Map<String, dynamic>?) ?? {};
              final bookingId = d.id;
              final status =
              (data['status'] ?? 'pending').toString().toLowerCase();

              final old = _lastSeenStatus[bookingId];
              if (old == null) {
                _lastSeenStatus[bookingId] = status;
                continue;
              }

              if (old != status) {
                _lastSeenStatus[bookingId] = status;

                if (status == "confirmed") {
                  _showSnack("✅ Your booking was confirmed!");
                } else if (status == "completed") {
                  _showSnack("✅ Your appointment is completed!");
                } else if (status == "cancelled") {
                  _showSnack("❌ Your booking was cancelled.");
                }
              }
            }
          });

          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = (doc.data() as Map<String, dynamic>?) ?? {};

                final service =
                (data['serviceName'] ?? "Service").toString();

                final DateTime? appointmentDate =
                _parseDateTime(data['appointmentDate']);

                String formattedDate = "Not scheduled";
                if (appointmentDate != null) {
                  formattedDate =
                  "${appointmentDate.day.toString().padLeft(2, '0')}/"
                      "${appointmentDate.month.toString().padLeft(2, '0')}/"
                      "${appointmentDate.year}";
                }

                final time = (data['appointmentTime'] ?? '').toString();
                final status = (data['status'] ?? "pending").toString();

                return _BookingCard(
                  service: service,
                  date: formattedDate,
                  time: time,
                  status: status,
                );
              },
            ),
          );
        },
      ),
    );
  }

  DateTime? _parseDateTime(dynamic value) {
    try {
      if (value == null) return null;

      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }

      if (value is String) {
        final v = value.trim();
        if (v.isEmpty) return null;

        final parsed = DateTime.tryParse(v);
        if (parsed != null) return parsed;

        final parts = v.split('/');
        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            return DateTime(year, month, day);
          }
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final String service;
  final String date;
  final String time;
  final String status;

  const _BookingCard({
    required this.service,
    required this.date,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          builder: (_) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text("Date: $date"),
                  const SizedBox(height: 6),
                  Text("Time: $time"),
                  const SizedBox(height: 6),
                  Text("Status: ${status.toUpperCase()}"),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: GHC.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.calendar_month, color: GHC.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    service,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                _StatusBadge(status: status, color: statusColor),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.date_range, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(date),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(time.isEmpty ? "-" : time),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "confirmed":
        return Colors.green;
      case "completed":
        return Colors.blue;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 70, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              "No bookings yet",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Your booked appointments will appear here.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;

  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}