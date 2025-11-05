import 'package:recipe_app/screens/account/root_screen.dart';
import 'package:recipe_app/screens/login_screen.dart';
import 'package:flutter/material.dart'; 
import 'package:get/get.dart';
import 'package:recipe_app/services/api_auth_service.dart'; // Importation nécessaire

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilise Obx pour écouter l'état réactif isAuthenticated de ApiAuthService
    return Obx(() {
      // Référence au contrôleur initialisé dans main.dart
      final authService = ApiAuthService.to;

      if (authService.isAuthenticated) {
        // Utilisateur connecté
        return const RootScreen();
      } else {
        // Utilisateur déconnecté
        return const LoginScreen();
      }
      
    
    });
  }
}
