import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'doctor_dashboard_screen.dart';
import 'subscription_plans_screen.dart';
import 'pages/admin_bookings_screen.dart';

import 'pages/support_page.dart';
import 'pages/about_ghc_page.dart';
import 'pages/privacy_security_page.dart';
import 'pages/contact_page.dart';
import 'pages/reviews_page.dart';
import 'pages/terms_of_service_page.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  bool _isAdminEmail(String? email) {
    final e = (email ?? '').toLowerCase().trim();
    return e == "ekema1234@gmail.com" || e == "egbe1234@gmail.com";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F8FC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF1E5ED8),
          foregroundColor: Colors.white,
          title: const Text("Profile"),
        ),
        body: const Center(
          child: Text("Not logged in"),
        ),
      );
    }

    final name = user.displayName?.trim();
    final email = user.email?.trim() ?? "No email";
    final phone = user.phoneNumber?.trim();
    final initials = _initialsFromName(name ?? email);
    final isAdmin = _isAdminEmail(user.email);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E5ED8),
        foregroundColor: Colors.white,
        title: const Text("Profile"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _headerCard(
            initials: initials,
            name: name,
            email: email,
            phone: phone,
          ),

          const SizedBox(height: 12),

          _subscriptionStatusCard(context, user.uid),

          const SizedBox(height: 18),

          _sectionTitle("Account"),
          const SizedBox(height: 10),

          _tile(
            context,
            icon: Icons.language_outlined,
            title: "Language",
            subtitle: "English • Français",
            onTap: () => _showLanguageDialog(context),
          ),

          _tile(
            context,
            icon: Icons.lock_outline,
            title: "Privacy & Security",
            subtitle: "Password, permissions, and protection",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacySecurityPage()),
              );
            },
          ),

          _tile(
            context,
            icon: Icons.gavel_outlined,
            title: "Terms of Service",
            subtitle: "Read terms and conditions",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsOfServicePage()),
              );
            },
          ),

          if (isAdmin)
            _tile(
              context,
              icon: Icons.admin_panel_settings_outlined,
              title: "Admin Panel",
              subtitle: "Confirm / Complete bookings",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminBookingsScreen()),
                );
              },
            ),

          if (isAdmin)
            _tile(
              context,
              icon: Icons.medical_services_outlined,
              title: "Doctor Dashboard",
              subtitle: "Activate or deactivate doctors",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DoctorDashboardScreen(),
                  ),
                );
              },
            ),

          _tile(
            context,
            icon: Icons.workspace_premium_outlined,
            title: "Subscription Plans",
            subtitle: "Basic • Family • Premium",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubscriptionPlansScreen(),
                ),
              );
            },
          ),

          _tile(
            context,
            icon: Icons.help_outline,
            title: "Support",
            subtitle: "Chat or contact GHC",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportPage()),
              );
            },
          ),

          _tile(
            context,
            icon: Icons.info_outline,
            title: "About Grace Health Care",
            subtitle: "Learn about our services",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutGhcPage()),
              );
            },
          ),

          _tile(
            context,
            icon: Icons.contact_phone_outlined,
            title: "Contact",
            subtitle: "Phone, WhatsApp, Email",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactPage()),
              );
            },
          ),

          _tile(
            context,
            icon: Icons.star_outline,
            title: "Reviews",
            subtitle: "What patients say",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReviewsPage()),
              );
            },
          ),

          const SizedBox(height: 18),

          _sectionTitle("Actions"),
          const SizedBox(height: 10),

          _actionTile(
            context,
            icon: Icons.delete_outline,
            iconColor: const Color(0xFFEF4444),
            title: "Delete My Account",
            subtitle: "Permanently remove your profile and account",
            onTap: () => _showDeleteAccountDialog(context),
          ),

          _actionTile(
            context,
            icon: Icons.logout,
            iconColor: const Color(0xFFEF4444),
            title: "Log out",
            subtitle: "Sign out from this device",
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }

  static Future<void> _showLanguageDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Language",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Icon(Icons.language, color: Color(0xFF1E5ED8)),
                title: const Text("English"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("English selected"),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.language, color: Color(0xFF1E5ED8)),
                title: const Text("Français"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Français selected"),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Delete My Account",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            "Are you sure you want to delete your account?\n\n"
                "This will permanently remove your profile and associated data from Grace Health Care.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete Account"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final uid = user.uid;

      await firestore.collection('users').doc(uid).delete().catchError((_) {});
      await firestore.collection('subscriptions').doc(uid).delete().catchError((_) {});

      final bookings = await firestore
          .collection('bookings')
          .where('userId', isEqualTo: uid)
          .get();

      for (final doc in bookings.docs) {
        await doc.reference.delete().catchError((_) {});
      }

      await user.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully")),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? "Could not delete account";

      if (e.code == 'requires-recent-login') {
        msg = "Please log in again before deleting your account.";
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: $e")),
        );
      }
    }
  }

  static Widget _subscriptionStatusCard(BuildContext context, String userId) {
    final ref =
    FirebaseFirestore.instance.collection("subscriptions").doc(userId);

    return StreamBuilder<DocumentSnapshot>(
      stream: ref.snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return _subscriptionBox(
            context,
            title: "Subscription",
            subtitle: "Error loading subscription",
            badgeText: "ERROR",
            badgeColor: const Color(0xFFEF4444),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubscriptionPlansScreen(),
                ),
              );
            },
          );
        }

        if (snap.connectionState == ConnectionState.waiting) {
          return _subscriptionBox(
            context,
            title: "Subscription",
            subtitle: "Loading...",
            badgeText: "LOADING",
            badgeColor: const Color(0xFF64748B),
            onTap: () {},
            disabled: true,
          );
        }

        if (!snap.hasData || !snap.data!.exists) {
          return _subscriptionBox(
            context,
            title: "Subscription",
            subtitle: "No subscription yet",
            badgeText: "NONE",
            badgeColor: const Color(0xFF64748B),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubscriptionPlansScreen(),
                ),
              );
            },
            actionLabel: "Choose a Plan",
          );
        }

        final data = (snap.data!.data() as Map<String, dynamic>?) ?? {};
        final planName = (data["planName"] ?? "Unknown Plan").toString();
        final priceLabel = (data["priceLabel"] ?? "").toString();
        final billingCycle = (data["billingCycle"] ?? "").toString();
        final status = (data["status"] ?? "pending").toString().toLowerCase();

        final badge = _statusBadge(status);

        final subParts = <String>[];
        if (priceLabel.isNotEmpty) subParts.add(priceLabel);
        if (billingCycle.isNotEmpty) subParts.add(billingCycle);
        if (status == "pending") {
          subParts.add("Awaiting payment confirmation");
        }

        final subtitle =
        subParts.isEmpty ? "Tap to manage" : subParts.join(" • ");

        return _subscriptionBox(
          context,
          title: planName,
          subtitle: subtitle,
          badgeText: badge.$1,
          badgeColor: badge.$2,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SubscriptionPlansScreen(),
              ),
            );
          },
          actionLabel: "Manage Subscription",
        );
      },
    );
  }

  static (String, Color) _statusBadge(String status) {
    switch (status) {
      case "active":
        return ("ACTIVE", const Color(0xFF22C55E));
      case "cancelled":
      case "canceled":
        return ("CANCELLED", const Color(0xFFEF4444));
      case "expired":
        return ("EXPIRED", const Color(0xFFF59E0B));
      default:
        return ("PENDING", const Color(0xFF1E5ED8));
    }
  }

  static Widget _subscriptionBox(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String badgeText,
        required Color badgeColor,
        required VoidCallback onTap,
        String? actionLabel,
        bool disabled = false,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: disabled ? null : onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.workspace_premium, color: badgeColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5ED8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: disabled ? null : onTap,
                  child: Text(actionLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _headerCard({
    required String initials,
    required String? name,
    required String email,
    required String? phone,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0x1A1E5ED8),
            child: Text(
              initials,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Color(0xFF1E5ED8),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (name != null && name.isNotEmpty) ? name : "GHC Patient",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                if (phone != null && phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
      ),
    );
  }

  static Widget _tile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0x1A1E5ED8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1E5ED8)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  static Widget _actionTile(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  static String _initialsFromName(String text) {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return "GH";

    final parts = cleaned
        .split(RegExp(r"\s+"))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    final first = parts.first.substring(0, 1).toUpperCase();
    final last = parts.last.substring(0, 1).toUpperCase();
    return "$first$last";
  }
}