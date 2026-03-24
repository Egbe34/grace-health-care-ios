import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ghc_constants.dart';

class SupportChatScreen extends StatefulWidget {
  final String chatId; // we use patientUid as chatId
  final String patientUid;
  final String patientEmail;

  const SupportChatScreen({
    super.key,
    required this.chatId,
    required this.patientUid,
    required this.patientEmail,
  });

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  static const String supportUid = "CPFZGUQqGJPx7CgOhNNl60ZKT933";

  final _msgCtrl = TextEditingController();
  bool _sending = false;

  bool get _isSupport => FirebaseAuth.instance.currentUser?.uid == supportUid;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  DocumentReference get _chatRef => FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

  CollectionReference get _messagesRef =>
      FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages');

  Future<void> _ensureChatExists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final chatSnap = await _chatRef.get();
    if (chatSnap.exists) return;

    // If patient opens chat first, create chat doc
    final patientUid = _isSupport ? widget.patientUid : user.uid;
    final patientEmail = _isSupport ? widget.patientEmail : (user.email ?? "");

    await _chatRef.set({
      'type': 'support',
      'patientUid': patientUid,
      'patientEmail': patientEmail,
      'supportUid': supportUid,
      'participants': [patientUid, supportUid],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastSenderId': '',
    }, SetOptions(merge: true));
  }

  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);

    try {
      await _ensureChatExists();

      final senderId = user.uid;
      final receiverId = _isSupport ? widget.patientUid : supportUid;

      final msg = {
        'text': text,
        'senderId': senderId,
        'receiverId': receiverId,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      };

      await _messagesRef.add(msg);

      await _chatRef.set({
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': text,
        'lastSenderId': senderId,
      }, SetOptions(merge: true));

      _msgCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    final title = _isSupport ? widget.patientEmail : "Support Chat";

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: GHC.primary,
        title: Text(title),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesRef.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text("Error: ${snap.error}"));
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final text = (data['text'] ?? '').toString();
                    final senderId = (data['senderId'] ?? '').toString();

                    final mine = senderId == user.uid;

                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: mine ? GHC.primary : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: mine ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // input
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GHC.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _sending ? null : _sendMessage,
                  child: _sending
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}