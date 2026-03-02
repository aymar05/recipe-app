import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_app/config/theme.dart';
import 'package:recipe_app/screens/account/changePassword_screen.dart';
import 'package:recipe_app/screens/account/edit_profile_form_screen.dart';
import 'package:recipe_app/services/api/config/constants.dart';
import 'package:recipe_app/services/api_auth_service.dart';
import 'package:recipe_app/services/auth_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ProfileScreen — Refonte UI v2
// ⚠️  ZÉRO MODIFICATION LOGIQUE : _logout, _showLogoutDialog, Obx(user),
//     imageProvider, Get.to(EditProfileFormScreen), Get.to(ChangePasswordScreen)
// ──────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ── LOGIQUE INCHANGÉE ──────────────────────────────────────────────────────
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Déconnexion',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?',
            style: GoogleFonts.outfit(color: kTextSecondary)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler',
                style: GoogleFonts.outfit(color: kTextSecondary)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _logout();
            },
            child: Text('Déconnexion',
                style: GoogleFonts.outfit(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
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
              const SizedBox(height: 28),

              // ── Titre ──────────────────────────────────────────────────
              Text(
                'Mon Profil',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 24),

              // ── Zone dynamique : Avatar + Nom + Email ──────────────────
              Obx(() {
                final user = ApiAuthService.to.user;

                if (user == null) {
                  return const Center(
                      child: CircularProgressIndicator(color: kPrimary));
                }

                // Résolution URL avatar — LOGIQUE ORIGINALE INCHANGÉE
                ImageProvider? imageProvider;
                if (user.imageUrl != null) {
                  String url = user.imageUrl!.startsWith('http')
                      ? user.imageUrl!
                      : '${Constants.apiBaseUrl}/${user.imageUrl!}';
                  imageProvider = NetworkImage(url);
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kPrimaryLight,
                          border: Border.all(color: kBorder, width: 1.5),
                          image: imageProvider != null
                              ? DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover)
                              : null,
                        ),
                        child: imageProvider == null
                            ? const Icon(
                                Icons.person_rounded,
                                size: 32,
                                color: kPrimary,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),

                      // Nom + Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name ?? 'Utilisateur',
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: kTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email ?? '',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: kTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 32),

              // ── Menu Options ───────────────────────────────────────────
              _ProfileMenuItem(
                icon: Icons.person_outline_rounded,
                iconColor: kPrimary,
                iconBg: kPrimaryLight,
                title: 'Modifier le profil',
                onTap: () => Get.to(() => const EditProfileFormScreen()),
              ),
              const SizedBox(height: 10),

              _ProfileMenuItem(
                icon: Icons.lock_outline_rounded,
                iconColor: kAccent,
                iconBg: const Color(0xFFFFF3E0),
                title: 'Changer le mot de passe',
                onTap: () => Get.to(() => const ChangePasswordScreen()),
              ),

              const SizedBox(height: 24),

              // ── Bouton Déconnexion ─────────────────────────────────────
              GestureDetector(
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Se déconnecter',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
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
// Widget : Item de menu profil générique
// ──────────────────────────────────────────────────────────────────────────────
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône colorée
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),

            // Titre
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: kTextPrimary,
                ),
              ),
            ),

            // Chevron
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: kTextSecondary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}