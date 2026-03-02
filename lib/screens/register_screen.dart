import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app/services/auth_service.dart';
import 'package:recipe_app/models/requests/register_request.dart';
import 'package:recipe_app/services/api_auth_service.dart';
import 'package:recipe_app/models/auth_response.dart';
import 'package:recipe_app/services/api/entities/api_response.dart';
import 'package:recipe_app/config/theme.dart'; // kPrimary, kAccent

// ──────────────────────────────────────────────────────────────────────────────
// RegisterScreen — Refonte UI v2 (style Premium Green + Glassmorphism)
// ⚠️  ZÉRO MODIFICATION LOGIQUE : _handleRegister, _formKey, controllers, _isLoading
// ──────────────────────────────────────────────────────────────────────────────

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ── LOGIQUE MÉTIER INCHANGÉE ──────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();

  bool _isLoading = false;

  // ── ÉTATS UI UNIQUEMENT (visibilité mots de passe) ────────────────────────
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final passwordConfirmation = _passwordConfirmationController.text.trim();

    if (password != passwordConfirmation) {
      Get.snackbar(
        "Erreur",
        "Les mots de passe ne correspondent pas",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() => _isLoading = false);
      return;
    }

    final req = RegisterRequest(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    final authService = AuthService();
    try {
      final ApiResponse<AuthResponse> resp = await authService.register(req);

      setState(() => _isLoading = false);

      if (resp is Success<AuthResponse>) {
        final auth = resp.data;
        final token = auth.token;

        if (token != null && token.isNotEmpty) {
          await ApiAuthService.to.setToken(token);
        }
        Get.offAllNamed('/root');
        Get.snackbar(
          "Succès",
          "Inscription réussie",
          backgroundColor: kPrimary,
          colorText: Colors.white,
        );
      } else {
        final code = (resp as Failure).code;
        Get.snackbar(
          "Erreur",
          "Inscription échouée (code: $code)",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        "Erreur réseau",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ── RENDU VISUEL ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── [1] Image de fond ────────────────────────────────────────────
          Image.asset(
            'assets/images/auth-bg.jpg',
            fit: BoxFit.cover,
          ),

          // ── [2] Voile vert foncé — identique au login ────────────────────
          Container(
            color: const Color(0xFF0D3320).withOpacity(0.72),
          ),

          // ── [3] Contenu scrollable ───────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),

                    // ── En-tête : Titre + Icône chef ──────────────────────
                    _buildHeader(),

                    const SizedBox(height: 40),

                    // ── Champ Nom & Prénoms ───────────────────────────────
                    _GlassField(
                      controller: _nameController,
                      hintText: 'Nom & Prénoms',
                      keyboardType: TextInputType.name,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Veuillez entrer un nom.'
                          : null,
                    ),

                    const SizedBox(height: 14),

                    // ── Champ Email ───────────────────────────────────────
                    _GlassField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty || !v.contains('@') || !v.contains('.')) {
                          return 'Veuillez entrer un email valide.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // ── Champ Mot de passe ────────────────────────────────
                    _GlassField(
                      controller: _passwordController,
                      hintText: 'Mot de passe',
                      obscureText: _obscurePassword,
                      validator: (v) {
                        if (v == null || v.isEmpty || v.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères.';
                        }
                        return null;
                      },
                      suffixIcon: GestureDetector(
                        onTap: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Champ Confirmer Mot de passe ──────────────────────
                    _GlassField(
                      controller: _passwordConfirmationController,
                      hintText: 'Confirmer Mot de passe',
                      obscureText: _obscurePasswordConfirm,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Veuillez confirmer votre mot de passe.';
                        }
                        if (v != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas.';
                        }
                        return null;
                      },
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                            () => _obscurePasswordConfirm = !_obscurePasswordConfirm),
                        child: Icon(
                          _obscurePasswordConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Lien "Mot de passe oublié ?" ──────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Mot de passe oublié ?',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white70,
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Bouton "Inscription" — pill blanc ─────────────────
                    _buildRegisterButton(),

                    const SizedBox(height: 28),

                    // ── Lien connexion ────────────────────────────────────
                    _buildLoginLink(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sous-widgets privés ───────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenu sur',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.85),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Recipe Book',
              style: GoogleFonts.outfit(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
          ],
        ),

        // Logo chef hat SVG — même style que login
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: SvgPicture.asset(
              'assets/icons/chef_hat.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: kPrimary,
          disabledBackgroundColor: Colors.white70,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: kPrimary,
                ),
              )
            : Text(
                'Inscription',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous avez déjà un compte ?',
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.85),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Get.toNamed('/login'),
          child: Text(
            'Se connecter',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
              decorationThickness: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Widget Glassmorphism réutilisable — même composant que login_screen.dart
// ──────────────────────────────────────────────────────────────────────────────
class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _GlassField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.70),
              fontSize: 15,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 16,
            ),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: suffixIcon,
                  )
                : null,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.35),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.35),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(
                color: Colors.white,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: Colors.red.shade300,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: Colors.red.shade300,
                width: 1.8,
              ),
            ),
            errorStyle: const TextStyle(height: 0, fontSize: 0.01),
          ),
        ),
      ),
    );
  }
}
