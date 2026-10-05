import 'package:flutter/material.dart';
import 'etablissement_avatar.dart' show couleurDepuisNom;

/// Remplace une image manquante par le nom de l'établissement en grand sur un fond de
/// couleur (dérivée du nom, donc stable) plutôt qu'une photo générique par défaut —
/// trompeuse car elle ne correspond à rien de réel.
class NamePlaceholder extends StatelessWidget {
  const NamePlaceholder({super.key, required this.name, this.fontSize = 15});

  final String name;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final couleur = couleurDepuisNom(name);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [couleur, couleur.withValues(alpha: 0.75)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              height: 1.25,
            ),
          ),
        ),
      ),
    );
  }
}
