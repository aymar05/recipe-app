import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/screens/account/recipe_screen.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:recipe_app/services/api/config/constants.dart';

// ──────────────────────────────────────────────────────────────────────────────
// FavoritesScreen — Refonte UI v2
// ⚠️  ZÉRO MODIFICATION LOGIQUE : _apiService, _favorites, _isLoading,
//     _loadFavorites, _apiService.getFavorites, Navigator.push + .then
// ──────────────────────────────────────────────────────────────────────────────

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // ── LOGIQUE INCHANGÉE ──────────────────────────────────────────────────────
  final APIService _apiService = Get.find<APIService>();
  List<Recipe> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    final recipes = await _apiService.getFavorites();

    if (mounted) {
      setState(() {
        _favorites = recipes;
        _isLoading = false;
      });
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
              const SizedBox(height: 28),

              // ── Titre + compteur ──────────────────────────────────────
              Text(
                'Mes Favoris',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 4),

              // Compteur dynamique
              if (!_isLoading)
                Text(
                  _favorites.isEmpty
                      ? 'Aucune recette sauvegardée'
                      : '${_favorites.length} recette${_favorites.length > 1 ? 's' : ''} sauvegardée${_favorites.length > 1 ? 's' : ''}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: kTextSecondary,
                  ),
                ),

              const SizedBox(height: 20),

              // ── Contenu ───────────────────────────────────────────────
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Chargement
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: kPrimary),
      );
    }

    // État vide
    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 40,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun favori pour le moment.',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sauvegardez des recettes que vous aimez !',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _loadFavorites,
              child: Text(
                'Actualiser',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: kPrimary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: kPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Grille de favoris
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: kPrimary,
      child: GridView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: _favorites.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          return _FavoriteCard(
            recipe: _favorites[index],
            onNavigated: _loadFavorites,
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Widget : Carte favori — même style que home_screen._RecipeCard
// icône bookmark jaune/doré pour indiquer le favori
// ──────────────────────────────────────────────────────────────────────────────
class _FavoriteCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onNavigated;

  const _FavoriteCard({required this.recipe, required this.onNavigated});

  String _resolveImageUrl() {
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
    return imageUrlToUse;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeScreen(recipeId: recipe.id!),
          ),
        ).then((_) => onNavigated());
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
            // ── Image + Bookmark jaune (favori confirmé) ──────────────
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
                        imageUrl,
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

                  // Icône bookmark JAUNE = favori actif
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
                        Icons.bookmark_rounded,
                        size: 16,
                        color: Color(0xFFF5BB00), // Jaune doré
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Infos texte ───────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      recipe.title ?? 'Recette sans titre',
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
  }
}