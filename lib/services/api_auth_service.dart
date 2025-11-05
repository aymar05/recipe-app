import 'package:get/get.dart';
import 'package:recipe_app/services/storage_service.dart';

class ApiAuthService extends GetxService {

  static ApiAuthService get to => Get.find();

  final _storageService = StorageService();

  final Rxn<String> _token = Rxn<String>();

  String? get token => _token.value;

  @override
  void onInit() {
    super.onInit();
   _loadTokenFromStorage();
  }

  Future<void> _loadTokenFromStorage() async {
    _token.value = await _storageService.getAuthToken();
  }

  Future<void> setToken(String tokenValue) async {
    _token.value = tokenValue;
    await _storageService.setAuthToken(tokenValue);
  }

  Future<void> clearToken() async {
    _token.value = null;
    await _storageService.clear();
  }

  bool get isAuthenticated => _token.value != null && _token.value!.isNotEmpty;
}