import 'dart:convert';

class Comment {
  int? id;
  String? text;
  int? recipeId;
  int? userId;
  DateTime? createdAt;
  DateTime? updatedAt;
  CommentUser? user; // Ajout de l'objet User

  Comment({
    this.id,
    this.text,
    this.recipeId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  Comment copyWith({
    int? id,
    String? text,
    int? recipeId,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    CommentUser? user,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      recipeId: recipeId ?? this.recipeId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
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
      // On récupère l'objet user s'il existe dans la réponse API
      user: json["user"] != null ? CommentUser.fromJson(json["user"]) : null,
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
      "user": user?.toJson(),
    };
  }
}

// Petite classe utilitaire pour récupérer juste le nom de l'user
class CommentUser {
  int? id;
  String? name;

  CommentUser({this.id, this.name});

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}