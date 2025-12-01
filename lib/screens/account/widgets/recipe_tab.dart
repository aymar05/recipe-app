import 'package:flutter/material.dart';
import 'package:recipe_app/models/ingredient.dart';

class RecipeTabWidget extends StatelessWidget {
  final List<Ingredient> ingredients;

  const RecipeTabWidget({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ingrédients",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ingredients.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final ingredient = ingredients[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      ingredient.name ?? "Ingrédient",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  // Affichage de la quantité et de l'unité (ex: "200 g")
                  if (ingredient.quantity != null || ingredient.measure != null)
                    Text(
                      "${ingredient.quantity ?? ''} ${ingredient.measure ?? ''}",
                      style: const TextStyle(
                        color: Colors.grey, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}