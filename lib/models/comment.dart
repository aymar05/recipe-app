import 'dart:convert';

class Comment {
  int? id;
  String? text;
  int? recipeId;
  int? userId;
  DateTime? createdAt;
  DateTime? updatedAt;

  Comment({
    this.id,
    this.text,
    this.recipeId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  Comment copyWith({
    int? id,
    String? text,
    int? recipeId,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      recipeId: recipeId ?? this.recipeId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Comment.fromRawJson(String str) {
    return Comment.fromJson(json.decode(str));
  }

  String toRawJson() {
    return json.encode(toJson());
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json["id"],
      text: json["text"],
      recipeId: json["recipe_id"],
      userId: json["user_id"],
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
      "text": text,
      "recipe_id": recipeId,
      "user_id": userId,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    };
  }
}
