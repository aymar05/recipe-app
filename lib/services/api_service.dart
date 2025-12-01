import 'package:get/get.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/comment.dart';
import 'api_client.dart';

class APIService {
  final ApiClient _client;

  APIService({ApiClient? client}) : _client = client ?? Get.find<ApiClient>();

  // --- RECETTES (Listing avec Pagination) ---

  // Modification ici : on accepte un numéro de page
  Future<List<Recipe>> getRecipes({int page = 1}) async {
    try {
      // On envoie le paramètre 'page' standard de Laravel
      final params = {'page': page.toString()};

      final body = await _client.getJson('/api/recipes', params: params);

      // CAS 1 : Pagination Laravel (clé 'data')
      if (body is Map && body['data'] != null && body['data'] is List) {
        final List dataList = body['data'];
        return dataList.map((e) {
          final map = (e is Map) ? Map<String, dynamic>.from(e) : <String, dynamic>{};
          return Recipe.fromJson(map);
        }).toList();
      }

      // CAS 2 : Liste simple (Fallback)
      if (body is List) {
        return body.map((e) {
          final map = (e is Map) ? Map<String, dynamic>.from(e) : <String, dynamic>{};
          return Recipe.fromJson(map);
        }).toList();
      }

      return [];
    } catch (e) {
      print("Erreur getRecipes: $e");
      return [];
    }
  }

  // --- RECHERCHE DÉDIÉE ---
  
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final body = await _client.getJson('/api/recipes/search', params: {'query': query});

      if (body is Map && body['data'] != null && body['data'] is List) {
        final List dataList = body['data'];
        return dataList.map((e) {
          final map = (e is Map) ? Map<String, dynamic>.from(e) : <String, dynamic>{};
          return Recipe.fromJson(map);
        }).toList();
      }

      if (body is List) {
        return body.map((e) {
          final map = (e is Map) ? Map<String, dynamic>.from(e) : <String, dynamic>{};
          return Recipe.fromJson(map);
        }).toList();
      }

      return [];
    } catch (e) {
      print("Erreur searchRecipes: $e");
      return [];
    }
  }

  // --- DÉTAIL RECETTE ---

  Future<Recipe?> getRecipeById(int id) async {
    try {
      final body = await _client.getJson('/api/recipes/$id');
      if (body == null) return null;
      
      if (body is Map) {
        if (body['data'] != null && body['data'] is Map) {
           return Recipe.fromJson(Map<String, dynamic>.from(body['data']));
        }
        return Recipe.fromJson(Map<String, dynamic>.from(body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- COMMENTAIRES ---

  Future<Comment?> postComment(int recipeId, String text) async {
    try {
      final body = await _client.postJson(
        '/api/recipes/$recipeId/comments', 
        body: {'text': text}
      );
      
      if (body != null && body is Map) {
        if (body.containsKey('data')) {
           return Comment.fromJson(Map<String, dynamic>.from(body['data']));
        }
        return Comment.fromJson(Map<String, dynamic>.from(body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- FAVORIS ---

  Future<List<Recipe>> getFavorites() async {
    try {
      final body = await _client.getJson('/api/favorites');

      if (body is Map && body['data'] != null && body['data'] is List) {
         return (body['data'] as List).map((e) => Recipe.fromJson(e)).toList();
      }
      if (body is List) {
        return body.map((e) => Recipe.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> addToFavorites(int recipeId) async {
    try {
      await _client.postJson('/api/recipes/$recipeId/favorites', body: {});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavorite(int recipeId) async {
    try {
      await _client.deleteJson('/api/favorites/$recipeId');
      return true;
    } catch (e) {
      return false;
    }
  }
}