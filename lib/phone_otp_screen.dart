import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pages/auth_gate.dart';
import 'user_profile_service.dart';

class PhoneOtpScreen extends StatefulWidget {
  final String verificationId;
  final String name;
  final String phone;
  final String email;

  const PhoneOtpScreen({
    super.key,
    required this.verificationId,
    required this.name,
    required this.phone,
    required this.email,
  });

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> verifyOtp() async {
    final isFrench = Localizations.localeOf(context).languageCode == "fr";
    final code = otpController.text.trim();

    if (code.length != 6) {
      _showMsg(
        isFrench ? "Entrez le code à 6 chiffres" : "Enter the 6-digit code",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      await UserProfileService().createUserProfile(
        name: widget.name,
        phone: widget.phone,
        email: widget.email,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String msg =
      isFrench ? "Code invalide ou expiré" : "Invalid or expired code";

      if (e.code == "invalid-verification-code") {
        msg = isFrench ? "Code OTP invalide" : "Invalid OTP code";
      } else if (e.code == "session-expired") {
        msg = isFrench ? "Code expiré" : "Code expired";
      } else if (e.message != null && e.message!.isNotEmpty) {
        msg = e.message!;
      }

      _showMsg(msg);
    } catch (e) {
      _showMsg(
        isFrench ? "Échec de la vérification" : "Verification failed",
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = Localizations.localeOf(context).languageCode == "fr";

    return Scaffold(
      appBar: AppBar(
        title: Text(isFrench ? "Vérifier le téléphone" : "Verify Phone"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            Text(
              isFrench
                  ? "Entrez le code envoyé à ${widget.phone}"
                  : "Enter the code sent to ${widget.phone}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: isFrench ? "Code OTP" : "OTP Code",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : verifyOtp,
                child: isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(isFrench ? "Vérifier" : "Verify"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}