import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Import nécessaire pour XFile
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/models/comment.dart';
import 'package:recipe_app/models/recipe_request.dart';
import 'api_client.dart';
import 'package:recipe_app/models/user.dart';
import 'package:image_picker/image_picker.dart';

class APIService {
  final ApiClient _client;

  APIService({ApiClient? client}) : _client = client ?? Get.find<ApiClient>();

  // --- RECETTES ---

  Future<List<Recipe>> getRecipes({int page = 1}) async {
    try {
      final params = {'page': page.toString()};
      final body = await _client.getJson('/api/recipes', params: params);

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
      print("Erreur getRecipes: $e");
      return [];
    }
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      final body = await _client.getJson('/api/recipes/search', params: {'query': query});

      if (body is Map && body['data'] != null && body['data'] is List) {
        return (body['data'] as List).map((e) => Recipe.fromJson(e)).toList();
      }
      if (body is List) {
        return body.map((e) => Recipe.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Erreur searchRecipes: $e");
      return [];
    }
  }

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

  // --- PROPOSITIONS (RECIPE REQUESTS) ---

  Future<List<RecipeRequest>> getUserProposals() async {
    try {
      final body = await _client.getJson('/api/recipe-requests');

      if (body is Map && body['data'] != null && body['data'] is List) {
        return (body['data'] as List).map((e) => RecipeRequest.fromJson(e)).toList();
      }
      
      if (body is List) {
        return body.map((e) => RecipeRequest.fromJson(e)).toList();
      }
      
      return [];
    } catch (e) {
      print("Erreur getUserProposals: $e");
      return [];
    }
  }

  // MODIFICATION ICI POUR LE WEB : On prend le XFile
  Future<bool> createRecipeProposal({
    required String title,
    required int preparationTime,
    required XFile imageFile, // On passe l'objet XFile
    required List<Map<String, dynamic>> ingredients,
    required List<Map<String, dynamic>> steps,
    required List<String> tags,
  }) async {
    try {
      final Map<String, String> fields = {};

      fields['title'] = title;
      fields['preparation_time'] = preparationTime.toString();

      for (int i = 0; i < ingredients.length; i++) {
        fields['ingredients[$i][name]'] = ingredients[i]['name'].toString();
        fields['ingredients[$i][quantity]'] = ingredients[i]['quantity'].toString();
        fields['ingredients[$i][measure]'] = ingredients[i]['measure'].toString();
      }

      for (int i = 0; i < steps.length; i++) {
        fields['steps[$i][name]'] = steps[i]['name'].toString();
        fields['steps[$i][description]'] = steps[i]['description'].toString();
        fields['steps[$i][duration]'] = steps[i]['duration'].toString();
      }

      for (int i = 0; i < tags.length; i++) {
        fields['tags[$i]'] = tags[i];
      }

      // Lecture des bytes (Compatible Web)
      final List<int> imageBytes = await imageFile.readAsBytes();

      await _client.postMultipart(
        '/api/recipe-requests', 
        fileBytes: imageBytes,
        filename: imageFile.name, 
        fileField: 'image',
        fields: fields,
      );

      return true;
    } catch (e) {
      print("Erreur createRecipeProposal: $e");
      return false;
    }
  }

  Future<RecipeRequest?> getRecipeRequestById(int id) async {
    try {
      // Route : GET /recipe-requests/{id}
      final body = await _client.getJson('/api/recipe-requests/$id');
      
      if (body == null) return null;

      if (body is Map) {
        // Gestion au cas où l'API renvoie { "data": { ... } }
        if (body['data'] != null && body['data'] is Map) {
           return RecipeRequest.fromJson(Map<String, dynamic>.from(body['data']));
        }
        // Cas standard : renvoie l'objet direct
        return RecipeRequest.fromJson(Map<String, dynamic>.from(body));
      }
      return null;
    } catch (e) {
      print("Erreur getRecipeRequestById: $e");
      return null;
    }
  }

   // --- PROFIL & MOT DE PASSE ---

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Route définie dans api.php : prefix('profile') -> put('password')
      // Donc l'URL est /profile/password
      await _client.putJson(
        '/api/profile/password',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword, 
        },
      );
      return true;
    } catch (e) {
      print("Erreur updatePassword: $e");
      rethrow; 
    }
  }


  
  // --- GESTION PROFIL UTILISATEUR ---

  // 1. Récupérer le profil actuel (pour rafraîchir les données)
  Future<User?> getProfile() async {
    try {
      // Route: GET /profile (ProfileController@show)
      final body = await _client.getJson('/api/profile');
      if (body != null && body is Map) {
        return User.fromJson(Map<String, dynamic>.from(body));
      }
      return null;
    } catch (e) {
      print("Erreur getProfile: $e");
      return null;
    }
  }

  // 2. Mettre à jour le texte (Nom uniquement, selon ta demande)
  Future<User?> updateProfile({required String name}) async {
    try {
      // Route: PUT /profile (ProfileController@updateProfile)
      final body = await _client.putJson('/api/profile', body: {
        'name': name,
        // On n'envoie pas l'email car le backend ne le traite pas ou on ne veut pas le modif
      });

      if (body != null && body is Map) {
        return User.fromJson(Map<String, dynamic>.from(body));
      }
      return null;
    } catch (e) {
      print("Erreur updateProfile: $e");
      rethrow;
    }
  }

  // 3. Mettre à jour la photo (ProfileController@updatePicture)
  Future<bool> updateProfilePicture(XFile imageFile) async {
    try {
      final List<int> imageBytes = await imageFile.readAsBytes();

      // Route: POST /profile/picture
      await _client.postMultipart(
        '/api/profile/picture',
        fileBytes: imageBytes,
        filename: imageFile.name,
        fileField: 'image', // Le nom attendu par Laravel: $request->file('image')
        fields: {}, 
      );
      
      // Le controller renvoie 204 No Content, donc si pas d'erreur, c'est bon.
      return true;
    } catch (e) {
      print("Erreur updateProfilePicture: $e");
      return false;
    }
  }
}