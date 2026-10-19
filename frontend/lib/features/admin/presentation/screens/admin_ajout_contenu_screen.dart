import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../jobs/presentation/providers/job_provider.dart';
import '../../../news/presentation/providers/news_provider.dart';
import '../../data/datasources/assistant_remote_datasource.dart';
import '../widgets/assistant_widgets.dart';

/// Ajout d'une actualité ou d'une offre (emploi, stage...) par un administrateur :
/// 1) coller le lien de la page, 2) l'IA la lit (titre, résumé, date, image, organisme,
/// date limite), 3) relecture puis publication — affichée comme celles trouvées par l'IA.
/// Sans lien (annonce interne), on peut aussi tout remplir à la main.
class AdminAjoutContenuScreen extends ConsumerStatefulWidget {
  const AdminAjoutContenuScreen({super.key, required this.genre});

  /// 'actualite' ou 'offre'.
  final String genre;

  @override
  ConsumerState<AdminAjoutContenuScreen> createState() => _State();
}

class _State extends ConsumerState<AdminAjoutContenuScreen> {
  final _lien = TextEditingController();
  final _titre = TextEditingController();
  final _resume = TextEditingController();
  final _entreprise = TextEditingController();
  final _region = TextEditingController();
  final _dateLimite = TextEditingController();

  bool _enCours = false;
  bool _publication = false;
  bool _formulaire = false;
  bool _deja = false;
  String? _erreur;
  String? _image;
  String? _imageTrouvee; // gardée même si l'administrateur choisit « Aucune »
  String? _datePublication;
  late String _categorie = widget.genre == 'offre' ? 'emploi' : 'general';

  bool get _offre => widget.genre == 'offre';

  static const _categoriesActualite = {
    'general': 'Général', 'bourse': 'Bourse', 'concours': 'Concours', 'evenement': 'Événement', 'formation': 'Formation',
  };
  static const _typesOffre = {
    'emploi': 'Emploi', 'stage': 'Stage', 'alternance': 'Alternance', 'formation': 'Formation', 'bourse': 'Bourse',
    'concours': 'Concours',
  };

  @override
  void dispose() {
    for (final c in [_lien, _titre, _resume, _entreprise, _region, _dateLimite]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _analyser() async {
    final url = _lien.text.trim();
    if (!url.startsWith('http')) {
      setState(() => _erreur = 'Collez un lien complet (commençant par https://).');
      return;
    }
    setState(() {
      _enCours = true;
      _erreur = null;
    });
    try {
      final p = await ref.read(assistantDataSourceProvider).analyserLien(url, widget.genre);
      setState(() {
        _formulaire = true;
        _deja = p['deja_present'] == true;
        _lien.text = (p['source_url'] as String?) ?? url;
        _titre.text = (p['titre'] as String?) ?? '';
        _resume.text = (p['resume'] as String?) ?? '';
        _image = p['image'] as String?;
        _imageTrouvee = _image;
        _datePublication = p['date_publication'] as String?;
        if (_offre) {
          _categorie = (p['type'] as String?) ?? 'emploi';
          _entreprise.text = (p['entreprise'] as String?) ?? '';
          _region.text = (p['region'] as String?) ?? '';
          _dateLimite.text = (p['date_limite'] as String?) ?? '';
        } else {
          _categorie = (p['categorie'] as String?) ?? 'general';
        }
      });
    } on AssistantException catch (e) {
      setState(() => _erreur = e.message);
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  Future<void> _publier() async {
    String? vide(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    setState(() => _publication = true);
    try {
      await ref.read(assistantDataSourceProvider).publier(widget.genre, {
        'titre': _titre.text.trim(),
        'resume': _resume.text.trim(),
        'source_url': vide(_lien),
        'date_publication': _datePublication,
        if (_offre) ...{
          'type': _categorie,
          'entreprise': vide(_entreprise),
          'region': vide(_region),
          'date_limite': vide(_dateLimite),
        } else ...{
          'categorie': _categorie,
          'image': _image,
        },
      });
      if (!mounted) return;
      if (_offre) {
        ref.invalidate(jobListProvider);
      } else {
        ref.invalidate(newsListProvider);
      }
      context.showSnack(_offre ? 'Offre publiée.' : 'Actualité publiée.');
      context.go(_offre ? RoutePaths.jobs : RoutePaths.news);
    } on AssistantException catch (e) {
      if (mounted) context.showSnack(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _publication = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final libelles = _offre ? _typesOffre : _categoriesActualite;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_offre ? 'Ajouter un emploi / stage' : 'Ajouter une actualité')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          EtapesAide(etapes: [
            _offre
                ? "Collez le lien de l'offre (site de l'entreprise, Senjob, Emploi Dakar…)."
                : "Collez le lien de l'article (site officiel, presse reconnue).",
            "L'IA lit la page : titre, résumé, date, image${_offre ? ', organisme, lieu, date limite' : ''}.",
            'Vérifiez, corrigez, choisissez la catégorie puis publiez : elle apparaît comme celles de la veille IA.',
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: _lien,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(labelText: 'Lien de la page', prefixIcon: Icon(Icons.link_rounded)),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _enCours ? null : _analyser,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(_enCours ? 'Lecture en cours…' : 'Analyser le lien'),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () => setState(() => _formulaire = true),
              child: const Text('Remplir à la main'),
            ),
          ]),
          if (_enCours) const ChargementRecherche(texte: 'Lecture de la page…'),
          if (_erreur != null) MessageErreur(texte: _erreur!),
          if (_formulaire) ...[
            const SizedBox(height: 20),
            if (_deja)
              const AvertissementDoublon(
                titre: 'Ce lien est déjà publié dans l\'application',
                lignes: ['La veille IA ou un administrateur l\'a déjà ajouté.'],
              ),
            const TitreSection('À vérifier avant publication'),
            ChampTexte(controleur: _titre, label: _offre ? 'Intitulé du poste *' : 'Titre *'),
            DropdownButtonFormField<String>(
              value: libelles.containsKey(_categorie) ? _categorie : libelles.keys.first,
              decoration: InputDecoration(labelText: _offre ? 'Type' : 'Catégorie'),
              items: [for (final e in libelles.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
              onChanged: (v) => setState(() => _categorie = v ?? _categorie),
            ),
            const SizedBox(height: 12),
            if (_offre) ...[
              ChampTexte(controleur: _entreprise, label: 'Entreprise / organisme'),
              Row(children: [
                Expanded(child: ChampTexte(controleur: _region, label: 'Lieu (région)')),
                const SizedBox(width: 10),
                Expanded(child: ChampTexte(controleur: _dateLimite, label: 'Date limite (AAAA-MM-JJ)')),
              ]),
            ],
            ChampTexte(controleur: _resume, label: _offre ? 'Description' : 'Résumé *', lignes: 5),
            if (!_offre && _imageTrouvee != null) ...[
              Text('Image', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ChoixImage(images: [_imageTrouvee!], choisie: _image, onChoix: (i) => setState(() => _image = i)),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _publication ? null : _publier,
              icon: const Icon(Icons.publish_rounded),
              label: Text(_publication ? 'Publication…' : 'Publier'),
            ),
          ],
        ],
      ),
    );
  }
}
