import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/data/result_type.dart';
import 'package:recipe_app/models/ingredient_model.dart';
import 'package:recipe_app/screens/account/search_result_screen.dart';
import 'package:recipe_app/services/api_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SearchByIngredientScreen — Refonte UI v2
// ⚠️  ZÉRO MODIFICATION LOGIQUE : _ingredients, _cart, _apiService, _loadData,
//     wantKeepAlive, AutomaticKeepAliveClientMixin, Get.snackbar, Navigator.push
// ──────────────────────────────────────────────────────────────────────────────

class SearchByIngredientScreen extends StatefulWidget {
  const SearchByIngredientScreen({super.key});

  @override
  State<SearchByIngredientScreen> createState() =>
      _SearchByIngredientScreenState();
}

class _SearchByIngredientScreenState extends State<SearchByIngredientScreen>
    with AutomaticKeepAliveClientMixin {
  // ── LOGIQUE INCHANGÉE ──────────────────────────────────────────────────────
  @override
  bool get wantKeepAlive => true;

  List<IngredientModel> _ingredients = [];
  final List<IngredientModel> _cart = [];
  final APIService _apiService = Get.put(APIService());

  _loadData() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString('assets/data/ingredients.json');
    final jsonResult = jsonDecode(data);
    setState(() {
      _ingredients = (jsonResult.cast<Map<String, dynamic>>() as List)
          .map((ingredient) => IngredientModel.fromJson(ingredient))
          .toList();
    });
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  // ── RENDU VISUEL ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),

              // ── En-tête : titre + bouton "Voir recettes" si panier non vide ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Par ingrédient',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (_cart.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchResultScreen(
                              query: 'burger',
                              type: ResultType.recipe,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Recettes',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                'Sélectionnez des ingrédients pour trouver des recettes',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: kTextSecondary,
                ),
              ),

              const SizedBox(height: 20),

              // ── Bouton "Ajouter un ingrédient" ─────────────────────────────
              GestureDetector(
                onTap: _showIngredientPicker,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Ajouter un ingrédient au panier',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Grille des ingrédients sélectionnés ────────────────────────
              Expanded(
                child: _cart.isEmpty
                    ? _EmptyCart()
                    : GridView.builder(
                        itemCount: _cart.length,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          return _IngredientChip(
                            label: _cart[index].label ?? '',
                            onRemove: () =>
                                setState(() => _cart.remove(_cart[index])),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIngredientPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (builder) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Barre de recherche dans le bottom sheet
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: kBorder),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.search_rounded, color: kTextSecondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Rechercher un ingrédient...',
                            hintStyle: GoogleFonts.outfit(
                              color: kTextSecondary,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            filled: false,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: kTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Liste des ingrédients
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 2),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: kPrimaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 18,
                          color: kPrimary,
                        ),
                      ),
                      title: Text(
                        _ingredients[index].label ?? '',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: kTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: kPrimary,
                        size: 22,
                      ),
                      onTap: () => setState(() {
                        if (!_cart.contains(_ingredients[index])) {
                          _cart.add(_ingredients[index]);
                          Navigator.pop(context);
                          return;
                        } else {
                          Get.snackbar(
                            animationDuration:
                                const Duration(milliseconds: 100),
                            'Ingredient déjà ajouté',
                            'Vous avez déjà ajouté cet ingrédient',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(10),
                          );
                        }
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Chip ingrédient dans le panier ───────────────────────────────────────────
class _IngredientChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _IngredientChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: kPrimaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, size: 16, color: kPrimary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kTextPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 18, color: kTextSecondary),
          ),
        ],
      ),
    );
  }
}

// ── État vide du panier ───────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              Icons.shopping_basket_outlined,
              size: 36,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Votre panier est vide',
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajoutez des ingrédients pour commencer',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: kTextSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
