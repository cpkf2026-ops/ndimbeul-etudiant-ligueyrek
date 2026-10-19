import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Bouton « Ajouter » des pages Universités / Actualités / Emploi : visible uniquement
/// pour les administrateurs, il ouvre l'écran d'ajout assisté par l'IA.
class BoutonAjoutAdmin extends ConsumerWidget {
  const BoutonAjoutAdmin({super.key, required this.libelle, required this.route});

  final String libelle;
  final String route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estAdmin = ref.watch(authProvider).valueOrNull?.role?.isAdmin ?? false;
    if (!estAdmin) return const SizedBox.shrink();
    return FloatingActionButton.extended(
      heroTag: route,
      onPressed: () => context.push(route),
      backgroundColor: AppColors.accent,
      icon: const Icon(Icons.add_rounded, color: AppColors.primary),
      label: Text(libelle, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
    );
  }
}
