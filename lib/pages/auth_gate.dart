import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_choice_screen.dart';
import '../ghc_main_nav.dart';
import '../town_selection_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Not logged in
        if (!authSnap.hasData) {
          return const AuthChoiceScreen();
        }

        final uid = authSnap.data!.uid;

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnap.hasError) {
              return Scaffold(
                body: Center(
                  child: Text(
                    "Failed to load profile.\n${userSnap.error}",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final data = userSnap.data?.data();
            final town = (data?['town'] ?? '').toString().trim();

            // ✅ If doc missing OR town missing → go to town selection
            if (!userSnap.hasData || !userSnap.data!.exists || town.isEmpty) {
              return TownSelectionScreen();
            }

            // ✅ Town exists → go to Home
            return GHCMainNav();
          },
        );
      },
    );
  }
}