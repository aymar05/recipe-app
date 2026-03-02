import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/controllers/proposal_controller.dart';
import 'package:recipe_app/models/recipe_request.dart';
import 'package:recipe_app/screens/account/proposals/create_proposal_screen.dart';
import 'package:recipe_app/screens/account/proposals/recipe_proposal_detail_screen.dart';
import 'package:recipe_app/services/api/config/constants.dart';

// ──────────────────────────────────────────────────────────────────────────────
// UserProposalsScreen — Refonte UI v2
// ⚠️  ZÉRO MODIFICATION LOGIQUE : ProposalController, proposals Obx,
//     fetchProposals, imageUrl resolution, statusColor/statusText logic,
//     Get.to(CreateProposalScreen), Get.to(RecipeProposalDetailScreen)
// ──────────────────────────────────────────────────────────────────────────────

class UserProposalsScreen extends StatelessWidget {
  const UserProposalsScreen({super.key});

  // ── Résolution statut — LOGIQUE ORIGINALE INCHANGÉE ─────────────────────
  _StatusInfo _resolveStatus(String? rawStatus) {
    final status = rawStatus ?? 'pending';
    if (status == 'approved') {
      return _StatusInfo(
        label: 'Approuvée',
        color: kPrimary,
        bg: kPrimaryLight,
        icon: Icons.check_circle_outline_rounded,
      );
    } else if (status == 'rejected') {
      return _StatusInfo(
        label: 'Rejetée',
        color: Colors.red,
        bg: const Color(0xFFFEE2E2),
        icon: Icons.cancel_outlined,
      );
    } else {
      return _StatusInfo(
        label: 'En attente',
        color: kAccent,
        bg: const Color(0xFFFFF3E0),
        icon: Icons.hourglass_empty_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── LOGIQUE INCHANGÉE ──────────────────────────────────────────────────
    final ProposalController controller = Get.put(ProposalController());

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Obx(() {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── En-tête ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vos recettes',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: kTextSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mes propositions',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Compteurs par statut ─────────────────────────────────────
              if (!controller.isLoading.value &&
                  controller.proposals.isNotEmpty)
                SliverToBoxAdapter(
                  child: _StatusSummary(
                    proposals: controller.proposals,
                  ),
                ),

              // ── État : Chargement ─────────────────────────────────────────
              if (controller.isLoading.value)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  ),
                ),

              // ── État : Liste vide ─────────────────────────────────────────
              if (!controller.isLoading.value &&
                  controller.proposals.isEmpty)
                SliverFillRemaining(
                  child: _EmptyState(
                    onAdd: () => Get.to(() => const CreateProposalScreen()),
                  ),
                ),

              // ── Grille 2 colonnes des propositions ───────────────────────
              if (!controller.isLoading.value &&
                  controller.proposals.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72, // hauteur image + texte
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final req = controller.proposals[index];
                        return _ProposalCard(
                          req: req,
                          statusInfo: _resolveStatus(req.status),
                          onTap: () {
                            if (req.id != null) {
                              Get.to(() => RecipeProposalDetailScreen(
                                  requestId: req.id!));
                            }
                          },
                        );
                      },
                      childCount: controller.proposals.length,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),

      // ── FAB : Ajouter une nouvelle proposition ──────────────────────────
      floatingActionButton: _AddFAB(
        onPressed: () => Get.to(() => const CreateProposalScreen()),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Modèle d'info statut (UI only)
// ──────────────────────────────────────────────────────────────────────────────
class _StatusInfo {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;
  const _StatusInfo({
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
  });
}

// ──────────────────────────────────────────────────────────────────────────────
// Résumé des statuts (chips compteurs)
// ──────────────────────────────────────────────────────────────────────────────
class _StatusSummary extends StatelessWidget {
  final List<RecipeRequest> proposals;
  const _StatusSummary({required this.proposals});

  @override
  Widget build(BuildContext context) {
    final approved = proposals.where((p) => p.status == 'approved').length;
    final pending =
        proposals.where((p) => p.status != 'approved' && p.status != 'rejected').length;
    final rejected = proposals.where((p) => p.status == 'rejected').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _StatChip(count: approved, label: 'Approuvées', color: kPrimary, bg: kPrimaryLight),
          const SizedBox(width: 8),
          _StatChip(count: pending, label: 'En attente', color: kAccent, bg: const Color(0xFFFFF3E0)),
          const SizedBox(width: 8),
          _StatChip(count: rejected, label: 'Rejetées', color: Colors.red, bg: const Color(0xFFFEE2E2)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final Color bg;
  const _StatChip({
    required this.count,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Carte proposition
// ──────────────────────────────────────────────────────────────────────────────
class _ProposalCard extends StatelessWidget {
  final RecipeRequest req;
  final _StatusInfo statusInfo;
  final VoidCallback onTap;

  const _ProposalCard({
    required this.req,
    required this.statusInfo,
    required this.onTap,
  });

  /// Résolution URL image — LOGIQUE ORIGINALE INCHANGÉE
  String? _resolveImageUrl() {
    if (req.imageUrl == null || req.imageUrl!.isEmpty) return null;
    if (req.imageUrl!.startsWith('http')) return req.imageUrl;
    if (req.imageUrl!.startsWith('/')) {
      return '${Constants.apiBaseUrl}${req.imageUrl!.substring(1)}';
    }
    return '${Constants.apiBaseUrl}/${req.imageUrl!}';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Image + badge statut ─────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    color: kPrimaryLight,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.restaurant_menu_rounded,
                              size: 48,
                              color: kPrimary,
                            ),
                          )
                        : const Icon(
                            Icons.restaurant_menu_rounded,
                            size: 48,
                            color: kPrimary,
                          ),
                  ),
                ),

                // Badge statut
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusInfo.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusInfo.label,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Infos texte ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.title ?? 'Sans titre',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Durée
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 13, color: kAccent),
                            const SizedBox(width: 4),
                            Text(
                              '${req.preparationTime ?? 0} min',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: kAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Chevron
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: kPrimaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: kPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays == 1) return 'Il y a 1 jour';
    return 'Il y a ${diff.inDays} jours';
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// FAB premium : + Nouvelle proposition
// ──────────────────────────────────────────────────────────────────────────────
class _AddFAB extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kAccent, Color(0xFFFB923C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: kAccent.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              'Nouvelle proposition',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// État vide
// ──────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                size: 44,
                color: kPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucune proposition',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Partagez votre première recette avec la communauté !',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: kTextSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Proposer une recette',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
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