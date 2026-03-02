import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/comment.dart';
import 'package:recipe_app/models/ingredient.dart';
import 'package:recipe_app/models/recipe_step.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:recipe_app/services/api/config/constants.dart';
import 'package:recipe_app/services/api_auth_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// RecipeScreen — Refonte UI v2
// ⚠️  ZÉRO MODIFICATION LOGIQUE : _apiService, _commentController, recipe,
//     isLoading, isFavorite, isSendingComment, _loadData, _toggleFavorite,
//     _sendComment, dispose
// Ajout UI ONLY : _activeTab (int) pour la sélection Ingrédients/Instructions
// ──────────────────────────────────────────────────────────────────────────────

class RecipeScreen extends StatefulWidget {
  final int recipeId;
  const RecipeScreen({super.key, required this.recipeId});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  // ── LOGIQUE MÉTIER INCHANGÉE ──────────────────────────────────────────────
  final APIService _apiService = Get.find<APIService>();
  final TextEditingController _commentController = TextEditingController();

  Recipe? recipe;
  bool isLoading = true;
  bool isFavorite = false;
  bool isSendingComment = false;

  // ── ÉTAT UI UNIQUEMENT (onglet actif) ─────────────────────────────────────
  int _activeTab = 0; // 0 = Ingrédients, 1 = Instructions

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadData() async {
    try {
      final results = await Future.wait([
        _apiService.getRecipeById(widget.recipeId),
        _apiService.getFavorites()
      ]);

      final fetchedRecipe = results[0] as Recipe?;
      final favoritesList = results[1] as List<Recipe>;

      if (!mounted) return;

      if (fetchedRecipe == null) {
        setState(() => isLoading = false);
        return;
      }

      bool foundInFavorites =
          favoritesList.any((fav) => fav.id == widget.recipeId);

      setState(() {
        recipe = fetchedRecipe;
        isFavorite = foundInFavorites;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    bool previousState = isFavorite;
    setState(() => isFavorite = !isFavorite);

    bool success;
    if (isFavorite) {
      success = await _apiService.addToFavorites(widget.recipeId);
    } else {
      success = await _apiService.removeFavorite(widget.recipeId);
    }

    if (success) {
      Get.snackbar(
        isFavorite ? "Ajouté aux favoris" : "Retiré des favoris",
        isFavorite ? "Recette enregistrée" : "Recette retirée",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } else {
      setState(() => isFavorite = previousState);
      Get.snackbar(
        "Erreur",
        "Impossible de modifier les favoris",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => isSendingComment = true);

    Comment? newComment =
        await _apiService.postComment(widget.recipeId, _commentController.text);

    setState(() => isSendingComment = false);

    if (newComment != null) {
      _commentController.clear();

      final currentUser = ApiAuthService.to.user;
      if (currentUser != null) {
        newComment = newComment.copyWith(
          user: CommentUser(id: currentUser.id, name: currentUser.name),
        );
      }

      setState(() {
        recipe?.comments ??= [];
        recipe?.comments!.insert(0, newComment!);
      });

      Get.snackbar("Succès", "Commentaire ajouté !",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Erreur", "Échec de l'envoi",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ── RENDU VISUEL ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: kBackground,
        body: Center(child: CircularProgressIndicator(color: kPrimary)),
      );
    }

    final r = recipe!;

    // Résolution URL image — LOGIQUE ORIGINALE INCHANGÉE
    String? displayImage;
    String? rawPath = (r.imageUrl ?? '').isNotEmpty ? r.imageUrl : r.image;
    if (rawPath != null && rawPath.isNotEmpty) {
      if (rawPath.startsWith('http')) {
        displayImage = rawPath;
      } else {
        displayImage = rawPath.startsWith('/')
            ? '${Constants.apiBaseUrl}$rawPath'
            : '${Constants.apiBaseUrl}/$rawPath';
      }
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // ── Contenu principal scrollable ─────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── [1] Image héros avec boutons flottants ───────────────
              _HeroSliver(
                imageUrl: displayImage,
                isFavorite: isFavorite,
                onFavoriteTap: _toggleFavorite,
              ),

              // ── [2] Carte info recette (titre + stats + onglets) ──────
              SliverToBoxAdapter(
                child: _RecipeInfoCard(
                  recipe: r,
                  activeTab: _activeTab,
                  onTabChange: (i) => setState(() => _activeTab = i),
                ),
              ),

              // ── [3] Contenu de l'onglet actif ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _activeTab == 0
                      ? _IngredientsTab(ingredients: r.ingredients ?? [])
                      : _InstructionsTab(steps: r.steps ?? []),
                ),
              ),

              // ── [4] Section Commentaires ───────────────────────────────
              SliverToBoxAdapter(
                child: _CommentsSection(
                  comments: r.comments ?? [],
                  controller: _commentController,
                  isSending: isSendingComment,
                  onSend: _sendComment,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Sliver : Image héros + boutons retour et favori
// ──────────────────────────────────────────────────────────────────────────────
class _HeroSliver extends StatelessWidget {
  final String? imageUrl;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const _HeroSliver({
    required this.imageUrl,
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: false,
      snap: false,
      floating: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image plein écran
            if (imageUrl != null)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: kPrimaryLight),
              )
            else
              Container(color: kPrimaryLight),

            // Dégradé bas pour transition douce vers la carte blanche
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      kBackground.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bouton Retour ──────────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              child: _CircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
            ),

            // ── Bouton Favori ──────────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: _CircleButton(
                icon: isFavorite
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline_rounded,
                iconColor: isFavorite ? const Color(0xFFF5BB00) : kTextSecondary,
                onTap: onFavoriteTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bouton circulaire blanc générique (retour / favori)
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor = kTextPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Carte info recette : titre, stats, sélecteur d'onglet
// ──────────────────────────────────────────────────────────────────────────────
class _RecipeInfoCard extends StatelessWidget {
  final Recipe recipe;
  final int activeTab;
  final ValueChanged<int> onTabChange;

  const _RecipeInfoCard({
    required this.recipe,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final tags = recipe.tags ?? [];

    return Container(
      margin: const EdgeInsets.only(top: 0),
      decoration: const BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            recipe.title ?? 'Recette sans titre',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 14),

          // Stat : Durée uniquement
          _StatBadge(
            icon: Icons.access_time_rounded,
            iconColor: kAccent,
            label: '${recipe.time ?? 0} min',
          ),

          // Tags — chips pill (visible seulement si non vide)
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kBorder),
                        ),
                        child: Text(
                          t.name ?? '',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: kTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],

          const SizedBox(height: 20),

          // Sélecteur Ingrédients / Instructions
          _TabSelector(activeTab: activeTab, onTabChange: onTabChange),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// Badge stat individuel (icône + texte)
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: kTextSecondary,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Sélecteur d'onglet : pill vert glissant
// ──────────────────────────────────────────────────────────────────────────────
class _TabSelector extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabChange;

  const _TabSelector({required this.activeTab, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Ingrédients',
            isActive: activeTab == 0,
            onTap: () => onTabChange(0),
          ),
          _TabItem(
            label: 'Instructions',
            isActive: activeTab == 1,
            onTap: () => onTabChange(1),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : kTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Onglet Ingrédients
// ──────────────────────────────────────────────────────────────────────────────
class _IngredientsTab extends StatelessWidget {
  final List<Ingredient> ingredients;
  const _IngredientsTab({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Aucun ingrédient renseigné.',
          style: GoogleFonts.outfit(color: kTextSecondary),
        ),
      );
    }

    return Column(
      children: ingredients.asMap().entries.map((entry) {
        final ingredient = entry.value;
        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Cercle check
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kBorder, width: 1.5),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: kPrimary,
                ),
              ),
              const SizedBox(width: 12),

              // Nom ingrédient
              Expanded(
                child: Text(
                  ingredient.name ?? 'Ingrédient',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kTextPrimary,
                  ),
                ),
              ),

              // Quantité + unité
              if (ingredient.quantity != null || ingredient.measure != null)
                Text(
                  '${ingredient.quantity ?? ''} ${ingredient.measure ?? ''}'.trim(),
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kAccent,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Onglet Instructions
// ──────────────────────────────────────────────────────────────────────────────
class _InstructionsTab extends StatelessWidget {
  final List<RecipeStep> steps;
  const _InstructionsTab({required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Aucune instruction renseignée.',
          style: GoogleFonts.outfit(color: kTextSecondary),
        ),
      );
    }

    return Column(
      children: steps.asMap().entries.map((entry) {
        final stepIndex = entry.key;
        final step = entry.value;
        return _StepTile(index: stepIndex, step: step);
      }).toList(),
    );
  }
}

class _StepTile extends StatelessWidget {
  final int index;
  final RecipeStep step;
  const _StepTile({required this.index, required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numéro d'étape — cercle vert
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: kPrimary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre de l'étape
                if (step.name != null && step.name!.isNotEmpty)
                  Text(
                    step.name!,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                  ),

                // Description
                if (step.description != null && step.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    step.description!,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: kTextSecondary,
                      height: 1.5,
                    ),
                  ),
                ],

                // Durée de l'étape
                if (step.duration != null && step.duration! > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 13, color: kAccent),
                      const SizedBox(width: 4),
                      Text(
                        '${step.duration} min',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: kAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Section Commentaires
// ──────────────────────────────────────────────────────────────────────────────
class _CommentsSection extends StatelessWidget {
  final List<Comment> comments;
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _CommentsSection({
    required this.comments,
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: kBorder),
          const SizedBox(height: 16),

          // Titre + compteur
          Row(
            children: [
              Text(
                'Commentaires',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${comments.length}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Champ de saisie + bouton envoyer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: kBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Ajouter un commentaire...',
                      hintStyle: GoogleFonts.outfit(
                        fontSize: 14,
                        color: kTextSecondary,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    minLines: 1,
                    maxLines: 3,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: kTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: isSending ? null : onSend,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSending ? kPrimary.withOpacity(0.6) : kPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: isSending
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Liste des commentaires
          if (comments.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                "Soyez le premier à commenter !",
                style: GoogleFonts.outfit(
                  fontStyle: FontStyle.italic,
                  color: kTextSecondary,
                  fontSize: 14,
                ),
              ),
            )
          else
            ...comments.map((comment) => _CommentTile(comment: comment)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tuile commentaire unique
// ──────────────────────────────────────────────────────────────────────────────
class _CommentTile extends StatelessWidget {
  final Comment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final userName = comment.user?.name ?? 'Utilisateur';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar initiale
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: kPrimaryLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Bulle texte
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.text ?? '',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: kTextSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}