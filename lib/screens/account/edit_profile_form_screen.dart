import 'dart:io';
import 'package:flutter/foundation.dart'; // Pour kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/models/user.dart';
import 'package:recipe_app/services/api_auth_service.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:recipe_app/services/api/config/constants.dart';

class EditProfileFormScreen extends StatefulWidget {
  const EditProfileFormScreen({super.key});

  @override
  State<EditProfileFormScreen> createState() => _EditProfileFormScreenState();
}

class _EditProfileFormScreenState extends State<EditProfileFormScreen> {
  final APIService _apiService = Get.find<APIService>();
  final ApiAuthService _authService = ApiAuthService.to;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Charger les infos actuelles dans les champs
    final user = _authService.user;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? ''; // Juste pour l'affichage
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar("Erreur", "Le nom ne peut pas être vide");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Étape 1 : Mise à jour du Nom
      // On ne passe QUE le nom car l'email n'est pas modifiable via cette route/logique
      await _apiService.updateProfile(name: _nameController.text);

      // Étape 2 : Mise à jour de l'Image (si une nouvelle a été choisie)
      if (_selectedImage != null) {
        await _apiService.updateProfilePicture(_selectedImage!);
      }

      // Étape 3 : Recharger le profil complet depuis le serveur
      // C'est crucial car updatePicture renvoie "No Content" (pas d'URL),
      // donc on doit redemander le user pour avoir la nouvelle URL d'image.
      User? freshUser = await _apiService.getProfile();

      // Étape 4 : Mettre à jour le state global de l'app
      if (freshUser != null) {
        await _authService.setUser(freshUser);
      }

      Get.back(); // Retour au menu
      Get.snackbar(
        "Succès", 
        "Profil mis à jour avec succès", 
        backgroundColor: Colors.green, 
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM
      );

    } catch (e) {
      Get.snackbar(
        "Erreur", 
        "Impossible de mettre à jour le profil. Vérifiez votre connexion.", 
        backgroundColor: Colors.red, 
        colorText: Colors.white
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.user;
    
    // Logique d'affichage de l'avatar
    ImageProvider? bgImage;
    
    // 1. Priorité à l'image locale nouvellement sélectionnée
    if (_selectedImage != null) {
      if (kIsWeb) {
        bgImage = NetworkImage(_selectedImage!.path);
      } else {
        bgImage = FileImage(File(_selectedImage!.path));
      }
    } 
    // 2. Sinon, l'image distante actuelle
    else if (currentUser?.imageUrl != null) {
       String url = currentUser!.imageUrl!.startsWith('http') 
          ? currentUser.imageUrl! 
          : "${Constants.apiBaseUrl}/${currentUser.imageUrl!}";
       bgImage = NetworkImage(url);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le profil"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Avatar avec icône caméra
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      image: bgImage != null ? DecorationImage(image: bgImage, fit: BoxFit.cover) : null,
                    ),
                    child: bgImage == null 
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Champ Nom (Editable)
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nom complet",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Champ Email (Désactivé / ReadOnly)
            TextField(
              controller: _emailController,
              enabled: false, // Désactive le champ
              style: TextStyle(color: Colors.grey[600]), // Grise le texte
              decoration: InputDecoration(
                labelText: "Adresse E-mail",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
                fillColor: Colors.grey[100],
                filled: true,
                helperText: "L'adresse e-mail ne peut pas être modifiée.",
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text("Enregistrer les modifications"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}