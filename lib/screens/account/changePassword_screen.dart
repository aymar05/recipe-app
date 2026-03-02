import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:recipe_app/services/api_client.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ChangePasswordScreen — Refonte UI v2
// ⚠️  ZÉRO MODIFICATION LOGIQUE : _apiService, 3 controllers, 3 visibility flags,
//     _isLoading, _handlePasswordChange, _showErrorDialog, _showSuccessDialog
// ──────────────────────────────────────────────────────────────────────────────

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordScreen> {
  // ── LOGIQUE INCHANGÉE ──────────────────────────────────────────────────────
  final APIService _apiService = Get.find<APIService>();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordChange() async {
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorDialog('Veuillez remplir tous les champs');
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorDialog('Les nouveaux mots de passe ne correspondent pas');
      return;
    }

    if (newPassword.length < 6) {
      _showErrorDialog(
          'Le nouveau mot de passe doit contenir au moins 6 caractères');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      String errorMessage =
          'Une erreur est survenue lors de la mise à jour.';

      if (e is ApiException) {
        if (e.statusCode == 401) {
          errorMessage = 'Le mot de passe actuel est incorrect.';
        } else if (e.statusCode == 422) {
          errorMessage =
              'Données invalides (ex: mot de passe trop court ou non confirmé).';
        }
      }

      if (mounted) {
        _showErrorDialog(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Erreur',
              style: GoogleFonts.outfit(
                  color: Colors.red, fontWeight: FontWeight.w700)),
          content: Text(message,
              style: GoogleFonts.outfit(color: kTextSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK',
                  style:
                      GoogleFonts.outfit(color: kAccent, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Succès',
              style: GoogleFonts.outfit(
                  color: kPrimary, fontWeight: FontWeight.w700)),
          content: Text('Votre mot de passe a été modifié avec succès.',
              style: GoogleFonts.outfit(color: kTextSecondary)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK',
                  style: GoogleFonts.outfit(
                      color: kAccent, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  // ── RENDU VISUEL ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
                onTap: () => Navigator.pop(context),
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

              const SizedBox(height: 24),

              // ── Titre ──────────────────────────────────────────────────
              Text(
                'Changement de\nmot de passe',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  letterSpacing: -0.3,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 36),

              // ── Groupe 1 : Mot de passe actuel ─────────────────────────
              _FieldLabel(label: 'Saisissez votre mot de passe actuel'),
              const SizedBox(height: 10),
              _PasswordField(
                controller: _currentPasswordController,
                hintText: 'Mot de passe actuel',
                isVisible: _isCurrentPasswordVisible,
                onToggle: () => setState(
                    () => _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
              ),

              const SizedBox(height: 24),

              // ── Groupe 2 : Nouveau mot de passe ────────────────────────
              _FieldLabel(label: 'Saisissez votre nouveau mot de passe'),
              const SizedBox(height: 10),
              _PasswordField(
                controller: _newPasswordController,
                hintText: 'Nouveau mot de passe',
                isVisible: _isNewPasswordVisible,
                onToggle: () => setState(
                    () => _isNewPasswordVisible = !_isNewPasswordVisible),
              ),

              const SizedBox(height: 24),

              // ── Groupe 3 : Confirmation ────────────────────────────────
              _FieldLabel(label: 'Confirmez votre mot de passe'),
              const SizedBox(height: 10),
              _PasswordField(
                controller: _confirmPasswordController,
                hintText: 'Confirmez mot de passe',
                isVisible: _isConfirmPasswordVisible,
                onToggle: () => setState(() =>
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),

              const SizedBox(height: 44),

              // ── Bouton Enregistrer — orange pill (fidèle à la maquette) ─
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePasswordChange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: kAccent.withOpacity(0.6),
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
                          'Enregistrer',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
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

// ── Label de section ──────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kTextSecondary,
        letterSpacing: 0.1,
      ),
    );
  }
}

// ── Champ mot de passe avec œil ───────────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isVisible;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.hintText,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        style: GoogleFonts.outfit(
          fontSize: 15,
          color: kTextPrimary,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.outfit(
            color: kTextSecondary,
            fontSize: 15,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(
                isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: kTextSecondary,
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }
}