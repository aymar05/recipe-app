import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/data/result_type.dart';
import 'package:recipe_app/screens/account/search_result_screen.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SearchByRecipeScreen — Refonte UI v2
// ⚠️  ZÉRO MODIFICATION LOGIQUE : _searchController, _formKey, validator,
//     ResultType.recipe, Navigator.push vers SearchResultScreen
// ──────────────────────────────────────────────────────────────────────────────

class SearchByRecipeScreen extends StatefulWidget {
  const SearchByRecipeScreen({super.key});

  @override
  State<SearchByRecipeScreen> createState() => _SearchScreenByIngredientState();
}

class _SearchScreenByIngredientState extends State<SearchByRecipeScreen> {
  // ── LOGIQUE INCHANGÉE ──────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Suggestions de recherche rapide (UI only)
  static const List<String> _suggestions = [
    'Africain', 'Italien', 'Asiatique', 'Rapide', 'Vegetarien', 'Traditionnel',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),

              // ── Titre ─────────────────────────────────────────────────
              Text(
                'Rechercher',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 20),

              // ── Barre de recherche ────────────────────────────────────
              Form(
                key: _formKey,
                child: _SearchBar(
                  controller: _searchController,
                  hintText: 'Rechercher une recette...',
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Veuillez entrer une recette.' : null,
                  onSearch: _handleSearch,
                ),
              ),

              const SizedBox(height: 20),

              // ── Zone centrale : idle state ────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Icône de recherche illustrative
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: kPrimaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        size: 36,
                        color: kTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Recherchez une recette par son nom',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: kTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // ── Suggestions ────────────────────────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Suggestions',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestions.map((s) {
                        return GestureDetector(
                          onTap: () {
                            _searchController.text = s;
                            _handleSearch();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: kSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: kBorder),
                            ),
                            child: Text(
                              s,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: kTextPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSearch() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultScreen(
            query: _searchController.text,
            type: ResultType.recipe,
          ),
        ),
      );
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Widget réutilisable : Barre de recherche premium
// ──────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final VoidCallback onSearch;

  const _SearchBar({
    required this.controller,
    required this.hintText,
    required this.onSearch,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onFieldSubmitted: (_) => onSearch(),
      textInputAction: TextInputAction.search,
      style: GoogleFonts.outfit(
        fontSize: 15,
        color: kTextPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.outfit(
          color: kTextSecondary,
          fontSize: 15,
        ),
        // Fond blanc sur kBackground
        filled: true,
        fillColor: kSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: kBorder, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: kBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: kPrimary, width: 1.8),
        ),
        errorStyle: const TextStyle(height: 0, fontSize: 0.01),
        // Bouton recherche vert à droite
        suffixIcon: GestureDetector(
          onTap: onSearch,
          child: Container(
            margin: const EdgeInsets.all(6),
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: kPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
