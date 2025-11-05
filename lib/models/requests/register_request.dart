import 'dart:convert';

class RegisterRequest {
  String? name;
  String? email;
  String? password;
  String? passwordConfirmation;

  RegisterRequest({
    this.name,
    this.email,
    this.password,
    this.passwordConfirmation,
  });

  RegisterRequest copyWith({
    String? name,
    String? email,
    String? password,
    String? passwordConfirmation,
  }) {
    return RegisterRequest(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
    );
  }

  factory RegisterRequest.fromRawJson(String str) {
    return RegisterRequest.fromJson(json.decode(str));
  }

  String toRawJson() {
    return json.encode(toJson());
  }

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      name: json["name"],
      email: json["email"],
      password: json["password"],
      passwordConfirmation: json["password_confirmation"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation,
    };
  }
}
