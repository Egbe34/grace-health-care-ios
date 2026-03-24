import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ghc_constants.dart';
import 'support_chat_screen.dart';

class SupportChatListScreen extends StatelessWidget {
  const SupportChatListScreen({super.key});

  // ✅ Your support/admin UID
  static const String supportUid = "CPFZGUQqGJPx7CgOhNNl60ZKT933";

  bool _isSupport(User? user) => user != null && user.uid == supportUid;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (!_isSupport(user)) {
      return Scaffold(
        appBar: AppBar(backgroundColor: GHC.primary, title: const Text("Support Chats")),
        body: const Center(child: Text("Access denied (support only)")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: GHC.primary,
        title: const Text("Support: Chats"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text("Error: ${snap.error}"));
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text("No chats yet"));

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;

              final patientUid = (data['patientUid'] ?? doc.id).toString();
              final patientEmail = (data['patientEmail'] ?? 'Patient').toString();
              final lastMessage = (data['lastMessage'] ?? '').toString();

              String timeText = "";
              final ts = data['updatedAt'];
              if (ts is Timestamp) {
                final d = ts.toDate();
                timeText = "${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: ListTile(
                  title: Text(
                    patientEmail,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(lastMessage.isEmpty ? "No messages yet" : lastMessage),
                  trailing: Text(timeText, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SupportChatScreen(
                          chatId: doc.id,
                          patientUid: patientUid,
                          patientEmail: patientEmail,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}