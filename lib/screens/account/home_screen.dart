import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/controllers/home_controller.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/screens/account/recipe_screen.dart';
import 'package:recipe_app/services/api/config/constants.dart';
import 'package:recipe_app/services/api_auth_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// HomeScreen — Refonte UI v2
// ⚠️  ZÉRO MODIFICATION LOGIQUE : HomeController, isLoading, recipeList,
//     isMoreLoading, loadNextPage, refreshRecipes, scrollController listener
// Layout : SliverAppBar invisible + section "Populaires" H-scroll + SliverGrid
// ──────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── LOGIQUE INCHANGÉE ──────────────────────────────────────────────────
    final HomeController controller = Get.put(HomeController());
    final ScrollController scrollController = ScrollController();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        controller.loadNextPage();
      }
    });
    // ──────────────────────────────────────────────────────────────────────

    return Scaffold(
      backgroundColor: kBackground,
      body: Obx(() {
        // ── État : Chargement initial ───────────────────────────────────
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimary),
          );
        }

        // ── État : Liste vide ───────────────────────────────────────────
        if (controller.recipeList.isEmpty) {
          return _EmptyState(onRetry: controller.refreshRecipes);
        }

        // ── État : Données disponibles ──────────────────────────────────
        final recipes = controller.recipeList;

        // Les 5 premières recettes alimentent la section "Populaires"
        final popularRecipes = recipes.take(5).toList();

        return RefreshIndicator(
          onRefresh: controller.refreshRecipes,
          color: kPrimary,
          displacement: 60,
          child: CustomScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── [1] En-tête fixe avec salutation ──────────────────────
              SliverToBoxAdapter(
                child: _HomeHeader(),
              ),

              // ── [2] Section "Populaires" — scroll horizontal ───────────
              SliverToBoxAdapter(
                child: _SectionTitle(title: 'Populaires'),
              ),
              SliverToBoxAdapter(
                child: _PopularSection(
                  recipes: popularRecipes,
                  favoriteIds: controller.favoriteIds,
                ),
              ),

              // ── [3] Section "Toutes les recettes" — grille 2 col ──────
              SliverToBoxAdapter(
                child: _SectionTitle(title: 'Toutes les recettes'),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final r = recipes[index];
                      return _RecipeCard(
                        recipe: r,
                        isFavorite: controller.favoriteIds.contains(r.id),
                      );
                    },
                    childCount: recipes.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                ),
              ),

              // ── [4] Indicateur de chargement de la page suivante ───────
              SliverToBoxAdapter(
                child: controller.isMoreLoading.value
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(color: kPrimary),
                        ),
                      )
                    : const SizedBox(height: 24),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Widget : En-tête de l'écran d'accueil
// ──────────────────────────────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salutation dynamique (ou fallback générique)
                Obx(() {
                  final name = ApiAuthService.to.user?.name;
                  return Text(
                    name != null ? 'Bonjour, $name 👋' : 'Bonjour,',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: kTextSecondary,
                    ),
                  );
                }),
                const SizedBox(height: 2),
                Text(
                  'Recipe Book',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),

            // Logo chef hat SVG — fond vert aténué, trait vert
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: SvgPicture.asset(
                  'assets/icons/chef_hat.svg',
                  colorFilter: const ColorFilter.mode(
                    kPrimary, // trait vert sur fond vert aténué
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Widget : Titre de section
// ──────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: kTextPrimary,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Widget : Section Populaires — scroll horizontal
// ──────────────────────────────────────────────────────────────────────────────
class _PopularSection extends StatelessWidget {
  final List<Recipe> recipes;
  final Set<int> favoriteIds;
  const _PopularSection({required this.recipes, required this.favoriteIds});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: recipes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final r = recipes[index];
          return _RecipeCard(
            recipe: r,
            isHorizontal: true,
            isFavorite: favoriteIds.contains(r.id),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Widget : Carte Recette — utilisée en mode horizontal ET en grille
// ──────────────────────────────────────────────────────────────────────────────
class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool isHorizontal;
  final bool isFavorite;

  const _RecipeCard({
    required this.recipe,
    this.isHorizontal = false,
    this.isFavorite = false,
  });

  /// Résolution URL image — LOGIQUE ORIGINALE INCHANGÉE
  String _resolveImageUrl() {
    String imageUrlToUse = 'https://via.placeholder.com/150';

    String? rawPath = (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
        ? recipe.imageUrl
        : recipe.image;

    if (rawPath != null && rawPath.isNotEmpty) {
      if (rawPath.startsWith('http')) {
        imageUrlToUse = rawPath;
      } else {
        if (rawPath.startsWith('/')) {
          imageUrlToUse = '${Constants.apiBaseUrl}$rawPath';
        } else {
          imageUrlToUse = '${Constants.apiBaseUrl}/$rawPath';
        }
      }
    }

    return imageUrlToUse;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl();

    return GestureDetector(
      onTap: () {
        if (recipe.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeScreen(recipeId: recipe.id!),
            ),
          );
        }
      },
      child: Container(
        // Carte horizontale = largeur fixe ; grille = s'adapte au parent
        width: isHorizontal ? 155 : null,
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
            // ── Image + Bookmark ─────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  // Image de la recette
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

                  // Icône Bookmark — plein + jaune si favori, sinon outline gris
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
                      child: Icon(
                        isFavorite
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        size: 16,
                        color: isFavorite
                            ? const Color(0xFFF5BB00)
                            : kTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Infos texte ───────────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Titre
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

                    // Temps
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

// ──────────────────────────────────────────────────────────────────────────────
// Widget : État vide
// ──────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
              Icons.search_off_rounded,
              size: 40,
              color: kPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune recette trouvée.',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Réessayer',
              style: GoogleFonts.outfit(
                color: kPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}