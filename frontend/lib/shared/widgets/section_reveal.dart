import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Primitive d'animation d'entrée unique, réutilisée par tous les écrans
/// au lieu que chacun réinvente son propre AnimationController. Fondu +
/// léger glissement vertical, discret et rapide (300-450ms) pour rester
/// du polish et non de la friction — notamment utile sur le web où
/// l'utilisateur scrolle vite.
class SectionReveal extends StatelessWidget {
  const SectionReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.horizontal = false,
  });

  final Widget child;
  final Duration delay;

  /// Glissement horizontal plutôt que vertical — utile pour les listes
  /// défilant horizontalement.
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final animated = child.animate(delay: delay).fadeIn(
      duration: 380.ms,
      curve: Curves.easeOut,
    );

    return horizontal
        ? animated.slideX(begin: 0.06, end: 0, duration: 380.ms, curve: Curves.easeOut)
        : animated.slideY(begin: 0.08, end: 0, duration: 380.ms, curve: Curves.easeOut);
  }
}
