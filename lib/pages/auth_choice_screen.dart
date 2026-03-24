import 'package:flutter/material.dart';

import '../login_screen.dart';
import '../main.dart';
import '../phone_login_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  static const Color ghcBlue = Color(0xFF0B4AA2);

  void _showTermsDialog(BuildContext context, bool isFrench) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isFrench ? 'Conditions d’utilisation' : 'Terms of Service'),
        content: SingleChildScrollView(
          child: Text(
            isFrench
                ? 'En utilisant Grace Health Care, vous acceptez d’utiliser l’application de manière responsable. Les consultations, réservations et autres services proposés via la plateforme sont soumis à disponibilité. Grace Health Care peut mettre à jour ou modifier les services à tout moment.'
                : 'By using Grace Health Care, you agree to use the app responsibly. Consultations, bookings, and other services offered through the platform are subject to availability. Grace Health Care may update or modify services at any time.',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isFrench ? 'Fermer' : 'Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context, bool isFrench) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isFrench ? 'Politique de confidentialité' : 'Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            isFrench
                ? 'Grace Health Care peut collecter des informations telles que votre nom, e-mail, téléphone et données de réservation afin de fournir ses services. Vos données sont protégées et utilisées uniquement pour le fonctionnement de la plateforme et l’amélioration de l’expérience utilisateur.'
                : 'Grace Health Care may collect information such as your name, email, phone number, and booking data in order to provide its services. Your data is protected and used only for platform operation and improving user experience.',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isFrench ? 'Fermer' : 'Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';

    final loginTitle = isFrench ? 'Connexion' : 'Login';
    final welcomeTitle = isFrench
        ? 'Bienvenue chez Grace Health Care'
        : 'Welcome to Grace Health Care';
    final subtitle = isFrench
        ? 'Réservez facilement des consultations, visites à domicile et tests de laboratoire.'
        : 'Book consultations, home visits, and lab tests easily.';
    final continueWithPhone =
    isFrench ? 'Continuer avec le téléphone' : 'Continue with Phone';
    final continueWithEmail =
    isFrench ? 'Continuer avec l’e-mail' : 'Continue with Email';
    final needHelp = isFrench ? 'Besoin d’aide ? Chat' : 'Need Help? Chat';
    final encrypted = isFrench ? 'Données cryptées' : 'Data Encrypted';
    final termsText = isFrench ? 'Conditions d’utilisation' : 'Terms of Service';
    final privacyText =
    isFrench ? 'Politique de confidentialité' : 'Privacy Policy';

    return Scaffold(
      appBar: AppBar(
        title: Text(loginTitle),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: LanguageSwitcherChip()),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Text(
                welcomeTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.phone),
                  label: Text(continueWithPhone),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhoneLoginScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.email),
                  label: Text(continueWithEmail),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Card(
                    elevation: 6,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/login_image.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.chat, size: 18, color: ghcBlue),
                      const SizedBox(width: 6),
                      Text(
                        needHelp,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        encrypted,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showTermsDialog(context, isFrench),
                    child: Text(
                      termsText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Text(
                    ' | ',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () => _showPrivacyDialog(context, isFrench),
                    child: Text(
                      privacyText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
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
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';

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