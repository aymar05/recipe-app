import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/data/result_type.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/screens/account/recipe_screen.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:recipe_app/services/api/config/constants.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SearchResultScreen — Refonte UI v2
// ⚠️  ZÉRO MODIFICATION LOGIQUE : _recipes, _apiService, _isLoading,
//     _hasSearched, _errorMessage, _checkAndLoadData, _loadData,
//     _apiService.searchRecipes, widget.query, widget.type
// ──────────────────────────────────────────────────────────────────────────────

class SearchResultScreen extends StatefulWidget {
  final String query;
  final ResultType type;

  const SearchResultScreen({
    super.key,
    required this.query,
    required this.type,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  // ── LOGIQUE INCHANGÉE ─────────────────────────────────────────────────────
  final List<Recipe> _recipes = [];
  final APIService _apiService = Get.find<APIService>();

  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAndLoadData();
  }

  void _checkAndLoadData() {
    if (widget.query.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Veuillez entrer un terme de recherche.';
      });
      return;
    }
    _loadData();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Recipe> recipes = await _apiService.searchRecipes(widget.query);

      if (mounted) {
        setState(() {
          _recipes.addAll(recipes);
          _isLoading = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Une erreur est survenue lors de la recherche.';
        });
      }
    }
  }

  // ── RENDU VISUEL ──────────────────────────────────────────────────────────

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
              const SizedBox(height: 16),

              // ── En-tête : retour + titre ──────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: kBorder),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: kTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Rechercher',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Barre de recherche statique (affiche la requête) ───────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kPrimary, width: 1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.query,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: kTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: kPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Sous-titre résultats ────────────────────────────────────
              if (_hasSearched && !_isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${_recipes.length} résultat${_recipes.length > 1 ? 's' : ''} pour "${widget.query}"',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: kTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              // ── Contenu principal ───────────────────────────────────────
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Erreur
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 36,
                color: kAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: kTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Chargement
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: kPrimary),
      );
    }

    // Aucun résultat
    if (_hasSearched && _recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 36,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune recette trouvée.',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Essayez avec d\'autres mots-clés',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: kTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // ── Grille de résultats ───────────────────────────────────────────────
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _recipes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final recipe = _recipes[index];

        // Résolution URL image — LOGIQUE ORIGINALE INCHANGÉE
        String imageUrlToUse = 'https://via.placeholder.com/150';
        String? rawPath =
            (recipe.imageUrl ?? '').isNotEmpty ? recipe.imageUrl : recipe.image;
        if (rawPath != null && rawPath.isNotEmpty) {
          if (rawPath.startsWith('http')) {
            imageUrlToUse = rawPath;
          } else {
            imageUrlToUse = rawPath.startsWith('/')
                ? '${Constants.apiBaseUrl}$rawPath'
                : '${Constants.apiBaseUrl}/$rawPath';
          }
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeScreen(recipeId: recipe.id!),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  flex: 6,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: SizedBox.expand(
                          child: Image.network(
                            imageUrlToUse,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: kPrimaryLight,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: kPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Bookmark
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bookmark_outline_rounded,
                            size: 16,
                            color: kTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Infos
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          recipe.title ?? 'Sans titre',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: kAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.time ?? 0} min',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: kAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}