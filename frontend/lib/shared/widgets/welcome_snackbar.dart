import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../features/auth/domain/entities/user.dart';

/// Message de bienvenue affiché une seule fois juste après une connexion
/// réussie (jamais lors d'une simple restauration de session au démarrage
/// de l'app — voir `AuthNotifier.consumeJustLoggedIn()`), sur l'écran
/// d'atterrissage (tableau de bord élève ou back-office admin).
void showWelcomeSnackBar(BuildContext context, User user) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 4),
        content: Text(
          'Bienvenue, ${user.prenom} 👋 — heureux de vous revoir sur '
          '${AppConstants.appName}.',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
}
