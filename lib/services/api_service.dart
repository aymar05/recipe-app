import 'dart:convert';
import 'package:get/get.dart';
import 'package:recipe_app/models/recipe_model.dart';
import 'package:recipe_app/models/recipe_search_result.dart';
import 'api_client.dart';

class APIService {
  final ApiClient _client;

  APIService({ApiClient? client}) : _client = client ?? Get.find<ApiClient>();

  Future<List<RecipeSearchResultModel>> searchByRecipeName(String query) async {
    try {
      final body = await _client.getJson('/recipes', params: {'name': query});
      if (body is List) {
        return body.map((e) {
          final map = (e is Map) ? Map<String, dynamic>.from(e) : <String, dynamic>{};
          return RecipeSearchResultModel.fromJson(map);
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<RecipeSearchResultModel>> searchByIngredients(String ingredientsCsv) async {
    try {
      final body = await _client.getJson('/recipes', params: {'ingredients': ingredientsCsv});
      if (body is List) {
        return body.map((e) {
          final map = (e is Map) ? Map<String, dynamic>.from(e) : <String, dynamic>{};
          return RecipeSearchResultModel.fromJson(map);
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<RecipeModel?> getRecipeById(int id) async {
    try {
      final body = await _client.getJson('/recipes/$id');
      if (body == null) return null;
      if (body is Map) {
        return RecipeModel.fromJson(Map<String, dynamic>.from(body));
      }
      if (body is Map && body['data'] != null && body['data'] is Map) {
        return RecipeModel.fromJson(Map<String, dynamic>.from(body['data']));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<RecipeModel?> createRecipe(RecipeModel recipe) async {
    try {
      final body = await _client.postJson('/recipes', body: recipe.toJson());
      if (body == null) return null;
      if (body is Map) return RecipeModel.fromJson(Map<String, dynamic>.from(body));
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateRecipe(int id, RecipeModel recipe) async {
    try {
      await _client.putJson('/recipes/$id', body: recipe.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRecipe(int id) async {
    try {
      await _client.deleteJson('/recipes/$id');
      return true;
    } catch (e) {
      return false;
    }
  }
}