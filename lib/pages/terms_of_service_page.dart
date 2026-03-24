import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  static const String _websiteUrl = 'https://ghc-healthcare.com/terms-of-service';
  static const String _privacyUrl = 'https://ghc-healthcare.com/privacy-policy';
  static const String _medicalUrl = 'https://ghc-healthcare.com/medical-disclaimer';
  static const String _supportEmail = 'info@ghc-healthcare.com';

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link')),
      );
    }
  }

  Future<void> _openEmail(BuildContext context) async {
    final uri = Uri.parse('mailto:$_supportEmail');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: const Color(0xFF1E5ED8),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Terms of Service for Grace Health Care (GHC)',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'By using the Grace Health Care mobile application, website, and related services, you agree to these Terms of Service. Please read them carefully before using the platform.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: '1. Purpose of the platform',
            body:
            'Grace Health Care (GHC) is a healthcare access platform that helps users connect with available healthcare services such as doctor consultations, appointment bookings, laboratory requests, pharmacy support, and other related healthcare coordination services. GHC is designed to improve access to healthcare information and support, but it does not replace emergency medical care, hospital treatment, or direct clinical judgment by a licensed healthcare professional.',
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: '2. User responsibilities',
            body:
            'By using GHC, you agree to provide accurate information when creating an account, booking a service, or communicating through the platform. You agree not to misuse the app, submit false medical or personal information, impersonate another person, or use the service for unlawful or harmful purposes.',
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: '3. Medical disclaimer',
            body:
            'Grace Health Care does not guarantee diagnosis, treatment outcomes, or medical results. Medical advice, prescriptions, laboratory requests, and healthcare decisions must come from qualified licensed professionals. Users should not use the app as a replacement for emergency services. In any serious or urgent medical situation, you should seek immediate in-person medical help.',
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: '4. Bookings and appointments',
            body:
            'Users may book appointments and healthcare-related services through the app. GHC works to make healthcare access easier, but appointment availability may depend on doctor schedules, service location, timing, confirmation status, and operational conditions. A booking request submitted through the app does not always mean the service is fully completed until confirmed by the relevant provider or process.',
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: '5. Payments and fees',
            body:
            'Some services listed on GHC may include consultation fees, service charges, or related healthcare costs. Users are responsible for reviewing service details before confirming a booking. Where payments apply, users must ensure payment is made through approved methods communicated by Grace Health Care or the relevant service process.',
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: '6. Proper use of healthcare information',
            body:
            'Users agree not to self-medicate irresponsibly based on assumptions or incomplete information. GHC encourages responsible healthcare decisions, including consultation with licensed doctors, laboratory testing when necessary, use of prescribed treatment, and proper follow-up. Information presented on the platform is intended to support healthcare access, not to encourage unsafe treatment practices.',
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: '7. Privacy and data handling',
            body:
            'Your use of GHC is also subject to our Privacy Policy. By using the platform, you understand that certain personal information may be collected and used to provide bookings, account support, communication, and service coordination. Grace Health Care works to handle user data responsibly and securely.',
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: '8. Account access and security',
            body:
            'You are responsible for protecting access to your account, including your phone number, email, password, and verification codes. If you believe your account has been accessed without permission, you should contact GHC support as soon as possible.',
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: '9. Service availability',
            body:
            'Grace Health Care may update, improve, suspend, or modify parts of the app or website at any time in order to improve services, maintain safety, or comply with operational or legal requirements. Some features may not always be available in every town, region, or at every moment.',
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: '10. Limitation of liability',
            body:
            'To the extent allowed by law, Grace Health Care is not liable for indirect loss, delay, misunderstanding, appointment unavailability, third-party provider actions, or consequences resulting from misuse of the platform. Users remain responsible for making informed healthcare decisions together with licensed professionals.',
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: '11. Changes to these terms',
            body:
            'Grace Health Care may update these Terms of Service from time to time. Continued use of the platform after updates means you accept the revised terms.',
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: '12. Contact',
            body:
            'If you have questions about these Terms of Service, you may contact Grace Health Care through our official support channels.',
          ),
          const SizedBox(height: 14),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Useful links',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E5ED8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _openLink(context, _websiteUrl),
                    icon: const Icon(Icons.language),
                    label: const Text(
                      'Open Website',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E5ED8),
                      side: const BorderSide(color: Color(0xFF1E5ED8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _openLink(context, _privacyUrl),
                    icon: const Icon(Icons.privacy_tip_outlined),
                    label: const Text(
                      'Open Privacy Policy',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E5ED8),
                      side: const BorderSide(color: Color(0xFF1E5ED8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _openLink(context, _medicalUrl),
                    icon: const Icon(Icons.medical_information_outlined),
                    label: const Text(
                      'Medical Disclaimer',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E5ED8),
                      side: const BorderSide(color: Color(0xFF1E5ED8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _openEmail(context),
                    icon: const Icon(Icons.email_outlined),
                    label: const Text(
                      'Contact Support',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Website: https://ghc-healthcare.com/',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Support: info@ghc-healthcare.com',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionCard({
    required String title,
    required String body,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: child,
    );
  }
}