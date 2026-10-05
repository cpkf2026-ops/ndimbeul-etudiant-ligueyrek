import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import 'favorite_button.dart';
import 'name_placeholder.dart';
import 'skeleton_loader.dart';

/// Carte université / entreprise / logement — image cover + overlay
/// dégradé, titre, sous-info, bouton favori optionnel. Composant central
/// des sections horizontales scrollables de l'Accueil et de l'Écosystème.
class EntityCard extends StatelessWidget {
  const EntityCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.badge,
    this.width = 190,
    this.height = 220,
    this.isFavorite,
    this.onFavoriteTap,
    this.onTap,
    this.trailingText,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final String? badge;
  final double width;
  final double height;
  final bool? isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;
  final String? trailingText;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // La quasi-totalité des images de l'app sont des URLs distantes
              // (`CachedNetworkImage`) — mais certaines photos réelles n'ont
              // aucune source distante compatible CORS (voir CREDITS_IMAGES.md,
              // ex. ISEP Thiès) et sont embarquées dans l'app à la place.
              if (imageUrl.isEmpty)
                NamePlaceholder(name: title)
              else if (imageUrl.startsWith('assets/'))
                Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => NamePlaceholder(name: title),
                )
              else
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SkeletonLoader(
                    height: double.infinity,
                    borderRadius: 0,
                  ),
                  errorWidget: (context, url, error) => NamePlaceholder(name: title),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      stops: const [0.4, 1],
                    ),
                  ),
                ),
              ),
              if (badge != null)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              if (isFavorite != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: FavoriteButton(
                    isFavorite: isFavorite!,
                    onTap: onFavoriteTap ?? () {},
                    background: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                        if (trailingText != null)
                          Text(
                            trailingText!,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
