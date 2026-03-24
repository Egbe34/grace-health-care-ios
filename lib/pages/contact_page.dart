import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  static const String _callNumberPrimary = '+237651398440';
  static const String _callNumberSecondary = '+237672999619';
  static const String _whatsAppNumber = '+237682526180';
  static const String _email = 'info@gracehealthcare.cm';

  Future<void> _openPhone(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open link"),
        ),
      );
    }
  }

  Future<void> _openWhatsApp() async {
    final clean = _whatsAppNumber.replaceAll('+', '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openEmail() async {
    final uri = Uri.parse('mailto:$_email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _contactTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: Icon(icon, size: 28, color: const Color(0xFF1E5ED8)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
            ),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text("Contact"),
        backgroundColor: const Color(0xFF1E5ED8),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _contactTile(
            context: context,
            icon: Icons.call_outlined,
            title: "Call",
            subtitle: "+237 651 398 440",
            onTap: () => _openPhone(_callNumberPrimary),
          ),
          _contactTile(
            context: context,
            icon: Icons.phone_outlined,
            title: "Phone",
            subtitle: "+237 672 999 619",
            onTap: () => _openPhone(_callNumberSecondary),
          ),
          _contactTile(
            context: context,
            icon: Icons.chat_outlined,
            title: "WhatsApp",
            subtitle: "+237 682 526 180",
            onTap: _openWhatsApp,
          ),
          _contactTile(
            context: context,
            icon: Icons.email_outlined,
            title: "Email",
            subtitle: _email,
            onTap: _openEmail,
          ),
          const SizedBox(height: 25),

          const Text(
            "Follow Grace Health Care",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 10),

          _contactTile(
            context: context,
            icon: Icons.facebook,
            title: "Facebook",
            subtitle: "Grace Healthcare GHC",
            onTap: () => _openLink(
                context,
                "https://facebook.com/gracehealthcare.ghc"),
          ),

          _contactTile(
            context: context,
            icon: Icons.camera_alt,
            title: "Instagram",
            subtitle: "@gracehealthcare_ghc",
            onTap: () => _openLink(
                context,
                "https://instagram.com/gracehealthcare_ghc"),
          ),
          const SizedBox(height: 8),
          const Text(
            "Business Hours: Mon–Sat | 8am–6pm",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}