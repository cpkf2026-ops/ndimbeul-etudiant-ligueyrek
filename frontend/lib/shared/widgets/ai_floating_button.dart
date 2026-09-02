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
      onPressed: () => context.push(RoutePaths.chat),
      child: const Icon(Icons.smart_toy_rounded, color: AppColors.accent),
    );
  }
}
