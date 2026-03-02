import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/controllers/proposal_controller.dart';

// ──────────────────────────────────────────────────────────────────────────────
// CreateProposalScreen — Refonte UI v3
// ⚠️  LOGIQUE STRICTEMENT IDENTIQUE À L'ORIGINAL :
//     - controller.addIngredient(name, qty, measure)  clears fields
//     - controller.addStep(name, desc, duration)       clears fields
//     - controller.addTag(tag)                         clears field
//     - controller.submitProposal(_titleController, _timeController)
// ──────────────────────────────────────────────────────────────────────────────

class CreateProposalScreen extends StatefulWidget {
  const CreateProposalScreen({super.key});

  @override
  State<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends State<CreateProposalScreen> {
  // ── LOGIQUE INCHANGÉE ──────────────────────────────────────────────────────
  final ProposalController controller = Get.find<ProposalController>();

  final _titleController = TextEditingController();
  final _timeController = TextEditingController();

  final _ingNameController = TextEditingController();
  final _ingQtyController = TextEditingController();

  final _stepNameController = TextEditingController();
  final _stepDescController = TextEditingController();
  final _stepDurationController = TextEditingController();

  final _tagController = TextEditingController();

  // ── UI state only ──────────────────────────────────────────────────────────
  String _selectedUnit = 'g';

  static const List<String> _units = [
    'g', 'kg', 'mg',
    'ml', 'cl', 'dl', 'L',
    'c. à café', 'c. à soupe',
    'tasse',
    'pincée', 'unité', 'tranche', 'gousse', 'brin', 'feuille',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),

              // ── En-tête ────────────────────────────────────────────────
              Text(
                'Proposer une recette',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Partagez votre recette avec la communauté',
                style: GoogleFonts.outfit(fontSize: 14, color: kTextSecondary),
              ),

              const SizedBox(height: 28),

              // ════════════════════════════════════════════════════════════
              // SECTION 1 · Informations générales
              // ════════════════════════════════════════════════════════════
              _sectionTitle('Informations générales'),
              const SizedBox(height: 12),
              _field(
                controller: _titleController,
                hint: 'Titre de la recette',
                icon: Icons.title_rounded,
              ),
              const SizedBox(height: 10),
              _field(
                controller: _timeController,
                hint: 'Temps de préparation (min)',
                icon: Icons.access_time_rounded,
                type: TextInputType.number,
              ),

              const SizedBox(height: 24),
              const Divider(color: kBorder),
              const SizedBox(height: 16),

              // ════════════════════════════════════════════════════════════
              // SECTION 2 · Image
              // ════════════════════════════════════════════════════════════
              _sectionTitle('Image de la recette'),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: controller.pickImage,
                child: Obx(() {
                  final img = controller.selectedImage.value;
                  if (img != null) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: kIsWeb
                            ? Image.network(img.path, fit: BoxFit.cover)
                            : Image.file(File(img.path), fit: BoxFit.cover),
                      ),
                    );
                  }
                  return Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kPrimaryLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: kPrimary.withOpacity(0.35), width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_rounded,
                            size: 36, color: kPrimary.withOpacity(0.5)),
                        const SizedBox(height: 8),
                        Text(
                          'Appuyer pour choisir une image',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: kPrimary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),
              const Divider(color: kBorder),
              const SizedBox(height: 16),

              // ════════════════════════════════════════════════════════════
              // SECTION 3 · Ingrédients
              // ════════════════════════════════════════════════════════════
              _sectionTitle('Ingrédients'),
              const SizedBox(height: 12),

              // ── Ligne de saisie ─────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Nom
                  Expanded(
                    child: _field(
                      controller: _ingNameController,
                      hint: 'Nom',
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Quantité
                  SizedBox(
                    width: 64,
                    child: _field(
                      controller: _ingQtyController,
                      hint: 'Qté',
                      type: TextInputType.number,
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Unité — dropdown
                  Container(
                    width: 92,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBorder),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedUnit,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 16, color: kPrimary),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kTextPrimary,
                        ),
                        dropdownColor: kSurface,
                        borderRadius: BorderRadius.circular(14),
                        onChanged: (v) =>
                            setState(() => _selectedUnit = v ?? 'g'),
                        items: _units
                            .map((u) => DropdownMenuItem(
                                  value: u,
                                  child: Text(u,
                                      style: GoogleFonts.outfit(
                                          fontSize: 12, color: kTextPrimary),
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Bouton Ajouter ingrédient ─────────────────────────────
              _addButton(
                label: 'Ajouter un ingrédient',
                onTap: () {
                  // LOGIQUE IDENTIQUE À L'ORIGINAL
                  controller.addIngredient(
                    _ingNameController.text,
                    _ingQtyController.text,
                    _selectedUnit,
                  );
                  _ingNameController.clear();
                  _ingQtyController.clear();
                  // L'unité garde sa valeur courante
                },
              ),
              const SizedBox(height: 8),

              // ── Liste des ingrédients ajoutés (Obx) ─────────────────────
              Obx(() => Column(
                    children: controller.formIngredients
                        .asMap()
                        .entries
                        .map((entry) {
                      final idx = entry.key;
                      final ing = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: kPrimaryLight,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: kPrimary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_rounded,
                                size: 16, color: kPrimary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${ing['name']}',
                                style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: kTextPrimary),
                              ),
                            ),
                            Text(
                              '${ing['quantity']} ${ing['measure']}',
                              style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kAccent),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  controller.removeIngredient(idx),
                              child: const Icon(Icons.close_rounded,
                                  size: 16, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )),

              const SizedBox(height: 24),
              const Divider(color: kBorder),
              const SizedBox(height: 16),

              // ════════════════════════════════════════════════════════════
              // SECTION 4 · Étapes
              // ════════════════════════════════════════════════════════════
              _sectionTitle('Étapes'),
              const SizedBox(height: 12),

              // ── Formulaire de saisie d'une étape ─────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _field(
                        controller: _stepNameController,
                        hint: 'Titre étape'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: kBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                      ),
                      child: TextField(
                        controller: _stepDescController,
                        maxLines: 3,
                        style: GoogleFonts.outfit(
                            fontSize: 14, color: kTextPrimary),
                        decoration: InputDecoration(
                          hintText: 'Description',
                          hintStyle: GoogleFonts.outfit(
                              color: kTextSecondary, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _field(
                      controller: _stepDurationController,
                      hint: 'Durée (min)',
                      type: TextInputType.number,
                      icon: Icons.access_time_rounded,
                      compact: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ── Bouton Ajouter étape ──────────────────────────────────
              _addButton(
                label: 'Ajouter une étape',
                onTap: () {
                  // LOGIQUE IDENTIQUE À L'ORIGINAL
                  controller.addStep(
                    _stepNameController.text,
                    _stepDescController.text,
                    _stepDurationController.text,
                  );
                  _stepNameController.clear();
                  _stepDescController.clear();
                  _stepDurationController.clear();
                },
              ),
              const SizedBox(height: 8),

              // ── Liste des étapes ajoutées (Obx) ────────────────────────
              Obx(() => Column(
                    children: controller.formSteps
                        .asMap()
                        .entries
                        .map((entry) {
                      final idx = entry.key;
                      final step = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kPrimaryLight.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: kPrimary.withOpacity(0.15)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Numéro étape
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                  color: kPrimary, shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  '${idx + 1}',
                                  style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${step['name']}',
                                    style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: kTextPrimary),
                                  ),
                                  if (step['description'] != null &&
                                      step['description'].toString().isNotEmpty)
                                    Text(
                                      step['description'],
                                      style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          color: kTextSecondary),
                                    ),
                                  if (step['duration'] != null)
                                    Row(
                                      children: [
                                        const Icon(
                                            Icons.access_time_rounded,
                                            size: 13,
                                            color: kAccent),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${step['duration']} min',
                                          style: GoogleFonts.outfit(
                                              fontSize: 12,
                                              color: kAccent,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => controller.removeStep(idx),
                              child: const Icon(Icons.close_rounded,
                                  size: 16, color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )),

              const SizedBox(height: 24),
              const Divider(color: kBorder),
              const SizedBox(height: 16),

              // ════════════════════════════════════════════════════════════
              // SECTION 5 · Tags
              // ════════════════════════════════════════════════════════════
              _sectionTitle('Tags'),
              const SizedBox(height: 12),

              // Tags ajoutés
              Obx(() {
                if (controller.formTags.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.formTags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: kPrimaryLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: kPrimary.withOpacity(0.25)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(tag,
                                      style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: kTextPrimary)),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () =>
                                        controller.removeTag(tag),
                                    child: const Icon(Icons.close_rounded,
                                        size: 14, color: kTextSecondary),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                );
              }),

              // Saisie tag
              Container(
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        style:
                            GoogleFonts.outfit(fontSize: 14, color: kTextPrimary),
                        decoration: InputDecoration(
                          hintText: 'Nouveau tag',
                          hintStyle: GoogleFonts.outfit(
                              color: kTextSecondary, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          // LOGIQUE IDENTIQUE À L'ORIGINAL
                          controller.addTag(_tagController.text);
                          _tagController.clear();
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                              color: kPrimary, shape: BoxShape.circle),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ════════════════════════════════════════════════════════════
              // BOUTON ENVOYER — LOGIQUE IDENTIQUE À L'ORIGINAL
              // ════════════════════════════════════════════════════════════
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : () async {
                              await controller.submitProposal(
                                _titleController.text,
                                _timeController.text,
                              );
                              // Le controller appelle Get.back() en interne
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: kAccent.withOpacity(0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                      icon: controller.isSubmitting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: controller.isSubmitting.value
                          ? const SizedBox.shrink()
                          : Text(
                              'Envoyer la proposition',
                              style: GoogleFonts.outfit(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                    ),
                  )),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers UI ─────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: kPrimary,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType type = TextInputType.text,
    IconData? icon,
    bool compact = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: GoogleFonts.outfit(
            fontSize: compact ? 13 : 14, color: kTextPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(
              color: kTextSecondary, fontSize: compact ? 13 : 14),
          prefixIcon: icon != null
              ? Icon(icon, size: 18, color: kPrimary.withOpacity(0.6))
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 16, vertical: compact ? 12 : 14),
        ),
      ),
    );
  }

  Widget _addButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
                color: kPrimary, shape: BoxShape.circle),
            child: const Icon(Icons.add_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kPrimary),
          ),
        ],
      ),
    );
  }
}