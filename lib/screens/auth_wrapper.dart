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

      // Votre ApiAuthService.to.checkAuthStatus() a déjà été appelé dans onInit.
      // Si getToken est en cours (ou si le token est null), isAuthenticated.value sera false.
      
      // Ici, on vérifie directement l'état réactif du service
      if (authService.isAuthenticated.value) {
        // Utilisateur connecté
        return const RootScreen();
      } else {
        // Utilisateur déconnecté
        return const LoginScreen();
      }
      
      // NOTE IMPORTANTE: Le ApiAuthService.to.checkAuthStatus() gère l'état 'loading' 
      // et met à jour isAuthenticated. Pour une implémentation plus stricte, 
      // vous pourriez ajouter un état 'isLoading' dans ApiAuthService.
      
      // Étant donné que ApiAuthService.to.checkAuthStatus() est asynchrone, 
      // il y a un très court laps de temps où isAuthenticated.value est false
      // avant que le token ne soit lu. Pour éviter un flash rapide vers LoginScreen 
      // si l'utilisateur est déjà connecté, vous devriez vérifier si le 
      // 'checkAuthStatus' est terminé, ou accepter le comportement actuel où l'écran 
      // de connexion/racine s'affiche presque immédiatement.
    });
  }
}
