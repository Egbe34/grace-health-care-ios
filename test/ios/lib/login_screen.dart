import 'auth_gate.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'l10n/app_localizations.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  String _localizedAuthError(BuildContext context, FirebaseAuthException e) {
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    final code = e.code.toLowerCase();

    switch (code) {
      case 'invalid-email':
        return isFrench ? 'Adresse e-mail invalide' : 'Invalid email address';
      case 'user-disabled':
        return isFrench
            ? 'Ce compte a été désactivé'
            : 'This account has been disabled';
      case 'user-not-found':
        return isFrench
            ? 'Aucun compte trouvé avec cet e-mail'
            : 'No account found with this email';
      case 'wrong-password':
      case 'invalid-credential':
        return isFrench
            ? 'E-mail ou mot de passe incorrect'
            : 'Incorrect email or password';
      case 'too-many-requests':
        return isFrench
            ? 'Trop de tentatives. Veuillez réessayer plus tard'
            : 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return isFrench
            ? 'Erreur réseau. Vérifiez votre connexion internet'
            : 'Network error. Check your internet connection';
      default:
        return e.message ?? (isFrench ? 'Échec de la connexion' : 'Login failed');
    }
  }

  Future<void> _login() async {
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';

    FocusScope.of(context).unfocus();

    if (_email.text.trim().isEmpty || _password.text.trim().isEmpty) {
      _showMsg(
        isFrench
            ? 'Veuillez entrer votre e-mail et votre mot de passe'
            : 'Please enter your email and password',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      _showMsg(isFrench ? 'Connexion réussie ✅' : 'Login successful ✅');

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showMsg(_localizedAuthError(context, e));
    } catch (e) {
      _showMsg(
        isFrench
            ? 'Une erreur est survenue : $e'
            : 'Something went wrong: $e',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';

    final loginTitle = isFrench ? 'Connexion' : 'Login';
    final welcomeText = isFrench ? 'Bon retour 👋' : 'Welcome back 👋';
    final continueText = isFrench
        ? 'Connectez-vous pour continuer sur Grace Health Care'
        : 'Login to continue to Grace Health Care';
    final emailLabel = isFrench ? 'E-mail' : 'Email';
    final passwordLabel = isFrench ? 'Mot de passe' : 'Password';
    final loginButton = isFrench ? 'Se connecter' : 'Login';
    final createAccountText = isFrench
        ? "Vous n'avez pas de compte ? Créez-en un"
        : "Don't have an account? Create one";
    final enterEmailPassword = isFrench
        ? 'Veuillez entrer votre e-mail et votre mot de passe'
        : 'Please enter your email and password';
    final showPassword =
    isFrench ? 'Afficher le mot de passe' : 'Show password';
    final hidePassword =
    isFrench ? 'Masquer le mot de passe' : 'Hide password';

    return Scaffold(
      appBar: AppBar(
        title: Text(loginTitle),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),

              const Align(
                alignment: Alignment.topRight,
                child: LanguageSwitcherChip(),
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  welcomeText,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(continueText),
              ),
              const SizedBox(height: 18),

              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: emailLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _password,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: passwordLabel,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword ? showPassword : hidePassword,
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _loading
                      ? null
                      : () {
                    if (_email.text.trim().isEmpty ||
                        _password.text.trim().isEmpty) {
                      _showMsg(enterEmailPassword);
                      return;
                    }
                    _login();
                  },
                  child: _loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(loginButton),
                ),
              ),

              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                child: Text(createAccountText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageSwitcherChip extends StatelessWidget {
  const LanguageSwitcherChip({super.key});

  @override
  Widget build(BuildContext context) {
    final currentCode = Localizations.localeOf(context).languageCode;
    final isFrench = currentCode == 'fr';

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'en') {
          GHCApp.setLocale(context, const Locale('en'));
        } else if (value == 'fr') {
          GHCApp.setLocale(context, const Locale('fr'));
        }
      },
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              Text('🇺🇸', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text('English'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'fr',
          child: Row(
            children: [
              Text('🇫🇷', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text('Français'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isFrench ? '🇫🇷' : '🇺🇸',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              isFrench ? 'FR' : 'EN',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Color(0xFF1F2937),
            ),
          ],
        ),
      ),
    );
  }
}