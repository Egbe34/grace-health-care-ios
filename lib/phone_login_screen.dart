import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'complete_phone_profile_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();

  String? _verificationId;
  bool _codeSent = false;
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  String? _normalizePhoneNumber(String input) {
    String value = input.trim();

    // Remove spaces, dashes, brackets
    value = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Already international format
    if (value.startsWith('+') && value.length >= 10) {
      return value;
    }

    // Cameroon local format: 6XXXXXXXX
    if (value.length == 9 && value.startsWith('6')) {
      return '+237$value';
    }

    // Cameroon format with leading zero: 06XXXXXXXX
    if (value.length == 10 && value.startsWith('0')) {
      return '+237${value.substring(1)}';
    }

    // Cameroon typed as 237XXXXXXXXX without +
    if (value.startsWith('237') && value.length == 12) {
      return '+$value';
    }

    return null;
  }

  Future<void> _sendOtp() async {
    final raw = _phoneCtrl.text.trim();

    if (raw.isEmpty) {
      _show("Please enter your phone number");
      return;
    }

    final phoneNumber = _normalizePhoneNumber(raw);

    if (phoneNumber == null) {
      _show("Enter a valid phone number. Example: +237674975175");
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            await _goToCompleteProfile(phoneNumber);
          } on FirebaseAuthException catch (e) {
            if (!mounted) return;
            setState(() => _loading = false);
            _show(e.message ?? "Auto verification failed");
          } catch (e) {
            if (!mounted) return;
            setState(() => _loading = false);
            _show("Auto verification failed");
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _loading = false);

          String msg = e.message ?? "Verification failed";

          if (e.code == "invalid-phone-number") {
            msg = "Invalid phone number";
          } else if (e.code == "too-many-requests") {
            msg = "Too many attempts. Please try again later.";
          } else if (e.code == "quota-exceeded") {
            msg = "SMS quota exceeded. Try again later.";
          } else if (e.code == "app-not-authorized") {
            msg = "App is not authorized for phone authentication.";
          } else if (e.code == "captcha-check-failed") {
            msg = "Security check failed. Try again.";
          }

          _show(msg);
        },

        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _loading = false;
          });
          _show("OTP sent successfully");
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _show("Failed to send OTP");
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpCtrl.text.trim();

    if (_verificationId == null) {
      _show("Send OTP first");
      return;
    }

    if (code.length != 6) {
      _show("Enter the 6-digit OTP code");
      return;
    }

    setState(() => _loading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final normalizedPhone =
          _normalizePhoneNumber(_phoneCtrl.text.trim()) ?? _phoneCtrl.text.trim();

      await _goToCompleteProfile(normalizedPhone);
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? "OTP verification failed";

      if (e.code == "invalid-verification-code") {
        msg = "Invalid OTP code";
      } else if (e.code == "session-expired") {
        msg = "Code expired. Please request a new OTP.";
      }

      _show(msg);
    } catch (e) {
      _show("OTP verification failed");
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _goToCompleteProfile(String fallbackPhone) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final phone = user.phoneNumber ?? fallbackPhone;

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => CompletePhoneProfileScreen(
          phoneNumber: phone,
        ),
      ),
          (route) => false,
    );
  }

  void _resetFlow() {
    setState(() {
      _codeSent = false;
      _verificationId = null;
      _otpCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1E5ED8);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text("Phone Login"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E5ED8), Color(0xFF0F4CC9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                    color: Colors.black.withOpacity(0.10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.phone_iphone, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Login with your phone",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Enter your phone number and verify with OTP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    enabled: !_codeSent && !_loading,
                    decoration: InputDecoration(
                      labelText: "Phone number",
                      hintText: "+237674975175",
                      helperText: "You can also type 674975175",
                      prefixIcon: const Icon(Icons.phone_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_codeSent)
                    TextField(
                      controller: _otpCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        labelText: "OTP code",
                        hintText: "123456",
                        prefixIcon: const Icon(Icons.lock_outline),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(),
                    ),
                  if (!_loading && !_codeSent)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _sendOtp,
                        child: const Text(
                          "Send OTP",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  if (!_loading && _codeSent) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _verifyOtp,
                        child: const Text(
                          "Verify OTP",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _resetFlow,
                            child: const Text("Change number"),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: _sendOtp,
                            child: const Text("Resend code"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "After OTP verification, the user will complete name and profile before entering the app.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
