import 'dart:convert';

class RegisterRequest {
  String? name;
  String? email;
  String? password;

  RegisterRequest({
    this.name,
    this.email,
    this.password,
  });

  RegisterRequest copyWith({
    String? name,
    String? email,
    String? password,
  }) {
    return RegisterRequest(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
    };
  }
}
