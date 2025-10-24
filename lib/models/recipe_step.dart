import 'dart:convert';

class RecipeStep {
  int? id;
  String? name;
  String? description;
  int? duration;
  int? recipeId;
  DateTime? createdAt;
  DateTime? updatedAt;

  RecipeStep({
    this.id,
    this.name,
    this.description,
    this.duration,
    this.recipeId,
    this.createdAt,
    this.updatedAt,
  });

  RecipeStep copyWith({
    int? id,
    String? name,
    String? description,
    int? duration,
    int? recipeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecipeStep(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      recipeId: recipeId ?? this.recipeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory RecipeStep.fromRawJson(String str) {
    return RecipeStep.fromJson(json.decode(str));
  }

  String toRawJson() {
    return json.encode(toJson());
  }

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      duration: json["duration"],
      recipeId: json["recipe_id"],
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.parse(json["updated_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "duration": duration,
      "recipe_id": recipeId,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    };
  }
}
