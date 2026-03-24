import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TownSelectionScreen extends StatefulWidget {
  const TownSelectionScreen({super.key});

  @override
  State<TownSelectionScreen> createState() => _TownSelectionScreenState();
}

class _TownSelectionScreenState extends State<TownSelectionScreen> {
  final List<String> towns = const [
    "Douala",
    "Yaoundé",
    "Bafoussam",
    "Bamenda",
    "Garoua",
    "Maroua",
    "Ngaoundéré",
    "Buea",
    "Limbe",
    "Bertoua",
    "Ebolowa",
    "Kribi",
    "Kumba",
    "Mamfe",
  ];

  String? selectedTown;
  bool saving = false;

  Future<void> _saveTown() async {
    if (selectedTown == null) return;

    setState(() => saving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      "uid": user.uid,
      "town": selectedTown,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;
    setState(() => saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Town saved ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select your town")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Choose your town so we can show the right doctors and services.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedTown,
              items: towns
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => selectedTown = v),
              decoration: const InputDecoration(
                labelText: "Town",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: saving ? null : _saveTown,
                child: saving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Continue"),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Image under Continue button
            Expanded(
              child: Center(
                child: Opacity(
                  opacity: 0.95,
                  child: Image.asset(
                    'assets/images/town_image.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}