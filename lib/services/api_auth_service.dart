import 'package:get/get.dart';
import 'package:recipe_app/services/storage_service.dart';
import '../models/user.dart'; // Assurez-vous que le chemin est correct

class ApiAuthService extends GetxService {
  static ApiAuthService get to => Get.find();

  final _storageService = StorageService();

  final Rxn<String> _token = Rxn<String>();
  // 1. Ajouter une variable réactive pour l'utilisateur
  final Rxn<User> _currentUser = Rxn<User>();

  String? get token => _token.value;
  // 2. Getter pour accéder à l'utilisateur depuis l'UI
  User? get user => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    _loadAuthData();
  }

  // 3. Charger le token ET l'utilisateur au démarrage
  Future<void> _loadAuthData() async {
    _token.value = await _storageService.getAuthToken();
    _currentUser.value = await _storageService.getAuthUser();
  }

  Future<void> setToken(String tokenValue) async {
    _token.value = tokenValue;
    await _storageService.setAuthToken(tokenValue);
  }

  // 4. Méthode pour définir l'utilisateur (à appeler lors du login ou edit profile)
  Future<void> setUser(User user) async {
    _currentUser.value = user;
    await _storageService.setAuthUser(user);
  }

  Future<void> clearToken() async {
    _token.value = null;
    _currentUser.value = null; // 5. Vider l'utilisateur à la déconnexion
    await _storageService.clear();
  }

  bool get isAuthenticated => _token.value != null && _token.value!.isNotEmpty;
}