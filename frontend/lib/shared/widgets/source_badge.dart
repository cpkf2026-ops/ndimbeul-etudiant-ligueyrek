import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';

/// Badge de traçabilité affiché sous chaque bloc d'information généré par
/// l'IA (fiche université) — indique la source et la date de mise à jour.
class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.source, required this.updatedAt});

  final String source;
  final DateTime updatedAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.verified_outlined, size: 13, color: AppColors.info),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            'Source : $source · MAJ ${DateFormatter.relative(updatedAt)}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
