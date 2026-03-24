import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final _nameCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  int _rating = 0;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a star rating ⭐")),
      );
      return;
    }
    if (_msgCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a short review ✍️")),
      );
      return;
    }

    setState(() => _saving = true);

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    await FirebaseFirestore.instance.collection("reviews").add({
      "uid": uid,
      "name": _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      "rating": _rating,
      "message": _msgCtrl.text.trim(),
      "createdAt": FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    setState(() {
      _saving = false;
      _rating = 0;
      _nameCtrl.clear();
      _msgCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thank you! Review submitted ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text("Reviews"),
        backgroundColor: const Color(0xFF1E5ED8),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Leave a review",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),
                _Stars(
                  rating: _rating,
                  onChanged: (v) => setState(() => _rating = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Name (optional)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _msgCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Your review",
                    hintText: "Tell us what you liked and what we can improve…",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E5ED8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text("Submit Review"),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            "Latest reviews",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection("reviews")
                .orderBy("createdAt", descending: true)
                .limit(20)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ));
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return _card(
                  child: const Text(
                    "No reviews yet. Be the first to share feedback ⭐",
                    style: TextStyle(color: Color(0xFF334155)),
                  ),
                );
              }

              return Column(
                children: docs.map((d) {
                  final data = d.data();
                  final name = (data["name"] ?? "Anonymous").toString();
                  final msg = (data["message"] ?? "").toString();
                  final rating = (data["rating"] ?? 0) as int;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                ),
                              ),
                              _Stars.readonly(rating),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(msg, style: const TextStyle(color: Color(0xFF334155), height: 1.35)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
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
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Stars extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onChanged;
  const _Stars({required this.rating, required this.onChanged});

  const _Stars.readonly(this.rating, {super.key}) : onChanged = null;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final star = i + 1;
        final filled = star <= rating;
        return IconButton(
          onPressed: onChanged == null ? null : () => onChanged!(star),
          icon: Icon(filled ? Icons.star : Icons.star_border),
          color: filled ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
        );
      }),
    );
  }
}