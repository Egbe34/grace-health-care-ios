import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/auth_gate.dart';

import 'login_screen.dart';
import 'user_profile_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> handleSignup() async {
    final isFrench = Localizations.localeOf(context).languageCode == "fr";

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      _showMsg(isFrench
          ? "Veuillez remplir tous les champs"
          : "Please fill all fields");
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await UserProfileService().createUserProfile(
        name: name,
        phone: phone,
        email: email,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String msg = isFrench ? "Échec de l'inscription" : "Signup failed";

      if (e.code == "email-already-in-use") {
        msg = isFrench
            ? "Cet e-mail est déjà utilisé"
            : "Email already in use";
      }

      if (e.code == "weak-password") {
        msg = isFrench
            ? "Mot de passe trop faible"
            : "Password is too weak";
      }

      if (e.code == "invalid-email") {
        msg = isFrench
            ? "Adresse e-mail invalide"
            : "Invalid email";
      }

      _showMsg(msg);
    } catch (e) {
      _showMsg(isFrench
          ? "Échec de l'inscription"
          : "Signup failed");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = Localizations.localeOf(context).languageCode == "fr";

    final title = isFrench ? "Créer un compte" : "Create Account";
    final header = isFrench ? "Créer votre compte" : "Create your account";
    final subtitle = isFrench
        ? "Rejoignez Grace Health Care en quelques minutes"
        : "Join Grace Health Care in minutes";

    final fullName = isFrench ? "Nom complet" : "Full Name";
    final phone = isFrench ? "Numéro de téléphone" : "Phone Number";
    final email = isFrench ? "E-mail" : "Email";
    final password = isFrench ? "Mot de passe" : "Password";

    final createAccount =
    isFrench ? "Créer un compte" : "Create Account";

    final loginInstead = isFrench
        ? "Vous avez déjà un compte ? Connexion"
        : "Already have an account? Login";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 8),

            Text(
              header,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(subtitle),

            const SizedBox(height: 24),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: fullName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: phone,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: email,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: passwordController,
              obscureText: hidePassword,
              decoration: InputDecoration(
                labelText: password,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : handleSignup,
                child: isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : Text(createAccount),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              child: Text(loginInstead),
            ),
          ],
        ),
      ),
    );
  }
}