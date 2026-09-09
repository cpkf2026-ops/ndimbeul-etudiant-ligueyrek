import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../shared/widgets/brand_illustration.dart';
import '../router/route_paths.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

const _kSplashDuration = Duration(seconds: 30);

/// Écran d'accueil animé (~30s au lancement, ou jusqu'au premier tap qui
/// l'ignore immédiatement) — mise en scène de la marque : dégradé vert
/// plein écran, illustration vectorielle "maison" qui apparaît en cascade,
/// badge + accroche qui glissent en place, puis une boucle ambiante
/// discrète jusqu'à la bascule vers le flux normal (dashboard si connecté,
/// sinon connexion — la redirection auth habituelle du router s'applique
/// dès la sortie du splash, qui en est explicitement exclue).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_kSplashDuration, _leave);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _leave() {
    _timer?.cancel();
    if (!mounted) return;
    final user = ref.read(authProvider).valueOrNull;
    context.go((user?.role?.isAdmin ?? false) ? RoutePaths.admin : RoutePaths.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _leave,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fond unique plein cadre : mains tenant une ampoule surmontée
            // d'une toque de diplômé, entourée d'icônes e-learning — visuel
            // de marque demandé pour l'écran d'accueil.
            Positioned.fill(
              child: Image.asset(
                'assets/images/splash_hero.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0, 0.25),
                errorBuilder: (context, error, stack) =>
                    const ColoredBox(color: AppColors.primary),
              ),
            ).animate().fadeIn(duration: 400.ms),
            // Voile volontairement léger : l'image de fond doit rester bien
            // visible. Seuls un très léger teint en haut (lisibilité du badge
            // marque) et un dégradé plus marqué en bas (texte du footer) sont
            // appliqués — le milieu reste quasi transparent.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.42),
                    AppColors.primary.withValues(alpha: 0.28),
                    AppColors.primary.withValues(alpha: 0.88),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Brand()
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 380.ms)
                        .slideY(begin: -0.3, end: 0, curve: Curves.easeOut),
                    Center(
                      child: BrandIllustration(
                        variant: BrandIllustrationVariant.splash,
                        size: 240,
                      ),
                    ),
                    const _SplashFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.accentGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.school_rounded, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          AppConstants.appName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Bloc bas — accroche, barre de progression et indice "tap pour passer".
/// Délais volontairement courts (< 1s) : au-delà, les widgets `.animate()`
/// suivant un premier widget déjà animé peuvent rester bloqués invisibles
/// sur cette version de flutter_animate/Flutter web (constaté empiriquement
/// — la boucle "respirante" de l'illustration et le délai de la barre de
/// progression (Flutter natif, non concerné) restent la seule pièce lente).
class _SplashFooter extends StatelessWidget {
  const _SplashFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTypography.heroTitle(
          straight: 'Votre avenir commence',
          accent: 'ici.',
          fontSize: 30,
        ).animate(delay: 550.ms).fadeIn(duration: 380.ms),
        const SizedBox(height: 10),
        Text(
          'Universités, bourses, logements et formations partout au '
          'Sénégal — accompagnés par une IA qui vous connaît.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            height: 1.4,
          ),
        ).animate(delay: 650.ms).fadeIn(duration: 380.ms),
        const SizedBox(height: 20),
        const _ProgressAffordance(duration: _kSplashDuration),
        Text(
          'Appuyez pour continuer',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12.5,
          ),
        ).animate(delay: 850.ms).fadeIn(duration: 380.ms),
      ],
    );
  }
}

class _ProgressAffordance extends StatelessWidget {
  const _ProgressAffordance({required this.duration});
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 3,
          width: 84,
          child: Stack(
            children: [
              ColoredBox(color: Colors.white.withValues(alpha: 0.18)),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: duration,
                curve: Curves.linear,
                builder: (context, value, _) => FractionallySizedBox(
                  widthFactor: value,
                  child: const ColoredBox(color: AppColors.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
