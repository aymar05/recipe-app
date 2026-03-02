import 'package:flutter/material.dart';
import 'package:recipe_app/config/theme.dart'; // Import des design tokens (kPrimary, kAccent…)
import 'package:recipe_app/screens/account/home_screen.dart';
import 'package:recipe_app/screens/account/search_screen.dart';
import 'package:recipe_app/screens/account/profile_screen.dart';
import 'package:recipe_app/screens/account/favorites_screen.dart';
import 'package:recipe_app/screens/account/proposals/user_proposals_screen.dart';

// ──────────────────────────────────────────────────────────
// RootScreen — Navigation principale 5 onglets
// LOGIQUE INCHANGÉE : _currentIndex, pages, onTap identiques
// SEUL LE RENDU VISUEL est modifié (BottomNavigationBar premium)
// ──────────────────────────────────────────────────────────

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  // ── LOGIQUE MÉTIER INCHANGÉE ──────────────────────────
  int _currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),          // Index 0
    SearchScreen(),        // Index 1
    UserProposalsScreen(), // Index 2 — Central
    FavoritesScreen(),     // Index 3
    ProfileScreen(),       // Index 4
  ];
  // ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea gérée par chaque écran enfant via son Scaffold/SliverAppBar
      body: pages[_currentIndex],

      // ── BottomNavigationBar Premium ──────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kSurface,
          // Ombre douce vers le haut — effet de "flottement"
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          // Angles supérieurs arrondis pour un look premium
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: kSurface,
            selectedItemColor: kPrimary,
            unselectedItemColor: kTextSecondary,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            elevation: 0,

            // ── Labels avec style typographique Outfit ──
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
            ),

            items: [
              // ── Accueil ───────────────────────────────
              BottomNavigationBarItem(
                icon: _NavIcon(
                  icon: Icons.home_outlined,
                  isActive: _currentIndex == 0,
                ),
                activeIcon: _NavIcon(
                  icon: Icons.home_rounded,
                  isActive: true,
                ),
                label: 'Accueil',
              ),

              // ── Recherche ────────────────────────────
              BottomNavigationBarItem(
                icon: _NavIcon(
                  icon: Icons.search_rounded,
                  isActive: _currentIndex == 1,
                ),
                activeIcon: _NavIcon(
                  icon: Icons.search_rounded,
                  isActive: true,
                ),
                label: 'Recherche',
              ),

              // ── Proposer (central, accent orange) ────
              BottomNavigationBarItem(
                icon: _CentralNavIcon(isActive: _currentIndex == 2),
                activeIcon: _CentralNavIcon(isActive: true),
                label: 'Proposer',
              ),

              // ── Favoris ──────────────────────────────
              BottomNavigationBarItem(
                icon: _NavIcon(
                  icon: Icons.favorite_outline_rounded,
                  isActive: _currentIndex == 3,
                ),
                activeIcon: _NavIcon(
                  icon: Icons.favorite_rounded,
                  isActive: true,
                ),
                label: 'Favoris',
              ),

              // ── Profil ───────────────────────────────
              BottomNavigationBarItem(
                icon: _NavIcon(
                  icon: Icons.person_outline_rounded,
                  isActive: _currentIndex == 4,
                ),
                activeIcon: _NavIcon(
                  icon: Icons.person_rounded,
                  isActive: true,
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Sous-widget : Icône de navigation standard avec indicateur
// ──────────────────────────────────────────────────────────
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const _NavIcon({required this.icon, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        // Pastille verte derrière l'icône quand actif
        color: isActive ? kPrimaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 24,
        color: isActive ? kPrimary : kTextSecondary,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Sous-widget : Icône centrale "Proposer" — cercle orange
// ──────────────────────────────────────────────────────────
class _CentralNavIcon extends StatelessWidget {
  final bool isActive;

  const _CentralNavIcon({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        // Dégradé orange → orange chaud pour le bouton central
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isActive
              ? [kAccent, const Color(0xFFE55A00)]
              : [kAccent.withOpacity(0.85), const Color(0xFFE55A00).withOpacity(0.85)],
        ),
        shape: BoxShape.circle,
        // Ombre orange subtile
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: kAccent.withOpacity(0.40),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: const Icon(
        Icons.add_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}