import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Mémorise la position du dernier appui à l'écran, pour que la transition
/// de page parte exactement de l'élément touché.
abstract final class TapTracker {
  static Offset? lastPosition;
}

/// À placer à la racine de l'app (MaterialApp.builder) : écoute tous les
/// appuis sans intercepter les gestes.
class TapTrackerScope extends StatelessWidget {
  const TapTrackerScope({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => TapTracker.lastPosition = event.position,
      child: child,
    );
  }
}

/// Transition "vague" : un cercle vert s'étend depuis le point touché,
/// puis la nouvelle page apparaît avec un léger zoom. Au retour : simple
/// fondu + dézoom, plus rapide. La page d'en dessous recule légèrement.
class RevealPageTransitionsBuilder extends PageTransitionsBuilder {
  const RevealPageTransitionsBuilder();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 480);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 260);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _RevealTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

class _RevealTransition extends StatefulWidget {
  const _RevealTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  State<_RevealTransition> createState() => _RevealTransitionState();
}

class _RevealTransitionState extends State<_RevealTransition> {
  // Capturé à la création de la route : le point d'origine de la vague.
  final Offset? _origin = TapTracker.lastPosition;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.animation, widget.secondaryAnimation]),
      child: widget.child,
      builder: (context, child) {
        Widget page = _buildPrimary(context, child!);

        // Page recouverte par une nouvelle route : recule et s'assombrit.
        final s = Curves.easeOutCubic.transform(widget.secondaryAnimation.value);
        if (s > 0) {
          page = Transform.scale(
            scale: 1 - 0.05 * s,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                page,
                IgnorePointer(
                  child: ColoredBox(color: Colors.black.withValues(alpha: 0.18 * s)),
                ),
              ],
            ),
          );
        }
        return page;
      },
    );
  }

  Widget _buildPrimary(BuildContext context, Widget child) {
    final animation = widget.animation;
    final value = animation.value;
    if (value >= 1) return child;

    // Retour arrière : fondu + léger dézoom, sans vague.
    if (animation.status == AnimationStatus.reverse) {
      final t = Curves.easeIn.transform(value);
      return Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
      );
    }

    final t = Curves.easeInOutCubic.transform(value);
    final size = MediaQuery.sizeOf(context);
    final origin = _origin ?? Offset(size.width / 2, size.height / 2);
    final maxRadius = _farthestCornerDistance(origin, size);

    final contentOpacity = const Interval(0.35, 1, curve: Curves.easeOut).transform(value);
    final halo = const Interval(0, 0.6, curve: Curves.easeOut).transform(value);

    return ClipPath(
      clipper: _CircleClipper(center: origin, radius: maxRadius * t),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // La vague : dégradé radial vert profond → vert doux, liseré doré.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  (origin.dx / size.width) * 2 - 1,
                  (origin.dy / size.height) * 2 - 1,
                ),
                radius: 1.4,
                colors: [
                  Color.lerp(AppColors.accent, AppColors.primary, halo)!,
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
          Opacity(
            opacity: contentOpacity,
            child: Transform.scale(
              scale: 0.96 + 0.04 * contentOpacity,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  static double _farthestCornerDistance(Offset o, Size s) {
    final corners = [
      Offset.zero,
      Offset(s.width, 0),
      Offset(0, s.height),
      Offset(s.width, s.height),
    ];
    return corners.map((c) => (c - o).distance).reduce(math.max);
  }
}

/// Variante pour les fenêtres superposées (ex. "Connexion requise") : le
/// contenu se dévoile en cercle depuis le point touché, sans fond plein,
/// pour laisser la page d'en dessous visible.
class CircleRevealTransition extends StatefulWidget {
  const CircleRevealTransition({super.key, required this.animation, required this.child});
  final Animation<double> animation;
  final Widget child;

  @override
  State<CircleRevealTransition> createState() => _CircleRevealTransitionState();
}

class _CircleRevealTransitionState extends State<CircleRevealTransition> {
  final Offset? _origin = TapTracker.lastPosition;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      child: widget.child,
      builder: (context, child) {
        final value = widget.animation.value;
        if (value >= 1) return child!;
        if (widget.animation.status == AnimationStatus.reverse) {
          return Opacity(opacity: Curves.easeIn.transform(value), child: child);
        }
        final size = MediaQuery.sizeOf(context);
        final origin = _origin ?? Offset(size.width / 2, size.height / 2);
        final t = Curves.easeOutCubic.transform(value);
        final radius = _RevealTransitionState._farthestCornerDistance(origin, size) * t;
        return ClipPath(
          clipper: _CircleClipper(center: origin, radius: radius),
          child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
        );
      },
    );
  }
}

class _CircleClipper extends CustomClipper<Path> {
  const _CircleClipper({required this.center, required this.radius});
  final Offset center;
  final double radius;

  @override
  Path getClip(Size size) =>
      Path()..addOval(Rect.fromCircle(center: center, radius: radius));

  @override
  bool shouldReclip(_CircleClipper old) => old.radius != radius || old.center != center;
}

/// Animation de changement d'onglet du shell (Accueil, Universités,
/// Emplois…) : la page glisse vers le haut en apparaissant, et un trait
/// doré balaie le haut de l'écran. Ne recrée pas l'enfant : l'état des
/// onglets est conservé.
class BranchSwitchAnimator extends StatefulWidget {
  const BranchSwitchAnimator({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<BranchSwitchAnimator> createState() => _BranchSwitchAnimatorState();
}

class _BranchSwitchAnimatorState extends State<BranchSwitchAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    value: 1,
  );

  @override
  void didUpdateWidget(BranchSwitchAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final v = _controller.value;
        if (v >= 1) return child!;
        final t = Curves.easeOutCubic.transform(v);
        final fade = const Interval(0, 0.7, curve: Curves.easeOut).transform(v);
        final sweep = Curves.easeInOutCubic.transform(v);

        return Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: fade,
              child: Transform.translate(
                offset: Offset(0, 22 * (1 - t)),
                child: Transform.scale(scale: 0.985 + 0.015 * t, child: child),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 1 - Curves.easeIn.transform(v),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: sweep,
                    child: Container(
                      height: 3,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(3)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
