import 'package:flutter/material.dart';

/// Centre et plafonne la largeur du contenu sur desktop/web pour éviter
/// qu'un bloc de texte ou une grille s'étire sur toute la largeur d'un
/// écran 1920px. No-op en dessous de [maxWidth] (mobile/tablette).
class ContentMaxWidth extends StatelessWidget {
  const ContentMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = 1040,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
