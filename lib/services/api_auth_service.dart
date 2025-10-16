import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

// =================================================================
// Implémentation Mock de FlutterSecureStorage
// Ceci simule le comportement du package réel pour des fins de compilation/test
// =================================================================
class FlutterSecureStorage {
  // Stockage simple en mémoire pour simuler la sécurisation
  // 'final' a été supprimé pour permettre la mutation.
  Map<String, String> _data = {}; 

  // CORRECTION: Suppression de 'const' car la classe contient un état interne mutable (_data).
  FlutterSecureStorage();

  Future<void> write({required String key, required String value}) async {
    _data[key] = value;
    // print('Stocké: $key = $value'); // Pour le débogage
  }

  Future<String?> read({required String key}) async {
    // print('Lu: $key = ${_data[key]}'); // Pour le débogage
    return _data[key];
  }

  Future<void> delete({required String key}) async {
    // print('Supprimé: $key'); // Pour le débogage
    _data.remove(key);
  }
}


class ApiAuthService extends GetxController {
  final isAuthenticated = false.obs;
  static ApiAuthService get to => Get.find();
  

  static const String _baseUrl = "http://192.168.1.196:8000/api/register";

  // CORRECTION: Suppression de 'const' lors de l'instanciation.
  final _storage = FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    // Vérifie l'état d'authentification au démarrage de l'application
    checkAuthStatus();
  }



  /// Stocke le token reçu
  Future<void> _storeToken(String token) async {
    await _storage.write(key: 'authToken', value: token);
  }

  /// Récupère le token stocké
  Future<String?> getToken() async {
    return await _storage.read(key: 'authToken');
  }

  /// Vérifie si l'utilisateur est connecté en lisant le token
  void checkAuthStatus() async {
    final token = await getToken();
    isAuthenticated.value = token != null;
    // Idéalement, faire un appel API '/user' pour valider le token et récupérer les infos utilisateur
  }


  
  /// Déconnexion: Supprime le token local et met à jour l'état.
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        // Optionnel : Appel API pour invalider le token côté serveur
        await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token', 
          },
        );
      } catch (e) {
        print("Erreur lors de l'appel /logout : $e");
      }
    }
    
    await _storage.delete(key: 'authToken');
    isAuthenticated.value = false;
  }

  /// Connexion: Appelle l'API, stocke le token et met à jour l'état.
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'device_name': 'mobile_app', // Requis par Laravel Sanctum
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (responseData.containsKey('token')) {
          await _storeToken(responseData['token'] as String);
          isAuthenticated.value = true; // Succès : met à jour l'état
          return true; 
        } else {
          print('Token non trouvé dans la réponse de connexion.');
          return false;
        }
      } else {
        print('Échec de la connexion : ${response.statusCode}');
        // L'API peut renvoyer des informations utiles dans response.body
        return false;
      }
    } catch (e) {
      print('Erreur réseau/générale lors de la connexion : $e');
      return false;
    }
  }

  /// Inscription: Appelle l'API, stocke le token (si retourné) et met à jour l'état.
  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'), 
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, // Nécessaire pour Laravel, on suppose que le contrôle de l'UI est bon.
          'device_name': 'mobile_app', 
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Si l'API renvoie un token à l'inscription :
        if (responseData.containsKey('token')) {
          await _storeToken(responseData['token'] as String);
          isAuthenticated.value = true; // Succès : met à jour l'état
        }
        return true; 
      } else {
        print('Échec de l\'inscription : ${response.statusCode}');
        print('Corps de la réponse : ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur réseau/générale lors de l\'inscription : $e');
      return false;
    }
  }
}
