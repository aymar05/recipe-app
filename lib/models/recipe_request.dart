import 'dart:convert';
import 'package:recipe_app/models/ingredient.dart';
import 'package:recipe_app/models/recipe_step.dart';
import 'package:recipe_app/models/tag.dart';

class RecipeRequest {
  int? id;
  String? title;
  String? image;
  int? preparationTime; // Attention: Laravel utilise 'preparation_time'
  String? status; // 'pending', 'approved', 'rejected'
  String? imageUrl;
  List<RecipeRequestStep>? steps;
  List<RecipeRequestIngredient>? ingredients;
  List<RecipeRequestTag>? tags;
  DateTime? createdAt;

  RecipeRequest({
    this.id,
    this.title,
    this.image,
    this.preparationTime,
    this.status,
    this.imageUrl,
    this.steps,
    this.ingredients,
    this.tags,
    this.createdAt,
  });

  factory RecipeRequest.fromJson(Map<String, dynamic> json) {
    return RecipeRequest(
      id: json["id"],
      title: json["title"],
      image: json["image"],
      preparationTime: json["preparation_time"],
      status: json["status"],
      imageUrl: json["image_url"],
      createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
      steps: json["steps"] != null
          ? List<RecipeRequestStep>.from(json["steps"].map((x) => RecipeRequestStep.fromJson(x)))
          : [],
      ingredients: json["ingredients"] != null
          ? List<RecipeRequestIngredient>.from(json["ingredients"].map((x) => RecipeRequestIngredient.fromJson(x)))
          : [],
      tags: json["tags"] != null
          ? List<RecipeRequestTag>.from(json["tags"].map((x) => RecipeRequestTag.fromJson(x)))
          : [],
    );
  }
}

// Sous-modèles spécifiques pour les Requests (car les tables sont différentes coté Laravel)

class RecipeRequestStep {
  String? name;
  String? description;
  int? duration;

  RecipeRequestStep({this.name, this.description, this.duration});

  factory RecipeRequestStep.fromJson(Map<String, dynamic> json) => RecipeRequestStep(
    name: json["name"],
    description: json["description"],
    duration: json["duration"],
  );
}

class RecipeRequestIngredient {
  String? name;
  int? quantity;
  String? measure;

  RecipeRequestIngredient({this.name, this.quantity, this.measure});

  factory RecipeRequestIngredient.fromJson(Map<String, dynamic> json) => RecipeRequestIngredient(
    name: json["name"],
    quantity: json["quantity"],
    measure: json["measure"],
  );
}

class RecipeRequestTag {
  String? name;

  RecipeRequestTag({this.name});

  factory RecipeRequestTag.fromJson(Map<String, dynamic> json) => RecipeRequestTag(
    name: json["name"],
  );
}