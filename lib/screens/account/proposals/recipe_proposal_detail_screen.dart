import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/models/recipe_request.dart';
import 'package:recipe_app/services/api/config/constants.dart';
import 'package:recipe_app/services/api_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// RecipeProposalDetailScreen — Refonte UI v2
// ⚠️  ZÉRO MODIFICATION LOGIQUE : _apiService, requestId, _loadData,
//     isLoading, request, imageUrl resolution, status switch (approved/rejected/pending)
//     tags, ingredients, steps
// Layout : SliverAppBar (hero image) + carte info + onglets ingrédients/instructions
// ──────────────────────────────────────────────────────────────────────────────

class RecipeProposalDetailScreen extends StatefulWidget {
  final int requestId;
  const RecipeProposalDetailScreen({super.key, required this.requestId});

  @override
  State<RecipeProposalDetailScreen> createState() =>
      _RecipeProposalDetailScreenState();
}

class _RecipeProposalDetailScreenState
    extends State<RecipeProposalDetailScreen> {
  // ── LOGIQUE MÉTIER INCHANGÉE ──────────────────────────────────────────────
  final APIService _apiService = Get.find<APIService>();
  RecipeRequest? request;
  bool isLoading = true;

  // ── ÉTAT UI UNIQUEMENT ────────────────────────────────────────────────────
  int _activeTab = 0; // 0 = Ingrédients, 1 = Instructions

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final fetchedRequest =
          await _apiService.getRecipeRequestById(widget.requestId);

      if (!mounted) return;

      if (fetchedRequest == null) {
        setState(() => isLoading = false);
        Get.snackbar('Erreur', 'Proposition introuvable');
        return;
      }

      setState(() {
        request = fetchedRequest;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ── RENDU VISUEL ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ── Chargement ──────────────────────────────────────────────────────────
    if (isLoading) {
      return const Scaffold(
        backgroundColor: kBackground,
        body: Center(child: CircularProgressIndicator(color: kPrimary)),
      );
    }

    // ── Erreur ───────────────────────────────────────────────────────────────
    if (request == null) {
      return Scaffold(
        backgroundColor: kBackground,
        appBar: AppBar(backgroundColor: kBackground, elevation: 0),
        body: Center(
          child: Text(
            'Erreur de chargement',
            style: GoogleFonts.outfit(color: kTextSecondary),
          ),
        ),
      );
    }

    final req = request!;

    // ── Résolution image — LOGIQUE ORIGINALE INCHANGÉE ─────────────────────
    String? displayImage;
    if (req.imageUrl != null && req.imageUrl!.isNotEmpty) {
      displayImage = req.imageUrl!.startsWith('http')
          ? req.imageUrl
          : '${Constants.apiBaseUrl}/${req.imageUrl!}';
    }

    // ── Résolution statut — LOGIQUE ORIGINALE INCHANGÉE ────────────────────
    Color statusColor;
    Color statusBg;
    String statusTitle;
    String statusMessage;
    IconData statusIcon;

    switch (req.status) {
      case 'approved':
        statusColor = kPrimary;
        statusBg = kPrimaryLight;
        statusTitle = 'Recette approuvée';
        statusMessage =
            'Votre recette a été publiée et est visible par la communauté.';
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusBg = const Color(0xFFFEE2E2);
        statusTitle = 'Proposition rejetée';
        statusMessage =
            'Votre recette ne répond pas aux critères. Vous pouvez la modifier et resoumettre.';
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = kAccent;
        statusBg = const Color(0xFFFFF3E0);
        statusTitle = 'En attente de validation';
        statusMessage =
            'Votre recette est en cours de révision par notre équipe.';
        statusIcon = Icons.hourglass_empty_rounded;
    }

    // Date relative
    String dateLabel = '';
    if (req.createdAt != null) {
      final diff = DateTime.now().difference(req.createdAt!);
      if (diff.inDays == 0) {
        dateLabel = "Proposée aujourd'hui";
      } else if (diff.inDays == 1) {
        dateLabel = 'Proposée il y a 1 jour';
      } else {
        dateLabel = 'Proposée il y a ${diff.inDays} jours';
      }
    }

    final ingredientsCount = req.ingredients?.length ?? 0;
    final stepsCount = req.steps?.length ?? 0;

    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── [1] Image héro + bouton retour ─────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: kPrimary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  displayImage != null
                      ? Image.network(
                          displayImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: kPrimaryLight,
                            child: const Icon(
                              Icons.restaurant_menu_rounded,
                              size: 64,
                              color: kPrimary,
                            ),
                          ),
                        )
                      : Container(
                          color: kPrimaryLight,
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            size: 64,
                            color: kPrimary,
                          ),
                        ),

                  // Dégradé bas
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
                            kBackground.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bouton retour circulaire
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── [2] Carte info recette ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    req.title ?? 'Sans titre',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),

                  // Date relative
                  if (dateLabel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: kTextSecondary,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Stats : Durée + Niveau
                  Row(
                    children: [
                      _StatItem(
                        icon: Icons.access_time_rounded,
                        iconColor: kAccent,
                        label: 'Durée',
                        value: '${req.preparationTime ?? 0} min',
                      ),
                      const SizedBox(width: 24),
                      _StatItem(
                        icon: Icons.bar_chart_rounded,
                        iconColor: kPrimary,
                        label: 'Niveau',
                        value: 'Moyen',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── [3] Bandeau statut ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusTitle,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          statusMessage,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: statusColor.withOpacity(0.85),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── [4] Tags ───────────────────────────────────────────────────
          if (req.tags != null && req.tags!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: req.tags!
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
              ),
            ),

          // ── [5] Sélecteur d'onglets ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Ingrédients ($ingredientsCount)',
                      isActive: _activeTab == 0,
                      onTap: () => setState(() => _activeTab = 0),
                    ),
                    _TabButton(
                      label: 'Instructions ($stepsCount)',
                      isActive: _activeTab == 1,
                      onTap: () => setState(() => _activeTab = 1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── [6] Contenu de l'onglet actif ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: _activeTab == 0
                  ? _IngredientsTab(ingredients: req.ingredients ?? [])
                  : _StepsTab(steps: req.steps ?? []),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Stat Item (Durée / Niveau)
// ──────────────────────────────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: kTextSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: kTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tab Button
// ──────────────────────────────────────────────────────────────────────────────
class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _TabButton({
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
          decoration: BoxDecoration(
            color: isActive ? kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : kTextSecondary,
              ),
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
  final List<RecipeRequestIngredient> ingredients;
  const _IngredientsTab({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return Center(
        child: Text(
          'Aucun ingrédient renseigné',
          style: GoogleFonts.outfit(color: kTextSecondary),
        ),
      );
    }

    return Column(
      children: ingredients
          .map((ing) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: kPrimaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: kPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ing.name ?? '',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${ing.quantity ?? ''} ${ing.measure ?? ''}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kAccent,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Onglet Instructions (étapes numérotées)
// ──────────────────────────────────────────────────────────────────────────────
class _StepsTab extends StatelessWidget {
  final List<RecipeRequestStep> steps;
  const _StepsTab({required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Center(
        child: Text(
          'Aucune instruction renseignée',
          style: GoogleFonts.outfit(color: kTextSecondary),
        ),
      );
    }

    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Numéro d'étape
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: kPrimary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (step.name != null && step.name!.isNotEmpty)
                      Text(
                        step.name!,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                        ),
                      ),
                    if (step.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          step.description!,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: kTextSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    if (step.duration != null && step.duration! > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: kAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${step.duration} min',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: kAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}