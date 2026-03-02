import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/models/user.dart';
import 'package:recipe_app/services/api_auth_service.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:recipe_app/services/api/config/constants.dart';

// ──────────────────────────────────────────────────────────────────────────────
// EditProfileFormScreen — Refonte UI v2
// ⚠️  ZÉRO MODIFICATION LOGIQUE : _apiService, _authService, _nameController,
//     _emailController, _selectedImage, _isLoading, _pickImage, _saveProfile
// ──────────────────────────────────────────────────────────────────────────────

class EditProfileFormScreen extends StatefulWidget {
  const EditProfileFormScreen({super.key});

  @override
  State<EditProfileFormScreen> createState() => _EditProfileFormScreenState();
}

class _EditProfileFormScreenState extends State<EditProfileFormScreen> {
  // ── LOGIQUE INCHANGÉE ──────────────────────────────────────────────────────
  final APIService _apiService = Get.find<APIService>();
  final ApiAuthService _authService = ApiAuthService.to;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = _authService.user;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
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
      Get.snackbar('Erreur', 'Le nom ne peut pas être vide');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.updateProfile(name: _nameController.text);

      if (_selectedImage != null) {
        await _apiService.updateProfilePicture(_selectedImage!);
      }

      User? freshUser = await _apiService.getProfile();

      if (freshUser != null) {
        await _authService.setUser(freshUser);
      }

      Get.back();
      Get.snackbar(
        'Succès',
        'Profil mis à jour avec succès',
        backgroundColor: kPrimary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le profil. Vérifiez votre connexion.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── RENDU VISUEL ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.user;

    // Résolution image avatar — LOGIQUE ORIGINALE INCHANGÉE
    ImageProvider? bgImage;
    if (_selectedImage != null) {
      bgImage = kIsWeb
          ? NetworkImage(_selectedImage!.path)
          : FileImage(File(_selectedImage!.path)) as ImageProvider;
    } else if (currentUser?.imageUrl != null) {
      String url = currentUser!.imageUrl!.startsWith('http')
          ? currentUser.imageUrl!
          : '${Constants.apiBaseUrl}/${currentUser.imageUrl!}';
      bgImage = NetworkImage(url);
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Navigation : retour ────────────────────────────────────
              GestureDetector(
                onTap: () => Get.back(),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14,
                      color: kPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Retour',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: kPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Titre ──────────────────────────────────────────────────
              Text(
                'Modifier le profil',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 32),

              // ── Avatar + bouton caméra ─────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kPrimaryLight,
                          border: Border.all(color: kBorder, width: 2),
                          image: bgImage != null
                              ? DecorationImage(
                                  image: bgImage, fit: BoxFit.cover)
                              : null,
                        ),
                        child: bgImage == null
                            ? const Icon(
                                Icons.person_rounded,
                                size: 48,
                                color: kPrimary,
                              )
                            : null,
                      ),
                      // Badge caméra orange
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: kAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // ── Champ Nom complet ─────────────────────────────────────
              Text(
                'Nom complet',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              _ProfileField(
                controller: _nameController,
                hintText: 'Votre nom',
                prefixIcon: Icons.person_outline_rounded,
                enabled: true,
              ),

              const SizedBox(height: 20),

              // ── Champ Email (désactivé) ───────────────────────────────
              Text(
                'Adresse E-mail',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              _ProfileField(
                controller: _emailController,
                hintText: 'Votre email',
                prefixIcon: Icons.mail_outline_rounded,
                enabled: false,
              ),
              const SizedBox(height: 6),
              Text(
                "L'adresse e-mail ne peut pas être modifiée.",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: kTextSecondary.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 40),

              // ── Bouton Enregistrer ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: kPrimary.withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Enregistrer les modifications',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Widget champ de saisie profil
// ──────────────────────────────────────────────────────────────────────────────
class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool enabled;

  const _ProfileField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? kSurface : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: GoogleFonts.outfit(
          fontSize: 15,
          color: enabled ? kTextPrimary : kTextSecondary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.outfit(
            color: kTextSecondary,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            prefixIcon,
            size: 20,
            color: enabled ? kPrimary : kTextSecondary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: false,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}