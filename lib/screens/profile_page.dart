import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/services/api_auth_service.dart';
import 'package:recipe_app/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
              Get.back(); // ferme le dialog
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
    return Scaffold(
      // AppBar removed
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar vide / icône
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),

            const SizedBox(height: 20),

            // Infos utilisateur
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Ton nom', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('email@exemple.com', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),

            const SizedBox(height: 40),

            // Menu items
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier le profil'),
              onTap: () {
                Get.toNamed('/editProfile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Changer le mot de passe'),
              onTap: () {
                Get.toNamed('/changePassword');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('À propos'),
              onTap: () {
                // affiche un dialog simple ou navigue
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
      // BottomNavigationBar removed
    );
  }
}
