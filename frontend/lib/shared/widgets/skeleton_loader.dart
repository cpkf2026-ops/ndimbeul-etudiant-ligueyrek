import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/theme/app_colors.dart';

/// Squelette de chargement — préféré aux spinners bloquants pour rester
/// perçu comme rapide sur connexion 3G.
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.background,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Squelette de carte (liste universités / offres) — image + 2 lignes texte.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 180});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonLoader(height: height, borderRadius: 0),
          const SizedBox(height: 8),
          const SkeletonLoader(height: 14, width: 140),
          const SizedBox(height: 6),
          const SkeletonLoader(height: 12, width: 90),
        ],
      ),
    );
  }
}
