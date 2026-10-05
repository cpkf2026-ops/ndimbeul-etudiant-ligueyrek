import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/route_paths.dart';
import '../../app/theme/app_colors.dart';

/// Bouton flottant assistant IA — cercle vert, toujours accessible depuis
/// les écrans principaux (Accueil, Orientation, Écosystème, ...).
class AiFloatingButton extends StatelessWidget {
  const AiFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'ai-floating-button',
      backgroundColor: AppColors.primary,
      elevation: 4,
      // go() : /chat est un branch de la StatefulShellRoute — utilisé depuis plusieurs
      // écrans (mêmes et différents branches), push() y empilait le chat au lieu d'y
      // basculer proprement (voir app_router.dart).
      onPressed: () => context.go(RoutePaths.chat),
      child: const Icon(Icons.smart_toy_rounded, color: AppColors.accent),
    );
  }
}
