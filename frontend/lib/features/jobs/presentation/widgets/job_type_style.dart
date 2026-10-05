import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/offre_emploi.dart';

/// Couleur + icône associées à chaque type d'offre — source unique partagée
/// par la carte, les filtres et l'écran de détail.
extension JobTypeStyle on JobType {
  Color get color => switch (this) {
        JobType.emploi => AppColors.info,
        JobType.stage => const Color(0xFF1F7A5A),
        JobType.alternance => const Color(0xFF8A5CD0),
        JobType.formation => AppColors.accentDark,
        JobType.bourse => const Color(0xFFD9534F),
        JobType.concours => const Color(0xFF0E7C7B),
      };

  IconData get icon => switch (this) {
        JobType.emploi => Icons.work_rounded,
        JobType.stage => Icons.school_rounded,
        JobType.alternance => Icons.sync_alt_rounded,
        JobType.formation => Icons.menu_book_rounded,
        JobType.bourse => Icons.savings_rounded,
        JobType.concours => Icons.emoji_events_rounded,
      };
}

/// Badge d'échéance : "J-3", "Aujourd'hui", "Expirée"… null si pas de date.
({String label, Color color})? deadlineBadge(OffreEmploi job) {
  if (job.expiree) return (label: 'Expirée', color: AppColors.error);
  final limite = job.dateLimite;
  if (limite == null) return null;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final days = DateTime(limite.year, limite.month, limite.day).difference(today).inDays;
  if (days < 0) return (label: 'Expirée', color: AppColors.error);
  if (days == 0) return (label: "Dernier jour", color: AppColors.error);
  if (days <= 7) return (label: 'J-$days', color: const Color(0xFFE07B00));
  return (label: 'J-$days', color: AppColors.success);
}

/// Initiales d'une entreprise ("Orange Sénégal" → "OS").
String initialesEntreprise(String nom) {
  final mots = nom.trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty).toList();
  if (mots.isEmpty) return '?';
  if (mots.length == 1) {
    return mots.first.substring(0, mots.first.length >= 2 ? 2 : 1).toUpperCase();
  }
  return (mots[0][0] + mots[1][0]).toUpperCase();
}
