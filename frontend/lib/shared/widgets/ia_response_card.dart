import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import 'loading_dots.dart';

/// Bulle de réponse IA — fond vert foncé, avatar robot, texte blanc,
/// sources cliquables sous la réponse (§4.5).
class IaResponseCard extends StatelessWidget {
  const IaResponseCard({
    super.key,
    required this.text,
    this.sources = const [],
    this.isStreaming = false,
    this.onSourceTap,
  });

  final String text;
  final List<String> sources;
  final bool isStreaming;
  final ValueChanged<String>? onSourceTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            color: AppColors.accent,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text.isEmpty ? ' ' : text,
                  style: const TextStyle(color: Colors.white, height: 1.4),
                ),
                if (isStreaming) ...[
                  const SizedBox(height: 6),
                  const LoadingDots(color: AppColors.accent),
                ],
                if (sources.isNotEmpty && !isStreaming) ...[
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: sources
                        .map(
                          (s) => InkWell(
                            onTap: () => onSourceTap?.call(s),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.link_rounded,
                                  size: 13,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  s,
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Bulle utilisateur — alignée à droite, fond doré clair.
class UserMessageBubble extends StatelessWidget {
  const UserMessageBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.amberSoft,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: AppColors.textPrimary, height: 1.4),
        ),
      ),
    );
  }
}
