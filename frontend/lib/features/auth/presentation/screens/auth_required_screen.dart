import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/extensions/context_extensions.dart';

/// Fenêtre "Connexion requise" — affichée par-dessus l'accueil (route
/// transparente, voir app_router.dart) quand un visiteur non connecté
/// touche une fonctionnalité réservée aux membres. [from] est l'URL qu'il
/// voulait ouvrir : on la transmet à l'écran de connexion pour l'y
/// renvoyer une fois connecté.
class AuthRequiredScreen extends StatelessWidget {
  const AuthRequiredScreen({super.key, this.from});

  final String? from;

  static const _features = <String, (String, IconData)>{
    RoutePaths.jobs: ('Emploi & Stages', Icons.work_rounded),
    RoutePaths.universities: ('Universités', Icons.school_rounded),
    RoutePaths.news: ('Actualités', Icons.article_rounded),
    RoutePaths.chat: ('Assistant IA', Icons.smart_toy_rounded),
    RoutePaths.orientation: ('Orientation', Icons.explore_rounded),
    RoutePaths.profile: ('Mon profil', Icons.person_rounded),
    RoutePaths.admin: ('Administration', Icons.admin_panel_settings_rounded),
  };

  (String, IconData) get _feature {
    final path = from ?? '';
    for (final entry in _features.entries) {
      if (path.startsWith(entry.key)) return entry.value;
    }
    return ('cette fonctionnalité', Icons.lock_rounded);
  }

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.dashboard);
    }
  }

  void _goTo(BuildContext context, String path) {
    final target = Uri(
      path: path,
      queryParameters: from == null ? null : {'from': from},
    ).toString();
    // Remplace la fenêtre : un "retour" depuis la connexion ramène à l'accueil.
    if (context.canPop()) {
      context.pushReplacement(target);
    } else {
      context.go(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, icon) = _feature;
    final isMobile = context.isMobile;

    final card = Material(
      color: AppColors.surface,
      borderRadius: isMobile
          ? const BorderRadius.vertical(top: Radius.circular(32))
          : BorderRadius.circular(32),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isMobile)
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Fermer',
                  onPressed: () => _close(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: AppColors.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 38),
                    ),
                    Positioned(
                      right: -4,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.lock_rounded,
                            size: 16, color: AppColors.primary),
                      ),
                    ),
                  ],
                ).animate().scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 350.ms,
                      curve: Curves.easeOutBack,
                    ),
              ),
              const SizedBox(height: 20),
              Center(
                child: AppTypography.heroTitle(
                  straight: 'Rejoignez',
                  accent: 'Ndimbeul.',
                  fontSize: 23,
                  straightColor: AppColors.textPrimary,
                  accentColor: AppColors.accentDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Créez votre compte gratuit ou connectez-vous pour accéder à '
                '« $label ».',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              const _Benefit(
                icon: Icons.school_rounded,
                text: 'Comparez universités, filières et frais de scolarité',
              ),
              const _Benefit(
                icon: Icons.smart_toy_rounded,
                text: 'Un assistant IA pour vous orienter, 24h/24',
              ),
              const _Benefit(
                icon: Icons.notifications_active_rounded,
                text: 'Alertes bourses, concours et opportunités',
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => _goTo(context, RoutePaths.register),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                  label: const Text('Créer un compte gratuit'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _goTo(context, RoutePaths.login),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  icon: const Icon(Icons.login_rounded, size: 20),
                  label: const Text('J\'ai déjà un compte'),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => _close(context),
                style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                child: const Text('Continuer la visite'),
              ),
            ],
          ),
        ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _close(context),
            ),
          ),
          Align(
            alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 440),
              child: SingleChildScrollView(child: card),
            ),
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
