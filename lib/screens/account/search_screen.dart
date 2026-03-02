import 'package:flutter/material.dart';
import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/screens/account/search_by_recipe_screen.dart';
import 'package:recipe_app/screens/account/search_by_ingredient_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SearchScreen — Refonte UI v2
// ⚠️  ZÉRO MODIFICATION LOGIQUE : PageController, _currentIndex, PageView children
// Changement : fond blanc propre au lieu du fond image avec overlay sombre
// ──────────────────────────────────────────────────────────────────────────────

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // ── LOGIQUE INCHANGÉE ──────────────────────────────────────────────────────
  final int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      // PageView en plein écran — fond propre blanc/gris clair
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // navigation par onglets gérée autre part
        children: const [
          SearchByRecipeScreen(),
          SearchByIngredientScreen(),
        ],
      ),
    );
  }
}
