import 'dart:convert';

import 'package:recipe_app/models/comment.dart';
import 'package:recipe_app/models/recipe_step.dart';
import 'package:recipe_app/models/tag.dart';

import 'ingredient.dart';

class Recipe {
  int? id;
  String? title;
  String? image;
  int? evaluation;
  int? time;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? imageUrl;
  List<RecipeStep>? steps;
  List<Ingredient>? ingredients;
  List<Comment>? comments;
  List<Tag>? tags;

  Recipe({
    this.id,
    this.title,
    this.image,
    this.evaluation,
    this.time,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.steps,
    this.ingredients,
    this.comments,
    this.tags,
  });

  Recipe copyWith({
    int? id,
    String? title,
    String? image,
    int? evaluation,
    int? time,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    List<RecipeStep>? steps,
    List<Ingredient>? ingredients,
    List<Comment>? comments,
    List<Tag>? tags,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      evaluation: evaluation ?? this.evaluation,
      time: time ?? this.time,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      steps: steps ?? this.steps,
      ingredients: ingredients ?? this.ingredients,
      comments: comments ?? this.comments,
      tags: tags ?? this.tags,
    );
  }

  factory Recipe.fromRawJson(String str) {
    return Recipe.fromJson(json.decode(str));
  }

  String toRawJson() {
    return json.encode(toJson());
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json["id"],
      title: json["title"],
      image: json["image"],
      evaluation: json["evaluation"],
      time: json["time"],
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.parse(json["updated_at"]),
      imageUrl: json["image_url"],
      steps: json["steps"] == null
          ? []
          : List<RecipeStep>.from(
              json["steps"]!.map((x) => RecipeStep.fromJson(x))),
      ingredients: json["ingredients"] == null
          ? []
          : List<Ingredient>.from(
              json["ingredients"]!.map((x) => Ingredient.fromJson(x))),
      comments: json["comments"] == null
          ? []
          : List<Comment>.from(
              json["comments"]!.map((x) => Comment.fromJson(x))),
      tags: json["tags"] == null
          ? []
          : List<Tag>.from(json["tags"]!.map((x) => Tag.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "image": image,
      "evaluation": evaluation,
      "time": time,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
      "image_url": imageUrl,
      "steps": steps == null
          ? []
          : List<dynamic>.from(steps!.map((x) => x.toJson())),
      "ingredients": ingredients == null
          ? []
          : List<dynamic>.from(ingredients!.map((x) => x.toJson())),
      "comments":
          comments == null ? [] : List<dynamic>.from(comments!.map((x) => x)),
      "tags":
          tags == null ? [] : List<dynamic>.from(tags!.map((x) => x.toJson())),
    };
  }
}
