import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/services/api_auth_service.dart';
import 'package:recipe_app/services/auth_service.dart';
import 'package:recipe_app/screens/account/editProfil_screen.dart';
import 'package:recipe_app/screens/account/changePassword_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout() async {
    final authService = AuthService();
    try {
      await authService.logout();
    } catch (_) {}
    await ApiAuthService.to.clearToken();
    Get.offAllNamed('/login');
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _logout();
            },
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Récupération du service
    final apiAuthService = ApiAuthService.to;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // On utilise Obx pour rendre cette partie réactive
            Obx(() {
              final user = apiAuthService.user;
              
              // Gestion du cas où l'utilisateur n'est pas encore chargé ou null
              if (user == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // Avatar
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),

                  const SizedBox(height: 20),

                  // Infos utilisateur dynamiques
                  Text(
                    // Assurez-vous que votre modèle User a bien les champs 'name' ou 'username'
                    user.name ?? 'Nom inconnu', 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? 'Pas d\'email', 
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              );
            }),

            const SizedBox(height: 40),

            // Menu items
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier le profil'),
              onTap: () {
                Get.to(() => EditprofilScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Changer le mot de passe'),
              onTap: () {
                Get.to(() => ChangePasswordScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('À propos'),
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('À propos'),
                    content: const Text('Recipe App v1.0'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Fermer'),
                      ),
                    ],
                  ),
                );
              },
            ),

            const Divider(),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
              onTap: () => _showLogoutDialog(context),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}