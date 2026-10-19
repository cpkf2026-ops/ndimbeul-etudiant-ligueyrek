import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router/route_paths.dart';

/// Ouvre directement le SITE OFFICIEL de l'établissement (nouvel onglet), quand il est
/// connu ; sinon sa fiche dans l'application (43 établissements sur 70 n'ont pas encore
/// de site renseigné en base — aucune adresse n'est devinée).
Future<void> ouvrirUniversite(
  BuildContext context, {
  required String id,
  String? siteWebOfficiel,
}) async {
  final site = _adresseSite(siteWebOfficiel);
  if (site != null && await launchUrl(site, webOnlyWindowName: '_blank')) return;
  if (context.mounted) context.push(RoutePaths.universityDetailPath(id));
}

/// « ucad.sn » ou « https://www.ucad.sn/ » -> adresse web exploitable, ou null.
Uri? _adresseSite(String? valeur) {
  final texte = valeur?.trim() ?? '';
  if (texte.isEmpty) return null;
  final uri = Uri.tryParse(texte.startsWith('http') ? texte : 'https://$texte');
  return (uri != null && uri.host.contains('.')) ? uri : null;
}
