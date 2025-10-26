import 'dart:convert';

import 'package:recipe_app/models/user.dart';

class AuthResponse {
  User? user;
  String? token;

  AuthResponse({
    this.user,
    this.token,
  });

  AuthResponse copyWith({
    User? user,
    String? token,
  }) {
    return AuthResponse(
      user: user ?? this.user,
      token: token ?? this.token,
    );
  }

  factory AuthResponse.fromRawJson(String str) {
    return AuthResponse.fromJson(json.decode(str));
  }

  String toRawJson() {
    return json.encode(toJson());
  }

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      token: json["token"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
        "user": user?.toJson(),
        "token": token,
      };
  }
}
