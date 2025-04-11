import 'dart:convert';

import 'package:recipe_app/models/recipe_model.dart';
import 'package:http/http.dart' as http;

import 'package:recipe_app/models/recipe_search_result.dart';

class APIService {
  Future<List<RecipeSearchResultModel>> searchByRecipeName(String query) async {
    try {
      var url = Uri.https('api.spoonacular.com', 'recipes/complexSearch', {
        "apiKey": "936ac072f83c4cc08505beacf1318293",
        "query": query,
      });
      var response = await http.get(url);
      List<RecipeSearchResultModel> recipes = [];
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      recipes = (jsonResponse["results"] as List)
          .map((e) => RecipeSearchResultModel.fromJson(e))
          .toList();

      return recipes;
    } catch (e) {
      return [];
    }
  }

  Future<List<RecipeSearchResultModel>> searchByIngredients(
      String query) async {
    try {
      var url = Uri.https('api.spoonacular.com', 'recipes/complexSearch', {
        "apiKey": "936ac072f83c4cc08505beacf1318293",
        "query": query,
      });
      var response = await http.get(url);
      List<RecipeSearchResultModel> recipes = [];
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      recipes = (jsonResponse["results"] as List)
          .map((e) => RecipeSearchResultModel.fromJson(e))
          .toList();

      return recipes;
    } catch (e) {
      return [];
    }
  }

  Future<dynamic> getRecipeById(int id) async {
    var url = Uri.https('api.spoonacular.com', "/recipes/$id/information", {
      "apiKey": "936ac072f83c4cc08505beacf1318293",
      "includeNutrition": "false",
    });
    try {
      var response = await http.get(url);
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      RecipeModel recipe = (RecipeModel.fromJson(jsonResponse));
      return recipe;
    } catch (e) {
      return null;
    }
  }
}
