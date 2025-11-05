import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/screens/account/root_screen.dart';
import 'package:recipe_app/screens/auth_wrapper.dart';
import 'package:recipe_app/screens/login_screen.dart';
import 'package:recipe_app/screens/profile_page.dart';
import 'package:recipe_app/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// IMPORTATIONS MISES À JOUR
import 'package:recipe_app/services/api_auth_service.dart';
import 'package:recipe_app/services/api_client.dart';
import 'package:recipe_app/services/api_service.dart';

// Pas besoin d'initialiser StorageService ici, ApiAuthService s'en occupe.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation des services avec GetX
  await initServices();
  
  runApp(const App());
}

// Une fonction propre pour initialiser les services
Future<void> initServices() async {
  // Enregistre ApiAuthService. Son `onInit` chargera le token.
  Get.put(ApiAuthService());
  
  // Enregistre ApiClient
  Get.put(ApiClient(baseUrl: 'http://192.168.1.18:8000'));
  
  // Enregistre APIService
  Get.put(APIService());
}


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
          name: "/root",
          page: () => const RootScreen(),
        ),
        GetPage(
          name: "/login",
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: "/register",
          page: () => const RegisterScreen(),
        ),
      ],
      theme: themeData,
      home: const AuthWrapper(),
    );
  }
}