import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recipe_app/services/api_service.dart';
import 'package:recipe_app/services/api_client.dart'; // Pour récupérer ApiException si besoin

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordScreen> {
  // Injection du service
  final APIService _apiService = Get.find<APIService>();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  // État de chargement
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Changement de mot de passe',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Champ mot de passe actuel
            const Text(
              'Saisissez votre mot de passe actuel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            _buildPasswordField(
              controller: _currentPasswordController,
              hintText: 'Mot de passe actuel',
              isVisible: _isCurrentPasswordVisible,
              onVisibilityToggle: () => setState(() => _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
            ),
            
            const SizedBox(height: 24),
            
            // Champ nouveau mot de passe
            const Text(
              'Saisissez votre nouveau mot de passe',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            _buildPasswordField(
              controller: _newPasswordController,
              hintText: 'Nouveau mot de passe',
              isVisible: _isNewPasswordVisible,
              onVisibilityToggle: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
            ),
            
            const SizedBox(height: 24),
            
            // Champ confirmation mot de passe
            const Text(
              'Confirmez votre mot de passe',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            _buildPasswordField(
              controller: _confirmPasswordController,
              hintText: 'Confirmez mot de passe',
              isVisible: _isConfirmPasswordVisible,
              onVisibilityToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
            
            const SizedBox(height: 16),
            
            // Lien mot de passe oublié (Optionnel)
            // Center(child: TextButton(...)), 
            
            const SizedBox(height: 32),
            
            // Bouton Enregistrer
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePasswordChange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Ou Theme.of(context).colorScheme.primary
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(
                      width: 24, 
                      height: 24, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text(
                      'Enregistrer',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey.shade600,
            ),
            onPressed: onVisibilityToggle,
          ),
        ),
      ),
    );
  }

  Future<void> _handlePasswordChange() async {
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // 1. Validation locale
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog('Veuillez remplir tous les champs');
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorDialog('Les nouveaux mots de passe ne correspondent pas');
      return;
    }

    if (newPassword.length < 6) { // Ajustez selon vos règles Laravel (min:8 souvent)
      _showErrorDialog('Le nouveau mot de passe doit contenir au moins 6 caractères');
      return;
    }

    // 2. Appel API
    setState(() => _isLoading = true);

    try {
      await _apiService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      // Succès
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      // Gestion des erreurs API
      String errorMessage = "Une erreur est survenue lors de la mise à jour.";
      
      if (e is ApiException) {
        if (e.statusCode == 401) {
          errorMessage = "Le mot de passe actuel est incorrect.";
        } else if (e.statusCode == 422) {
          errorMessage = "Données invalides (ex: mot de passe trop court ou non confirmé).";
          // Si votre API renvoie les détails, vous pouvez les parser ici depuis e.message
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Erreur', style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.orange)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Succès', style: TextStyle(color: Colors.green)),
          content: const Text('Votre mot de passe a été modifié avec succès.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialog
                Navigator.of(context).pop(); // Retourne à l'écran précédent (Profil)
              },
              child: const Text('OK', style: TextStyle(color: Colors.orange)),
            ),
          ],
        );
      },
    );
  }
}