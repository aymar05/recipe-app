import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/models/recipe_model.dart';
import 'package:recipe_app/screens/account/widgets/recipe_tab.dart';
import 'package:recipe_app/screens/account/widgets/single_comment.dart';
import 'package:recipe_app/services/api_service.dart';

class RecipeScreen extends StatefulWidget {
  final int recipeId;

  const RecipeScreen({super.key, required this.recipeId});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final APIService _apiService = Get.find<APIService>();
  RecipeModel? recipeModel;
  bool isLoading = true;

  void _loadData() async {
    try {
      final recipe = await _apiService.getRecipeById(widget.recipeId);
      if (!mounted) return;
      if (recipe == null) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur : recette introuvable')),
        );
        return;
      }
      setState(() {
        recipeModel = recipe;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final r = recipeModel!;
    final imageUrl = (r.image ?? '').isNotEmpty ? r.image : null;
    return Scaffold(
      appBar: AppBar(
        title: Text(r.title ?? 'Recette'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
                ),
              ),
            const SizedBox(height: 20),
            if (r.extendedIngredients != null) RecipeTabWidget(ingredients: r.extendedIngredients!),
            const SizedBox(height: 20),
            Text(
              r.summary ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            if (r.analyzedInstructions != null && r.analyzedInstructions!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: r.analyzedInstructions![0].steps != null
                    ? r.analyzedInstructions![0].steps!
                        .map((step) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Text('${step.number ?? ''}. ${step.step ?? ''}'),
                            ))
                        .toList()
                    : [],
              ),
            const SizedBox(height: 20),
            const Text("Commentaires"),
            const SizedBox(height: 10),
            const SingleComment(),
            const SizedBox(height: 10),
            const SingleComment(),
            const SizedBox(height: 10),
            const SingleComment(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
