import 'package:flutter/material.dart';

/// Palette officielle "Ndimbeul-Etudiant" — reproduite depuis la maquette
/// Figma (bannières IA, cartes stats tricolores, écosystème).
abstract final class AppColors {
  // Primaire — vert profond (bannières IA, headers, boutons primaires)
  static const Color primary = Color(0xFF0F3D2E);
  static const Color primaryLight = Color(0xFF1A4D3A);
  static const List<Color> primaryGradient = [primary, primaryLight];

  // Accent — doré / ambre (CTA, badges, bouton flottant assistant)
  static const Color accent = Color(0xFFE8B923);
  static const Color accentDark = Color(0xFFD4A017);
  static const List<Color> accentGradient = [accent, accentDark];

  // Fond
  static const Color background = Color(0xFFF7F8F6);
  static const Color surface = Colors.white;

  // Blocs tricolores (cartes stats, badges)
  static const Color greenSoft = Color(0xFFDCEFE3);
  static const Color amberSoft = Color(0xFFFDF3D8);
  static const Color blueSoft = Color(0xFFE4ECF9);

  // Texte
  static const Color textPrimary = Color(0xFF16241D);
  static const Color textSecondary = Color(0xFF6B7A72);
  static const Color textOnPrimary = Colors.white;

  // Sémantique
  static const Color success = Color(0xFF2E9E5B);
  static const Color error = Color(0xFFC0392B);
  static const Color warning = accentDark;
  static const Color info = Color(0xFF3E6BC7);

  // Bordures / séparateurs
  static const Color border = Color(0xFFE4E7E3);
  static const Color divider = Color(0xFFEDEFEC);
}
