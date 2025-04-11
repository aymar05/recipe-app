class RecipeSearchResultModel {
  int? id;
  String? title;
  String? image;

  RecipeSearchResultModel({this.id, this.title, this.image});

  RecipeSearchResultModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['image'] = image;
    return data;
  }
}
