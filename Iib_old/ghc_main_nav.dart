import 'package:flutter/material.dart';

import 'ghc_dashboard_screen.dart';
import 'booking_screen.dart';
import 'my_bookings_screen.dart';
import 'user_profile_screen.dart';

class GHCMainNav extends StatefulWidget {
  const GHCMainNav({super.key});

  @override
  State<GHCMainNav> createState() => _GHCMainNavState();
}

class _GHCMainNavState extends State<GHCMainNav> {
  int _index = 0;

  final List<Widget> _pages = const [
    GHCDashboardScreen(),
    BookingScreen(),
    MyBookingsScreen(),
    UserProfileScreen(),
  ];

  bool get _isFrench => Localizations.localeOf(context).languageCode == "fr";

  @override
  Widget build(BuildContext context) {
    final homeLabel = _isFrench ? "Accueil" : "Home";
    final bookLabel = _isFrench ? "Réserver" : "Book";
    final bookingsLabel = _isFrench ? "Réservations" : "Bookings";
    final profileLabel = _isFrench ? "Profil" : "Profile";

    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                    color: Colors.black.withValues(alpha: 0.12),
                  ),
                ],
              ),
              child: NavigationBar(
                backgroundColor: Colors.white,
                elevation: 0,
                height: 68,
                selectedIndex: _index,
                onDestinationSelected: (i) {
                  setState(() => _index = i);
                },
                indicatorColor: const Color(0x1A1E5ED8),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.dashboard_outlined),
                    selectedIcon: const Icon(Icons.dashboard),
                    label: homeLabel,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.add_circle_outline),
                    selectedIcon: const Icon(Icons.add_circle),
                    label: bookLabel,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.receipt_long_outlined),
                    selectedIcon: const Icon(Icons.receipt_long),
                    label: bookingsLabel,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(Icons.person),
                    label: profileLabel,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}