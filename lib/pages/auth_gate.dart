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

        if (authSnap.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Auth error:\n${authSnap.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Not logged in
        if (!authSnap.hasData) {
          return const AuthChoiceScreen();
        }

        final uid = authSnap.data!.uid;

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
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
                    'Failed to load profile.\n${userSnap.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!userSnap.hasData || !userSnap.data!.exists) {
              return const TownSelectionScreen();
            }

            final data = userSnap.data!.data();

            if (data == null) {
              return const TownSelectionScreen();
            }

            final town = (data['town'] ?? '').toString().trim();

            // If town missing -> go to town selection
            if (town.isEmpty) {
              return const TownSelectionScreen();
            }

            // Town exists -> go to Home
            return const GHCMainNav();
          },
        );
      },
    );
  }
}