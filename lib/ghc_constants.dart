import 'package:flutter/material.dart';

class GHC {
  // App main color (same look you already have)
  static const Color primary = Color(0xFF1E66F5);

  // ✅ Replace with your real WhatsApp number (include country code, no +, no spaces)
  // Example Cameroon: 2376XXXXXXXX
  static const String whatsappNumber = "237600000000";

  static String bookingWhatsAppText({
    required String email,
    required String serviceName,
    required String bookingId,
  }) {
    return "Hello Grace Health Care 👋\n"
        "I just booked: $serviceName\n"
        "Booking ID: $bookingId\n"
        "Email: $email\n"
        "Please assist me with consultation.";
  }
}