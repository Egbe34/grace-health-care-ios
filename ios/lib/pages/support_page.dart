import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  static const String whatsapp = "+237651398440"; // TODO update later
  static const String phone = "+237682526180"; // TODO update later

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Support")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: const Text("WhatsApp Support"),
                subtitle: const Text(whatsapp),
                onTap: () => _open("https://wa.me/$whatsapp"),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.call_outlined),
                title: const Text("Call Support"),
                subtitle: const Text(phone),
                onTap: () => _open("tel:$phone"),
              ),
            ),
            const SizedBox(height: 12),
            const Text("You’ll send support numbers later ✅", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}