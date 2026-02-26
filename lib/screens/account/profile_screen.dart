import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/screens/account/changePassword_screen.dart'; // Assurez-vous du nom du fichier
import 'package:recipe_app/screens/account/edit_profile_form_screen.dart'; // Import du formulaire
import 'package:recipe_app/services/api/config/constants.dart';
import 'package:recipe_app/services/api_auth_service.dart';
import 'package:recipe_app/services/auth_service.dart';

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
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Mon Profil", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        automaticallyImplyLeading: false, // Pas de flèche retour si c'est un onglet principal
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- ZONE DYNAMIQUE (OBS) ---
            Obx(() {
              final user = ApiAuthService.to.user;
              
              if (user == null) return const CircularProgressIndicator();

              // Gestion image
              ImageProvider? imageProvider;
              if (user.imageUrl != null) {
                 String url = user.imageUrl!.startsWith('http') 
                    ? user.imageUrl! 
                    : "${Constants.apiBaseUrl}/${user.imageUrl!}";
                 imageProvider = NetworkImage(url);
              }

              return Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      color: Colors.white,
                      image: imageProvider != null 
                          ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                          : null,
                    ),
                    child: imageProvider == null 
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name ?? 'Utilisateur',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    user.email ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              );
            }),
            
            const SizedBox(height: 40),
            
            // Options du menu
            _buildMenuOption(
              icon: Icons.edit,
              title: 'Modifier le profil',
              onTap: () {
                // Navigation vers le formulaire d'édition
                Get.to(() => const EditProfileFormScreen());
              },
            ),
            
            const SizedBox(height: 8),
            
            _buildMenuOption(
              icon: Icons.lock,
              title: 'Changer le mot de passe',
              onTap: () {
                Get.to(() => const ChangePasswordScreen());
              },
            ),
            
            const SizedBox(height: 8),
            
            _buildMenuOption(
              icon: Icons.logout,
              title: 'Se déconnecter',
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
      // Pas de BottomNavigationBar ici car il est géré par RootScreen
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.black87, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}