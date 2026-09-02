import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Système typographique — Poppins pour les titres (accroches hero avec
/// contraste droit/italique), Inter pour le corps de texte.
abstract final class AppTypography {
  static TextTheme textTheme(Color base) => TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: base,
          height: 1.15,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: base,
          height: 1.2,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: base,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: base,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: base,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: base,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: base,
          height: 1.4,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: base,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      );

  /// Titre hero façon maquette : "Posez votre question **maintenant**"
  /// — dernier segment en italique doré pour créer le contraste
  /// droit / italique observé sur les bannières IA.
  static Widget heroTitle({
    required String straight,
    required String accent,
    double fontSize = 24,
    Color straightColor = Colors.white,
    Color accentColor = AppColors.accent,
  }) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: straightColor,
          height: 1.2,
        ),
        children: [
          TextSpan(text: '$straight '),
          TextSpan(
            text: accent,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
