import 'dart:convert';

class Tag {
  int? id;
  String? name;

  Tag({
    this.id,
    this.name,
  });

  Tag copyWith({
    int? id,
    String? name,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory Tag.fromRawJson(String str) {
    return Tag.fromJson(json.decode(str));
  }

  String toRawJson() {
    return json.encode(toJson());
  }

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json["id"],
      name: json["name"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
}
