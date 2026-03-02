import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS — Recipe Book Premium v2
// ─────────────────────────────────────────────

/// Vert profond — couleur primaire (issu de la maquette login)
const Color kPrimary = Color(0xFF1B6737);

/// Vert clair — pour les fonds de surface (cards, bottom nav)
const Color kPrimaryLight = Color(0xFFE8F5EE);

/// Orange — accent chaud (icône centrale, badges, highlights)
const Color kAccent = Color(0xFFF97316);

/// Fond global de l'app
const Color kBackground = Color(0xFFF8FAF7);

/// Fond des surfaces (cards, bottom sheet)
const Color kSurface = Color(0xFFFFFFFF);

/// Texte principal
const Color kTextPrimary = Color(0xFF1A2E23);

/// Texte secondaire
const Color kTextSecondary = Color(0xFF7A8F81);

/// Divider / bordures légères
const Color kBorder = Color(0xFFDDE8E1);

// ─────────────────────────────────────────────
// THEME DATA
// ─────────────────────────────────────────────

ThemeData themeData = ThemeData(
  useMaterial3: true,

  // Palette principale
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: kPrimary,
    onPrimary: Colors.white,
    primaryContainer: kPrimaryLight,
    onPrimaryContainer: kPrimary,
    secondary: kAccent,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFFFEDD5),
    onSecondaryContainer: Color(0xFF7C3202),
    surface: kSurface,
    onSurface: kTextPrimary,
    background: kBackground,
    onBackground: kTextPrimary,
    error: Color(0xFFD32F2F),
    onError: Colors.white,
    outline: kBorder,
    shadow: Color(0x1A000000),
  ),

  // Typo — Google Fonts Outfit (moderne, lisible, premium)
  textTheme: GoogleFonts.outfitTextTheme().copyWith(
    displayLarge: GoogleFonts.outfit(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: kTextPrimary,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.outfit(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: kTextPrimary,
    ),
    titleLarge: GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: kTextPrimary,
    ),
    titleMedium: GoogleFonts.outfit(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: kTextPrimary,
    ),
    bodyLarge: GoogleFonts.outfit(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: kTextPrimary,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.outfit(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: kTextSecondary,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.outfit(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
  ),

  // ── Scaffold
  scaffoldBackgroundColor: kBackground,

  // ── AppBar — transparent, adapté aux images de fond
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    iconTheme: const IconThemeData(color: Colors.white),
    actionsIconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),

  // ── Input fields — glassmorphism
  // Les écrans sur fond blanc utilisent une variante claire définie localement.
  // Ce thème global cible les écrans sur fond sombre (login/register).
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withOpacity(0.15),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    hintStyle: GoogleFonts.outfit(
      color: Colors.white.withOpacity(0.75),
      fontSize: 15,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.4), width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.4), width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: Colors.white, width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: Colors.red.withOpacity(0.7), width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: Colors.red, width: 1.8),
    ),
    // Masque le message d'erreur inline (logique conservée)
    errorStyle: const TextStyle(height: 0, fontSize: 0.01),
  ),

  // ── ElevatedButton — pill blanc, texte vert
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: kPrimary,
      elevation: 0,
      shadowColor: Colors.transparent,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      textStyle: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
  ),

  // ── TextButton — texte vert par défaut
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: kPrimary,
      textStyle: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // ── Card — surface blanche, arrondie, ombre douce
  cardTheme: CardTheme(
    color: kSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    shadowColor: Colors.black.withOpacity(0.08),
    margin: EdgeInsets.zero,
  ),

  // ── Divider
  dividerTheme: const DividerThemeData(
    color: kBorder,
    space: 1,
    thickness: 1,
  ),

  // ── BottomNavigationBar — géré finement dans root_screen.dart
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: kSurface,
    selectedItemColor: kPrimary,
    unselectedItemColor: kTextSecondary,
    selectedLabelStyle: GoogleFonts.outfit(
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: GoogleFonts.outfit(
      fontSize: 11,
      fontWeight: FontWeight.w400,
    ),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    showSelectedLabels: true,
    showUnselectedLabels: true,
  ),

  // ── SnackBar — style partagé
  snackBarTheme: SnackBarThemeData(
    backgroundColor: kTextPrimary,
    contentTextStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
  ),

  // ── CircularProgressIndicator
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: kPrimary,
  ),
);
