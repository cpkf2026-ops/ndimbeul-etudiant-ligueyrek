import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

const _palette = [
  Color(0xFF0B6E4F),
  Color(0xFF1B998B),
  Color(0xFF2D6A4F),
  Color(0xFF3D5A80),
  Color(0xFF7A5195),
  Color(0xFFB5651D),
  Color(0xFF9C6644),
  Color(0xFF457B9D),
];

/// Couleur stable dérivée du nom : le même établissement garde toujours la même
/// couleur d'avatar, sur tous les écrans et à chaque rechargement.
Color couleurDepuisNom(String nom) =>
    _palette[nom.codeUnits.fold<int>(0, (acc, c) => acc + c) % _palette.length];

/// Avatar d'établissement (Tâche 2 du cahier des charges "développeur senior") :
/// - `logoUrl` renseigné -> vrai logo, mis en cache (cached_network_image), avec un
///   indicateur de chargement pendant le téléchargement ;
/// - `logoUrl` absent ou en erreur réseau -> repli sur un rond de couleur stable
///   (dérivée du nom) avec le sigle (ou les initiales du nom si pas de sigle) en
///   blanc, gras, centré — jamais de photo générique par défaut.
class EtablissementAvatar extends StatelessWidget {
  const EtablissementAvatar({
    super.key,
    required this.nom,
    this.logoUrl,
    this.sigle,
    this.size = 48,
  });

  final String nom;
  final String? logoUrl;
  final String? sigle;
  final double size;

  String get _libelle {
    if (sigle != null && sigle!.trim().isNotEmpty) return sigle!.trim();
    final mots = nom.trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty).toList();
    if (mots.isEmpty) return '?';
    if (mots.length == 1) return mots.first.substring(0, 1).toUpperCase();
    return (mots.first.substring(0, 1) + mots[1].substring(0, 1)).toUpperCase();
  }

  Widget _repli() {
    final couleur = couleurDepuisNom(nom);
    return DecoratedBox(
      decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(size * 0.08),
          child: FittedBox(
            child: Text(
              _libelle,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.38,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = logoUrl;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: (url == null || url.isEmpty)
            ? _repli()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, _) => DecoratedBox(
                  decoration: BoxDecoration(color: couleurDepuisNom(nom).withValues(alpha: 0.25)),
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, _, error) => _repli(),
              ),
      ),
    );
  }
}
