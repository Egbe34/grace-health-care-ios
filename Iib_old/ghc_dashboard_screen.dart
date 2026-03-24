import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'pages/booking_screen.dart';
import 'ghc_constants.dart';
import 'my_bookings_screen.dart';
import 'service_details_screen.dart';

class GHCDashboardScreen extends StatelessWidget {
  const GHCDashboardScreen({super.key});

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    final isFrench = Localizations.localeOf(context).languageCode == "fr";
    final user = FirebaseAuth.instance.currentUser;

    final menuMyBookings = isFrench ? "Mes réservations" : "My Bookings";
    final menuLogout = isFrench ? "Déconnexion" : "Logout";
    final defaultPatient = "Patient";
    final unknownEmail = isFrench ? "inconnu@email.com" : "unknown@email.com";
    final servicesTitle = "Services";

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: _buildTopBar(
          context: context,
          isFrench: isFrench,
          menuMyBookings: menuMyBookings,
          menuLogout: menuLogout,
        ),
        body: Center(
          child: Text(
            isFrench ? "Utilisateur non connecté" : "Not logged in",
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: _buildTopBar(
        context: context,
        isFrench: isFrench,
        menuMyBookings: menuMyBookings,
        menuLogout: menuLogout,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadProfile(),
        builder: (context, snap) {
          final profile = snap.data;

          final fullName = (profile?['fullName'] ??
              profile?['name'] ??
              user.displayName ??
              defaultPatient)
              .toString();

          final email =
          (profile?['email'] ?? user.email ?? unknownEmail).toString();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
            children: [
              _PremiumWelcomeHeader(
                fullName: fullName,
                email: email,
              ),
              const SizedBox(height: 16),
              _QuickActions(
                onBook: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingScreen()),
                  );
                },
                onMyBookings: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 18),
              Text(
                servicesTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              const _ServicesGrid(),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildTopBar({
    required BuildContext context,
    required bool isFrench,
    required String menuMyBookings,
    required String menuLogout,
  }) {
    return AppBar(
      backgroundColor: GHC.primary,
      foregroundColor: Colors.white,
      surfaceTintColor: GHC.primary,
      elevation: 0,
      toolbarHeight: 84,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 12, right: 4),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/logo_image.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Grace Health Care",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isFrench
                        ? "Des soins de santé fiables à votre porte"
                        : "Trusted Healthcare at Your Doorstep",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFD7F5DE),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.white, size: 30),
          onSelected: (value) async {
            if (value == "bookings") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
              );
            } else if (value == "logout") {
              await _logout();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: "bookings",
              child: Row(
                children: [
                  const Icon(Icons.receipt_long),
                  const SizedBox(width: 10),
                  Text(menuMyBookings),
                ],
              ),
            ),
            PopupMenuItem(
              value: "logout",
              child: Row(
                children: [
                  const Icon(Icons.logout),
                  const SizedBox(width: 10),
                  Text(menuLogout),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _SupportChatButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SupportChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isFrench = Localizations.localeOf(context).languageCode == "fr";
    final buttonText =
    isFrench ? "Discuter avec le support" : "Chat with Support";

    return Container(
      margin: const EdgeInsets.only(top: 0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E5ED8),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.chat_bubble_outline),
        label: Text(
          buttonText,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: onTap,
      ),
    );
  }
}

class _PremiumWelcomeHeader extends StatelessWidget {
  final String fullName;
  final String email;

  const _PremiumWelcomeHeader({
    required this.fullName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final isFrench = Localizations.localeOf(context).languageCode == "fr";

    final welcomeText =
    isFrench ? "Bienvenue, $fullName 👋" : "Welcome, $fullName 👋";
    final subtitle = isFrench
        ? "Prenez rendez-vous, suivez vos demandes et discutez avec le support."
        : "Book appointments, track your requests, and chat with support.";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GHC.primary,
            GHC.primary.withOpacity(0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: const Icon(Icons.health_and_safety, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  welcomeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.90),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onBook;
  final VoidCallback onMyBookings;

  const _QuickActions({
    required this.onBook,
    required this.onMyBookings,
  });

  @override
  Widget build(BuildContext context) {
    final isFrench = Localizations.localeOf(context).languageCode == "fr";

    final bookNow = isFrench ? "Réserver" : "Book Now";
    final newAppointment = isFrench ? "Nouveau rendez-vous" : "New appointment";
    final myBookings = isFrench ? "Mes réservations" : "My Bookings";
    final trackStatus = isFrench ? "Suivre le statut" : "Track status";

    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            title: bookNow,
            subtitle: newAppointment,
            icon: Icons.calendar_month,
            onTap: onBook,
            filled: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            title: myBookings,
            subtitle: trackStatus,
            icon: Icons.receipt_long,
            onTap: onMyBookings,
            filled: false,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? GHC.primary : Colors.white;
    final fg = filled ? Colors.white : Colors.black87;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: filled ? Colors.transparent : Colors.black12,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(filled ? 0.12 : 0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: filled
                    ? Colors.white.withOpacity(0.20)
                    : GHC.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: filled ? Colors.white : GHC.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: fg, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: fg.withOpacity(0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: fg.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();

  @override
  Widget build(BuildContext context) {
    final isFrench = Localizations.localeOf(context).languageCode == "fr";

    final stream = FirebaseFirestore.instance
        .collection('services')
        .where('active', isEqualTo: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return _ErrorBox(
            message: isFrench
                ? "Impossible de charger les services : ${snap.error}"
                : "Failed to load services: ${snap.error}",
          );
        }

        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return _ErrorBox(
            message: isFrench
                ? "Aucun service actif trouvé.\nVeuillez ajouter des services dans Firestore."
                : "No active services found.\nPlease add services in Firestore.",
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.82,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? 'Service').toString();
            final category = (data['category'] ?? 'consultation').toString();

            return _ServiceCard(
              name: name,
              category: category,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailsScreen(serviceId: doc.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String name;
  final String category;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.name,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFrench = Localizations.localeOf(context).languageCode == "fr";
    final icon = _iconForCategory(category);

    final activeText = isFrench ? "Actif" : "Active";
    final openText = isFrench ? "Ouvrir" : "Open";

    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.10),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: GHC.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: GHC.primary),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      activeText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: GHC.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  openText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains("tele")) return Icons.video_call;
    if (c.contains("home")) return Icons.home;
    if (c.contains("lab")) return Icons.science;
    if (c.contains("cosmetic")) return Icons.health_and_safety;
    if (c.contains("consult")) return Icons.medical_services;
    if (c.contains("pharmacy")) return Icons.local_pharmacy;
    return Icons.local_hospital;
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Text(message),
    );
  }
}
