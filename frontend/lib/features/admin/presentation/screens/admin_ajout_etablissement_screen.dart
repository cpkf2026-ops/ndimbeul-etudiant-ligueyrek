import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../universities/presentation/providers/university_provider.dart';
import '../../data/datasources/assistant_remote_datasource.dart';
import '../widgets/assistant_widgets.dart';

/// Ajout d'un établissement en 3 étapes : 1) nom, 2) recherche web par l'IA,
/// 3) relecture de la proposition puis ajout au catalogue.
class AdminAjoutEtablissementScreen extends ConsumerStatefulWidget {
  const AdminAjoutEtablissementScreen({super.key});

  @override
  ConsumerState<AdminAjoutEtablissementScreen> createState() => _State();
}

class _State extends ConsumerState<AdminAjoutEtablissementScreen> {
  final _recherche = TextEditingController();
  final _nom = TextEditingController();
  final _region = TextEditingController();
  final _commune = TextEditingController();
  final _adresse = TextEditingController();
  final _site = TextEditingController();
  final _description = TextEditingController();

  bool _enCours = false;
  bool _publication = false;
  String? _erreur;
  Map<String, dynamic>? _proposition;
  String? _type; // public | prive | null (non vérifié)
  String? _image;

  @override
  void dispose() {
    for (final c in [_recherche, _nom, _region, _commune, _adresse, _site, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _rechercher() async {
    final nom = _recherche.text.trim();
    if (nom.length < 3) {
      setState(() => _erreur = "Tapez le nom de l'établissement (3 caractères au moins).");
      return;
    }
    setState(() {
      _enCours = true;
      _erreur = null;
      _proposition = null;
    });
    try {
      final p = await ref.read(assistantDataSourceProvider).rechercherEtablissement(nom);
      setState(() {
        _proposition = p;
        _nom.text = (p['nom'] as String?) ?? nom;
        _region.text = (p['region'] as String?) ?? '';
        _commune.text = (p['commune'] as String?) ?? '';
        _site.text = (p['site_web_officiel'] as String?) ?? '';
        _description.text = (p['description'] as String?) ?? '';
        _type = p['type'] as String?;
        final images = (p['images'] as List?)?.cast<String>() ?? [];
        _image = images.isNotEmpty ? images.first : null;
      });
    } on AssistantException catch (e) {
      setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<void> _publier() async {
    if (_nom.text.trim().isEmpty) {
      context.showSnack('Le nom est obligatoire.', isError: true);
      return;
    }
    setState(() => _publication = true);
    try {
      String? vide(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
      await ref.read(assistantDataSourceProvider).publier('etablissement', {
        'nom': _nom.text.trim(),
        'type': _type,
        'region': vide(_region),
        'commune': vide(_commune),
        'adresse': vide(_adresse),
        'site_web_officiel': vide(_site),
        'description': vide(_description),
        'image': _image,
        'sources': _proposition?['sources'] ?? [],
      });
      if (!mounted) return;
      ref.invalidate(universityListProvider);
      context.showSnack('Établissement ajouté au catalogue.');
      context.go(RoutePaths.universities);
    } on AssistantException catch (e) {
      if (mounted) context.showSnack(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _publication = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _proposition;
    final deja = (p?['deja_present'] as List?)?.cast<Map>() ?? [];
    final images = (p?['images'] as List?)?.cast<String>() ?? [];
    final sources = (p?['sources'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ajouter un établissement')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          const EtapesAide(etapes: [
            "Tapez le nom de l'université ou de l'institut.",
            "L'IA cherche sur le web : site officiel, présentation, lieu, statut, logo.",
            'Vérifiez et corrigez la proposition, puis ajoutez-la au catalogue.',
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: _recherche,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _rechercher(),
            decoration: const InputDecoration(
              labelText: "Nom de l'établissement",
              hintText: 'Ex. : Institut Supérieur de Santé de Kaolack',
              prefixIcon: Icon(Icons.school_outlined),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _enCours ? null : _rechercher,
            icon: const Icon(Icons.travel_explore_rounded),
            label: Text(_enCours ? 'Recherche en cours…' : 'Rechercher sur le web'),
          ),
          if (_enCours) const ChargementRecherche(texte: 'Recherche web et lecture du site officiel (20 à 40 s)…'),
          if (_erreur != null) MessageErreur(texte: _erreur!),
          if (p != null) ...[
            const SizedBox(height: 20),
            if (deja.isNotEmpty)
              AvertissementDoublon(
                titre: 'Déjà dans le catalogue ?',
                lignes: [for (final d in deja) '${d['nom']}${d['commune'] != null ? ' — ${d['commune']}' : ''}'],
                onOuvrir: (i) => context.push(RoutePaths.universityDetailPath(deja[i]['id'] as String)),
              ),
            const TitreSection('Proposition à vérifier'),
            ChampTexte(controleur: _nom, label: 'Nom officiel *'),
            DropdownButtonFormField<String?>(
              value: _type,
              decoration: InputDecoration(
                labelText: 'Statut',
                helperText: p['preuve_type'] as String?,
                helperMaxLines: 3,
              ),
              items: const [
                DropdownMenuItem(value: 'public', child: Text('Public')),
                DropdownMenuItem(value: 'prive', child: Text('Privé')),
                DropdownMenuItem(value: null, child: Text('Non vérifié (ne rien afficher)')),
              ],
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ChampTexte(controleur: _commune, label: 'Quartier / commune')),
              const SizedBox(width: 10),
              Expanded(child: ChampTexte(controleur: _region, label: 'Région')),
            ]),
            ChampTexte(controleur: _adresse, label: 'Adresse (facultatif)'),
            ChampTexte(controleur: _site, label: 'Site officiel', clavier: TextInputType.url),
            ChampTexte(controleur: _description, label: 'Présentation', lignes: 5),
            if (images.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Image / logo', style: context.textTheme.titleMedium),
              const SizedBox(height: 8),
              ChoixImage(images: images, choisie: _image, onChoix: (i) => setState(() => _image = i)),
            ],
            if (sources.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Sources consultées', style: context.textTheme.titleMedium),
              for (final s in sources)
                TextButton(
                  style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.zero),
                  onPressed: () => launchUrl(Uri.parse(s), mode: LaunchMode.externalApplication),
                  child: Text(s, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _publication ? null : _publier,
              icon: const Icon(Icons.add_task_rounded),
              label: Text(_publication ? 'Ajout en cours…' : 'Ajouter au catalogue'),
            ),
          ],
        ],
      ),
    );
  }
}
