import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/role_selector.dart';

/// Étape obligatoire après l'inscription (et bloquante tant que
/// `profilComplete == false`, voir le `redirect` de app_router.dart) :
/// choix du statut puis formulaire dédié. Voir aussi EnsureProfileComplete
/// côté backend, qui applique le même garde-fou côté serveur.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  static const _statuts = [UserRole.lyceen, UserRole.etudiant, UserRole.diplome];

  UserRole? _statut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Compléter mon profil'),
        automaticallyImplyLeading: _statut != null,
        leading: _statut == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _statut = null),
              ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Encore une étape', style: context.textTheme.displayMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Choisissez votre statut pour personnaliser votre expérience.',
                    style: context.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  if (_statut == null)
                    RoleSelector(
                      value: _statut,
                      options: _statuts,
                      onChanged: (r) => setState(() => _statut = r),
                    )
                  else
                    _StatutForm(statut: _statut!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatutForm extends ConsumerStatefulWidget {
  const _StatutForm({required this.statut});
  final UserRole statut;

  @override
  ConsumerState<_StatutForm> createState() => _StatutFormState();
}

class _StatutFormState extends ConsumerState<_StatutForm> {
  // Lycéen
  String? _serieBac;
  String? _niveau;
  final _etablissementController = TextEditingController();
  int? _anneeTerminale;

  // Étudiant
  final _universiteController = TextEditingController();
  final _formationController = TextEditingController();
  String? _niveauActuel;

  // Diplômé / en poste / en stage
  final _dernierDiplomeController = TextEditingController();
  final _domaineController = TextEditingController();
  String? _situationActuelle;

  bool _isSubmitting = false;

  static const _series = ['S1', 'S2', 'S3', 'L', 'L1', 'L2', 'ES', 'STI2D', 'STG'];
  static const _niveaux = [('seconde', 'Seconde'), ('premiere', 'Première'), ('terminale', 'Terminale')];
  static const _niveauxEtudiant = ['L1', 'L2', 'L3', 'M1', 'M2', 'Doctorat'];
  static const _situations = [
    ('en_poste', 'En poste'),
    ('recherche_emploi', 'En recherche d\'emploi'),
    ('stage', 'En stage'),
  ];

  @override
  void dispose() {
    _etablissementController.dispose();
    _universiteController.dispose();
    _formationController.dispose();
    _dernierDiplomeController.dispose();
    _domaineController.dispose();
    super.dispose();
  }

  /// Libellés des champs obligatoires non renseignés — vide si le formulaire
  /// est valide. Utilisé à la fois pour bloquer l'envoi et pour dire
  /// précisément à l'utilisateur ce qu'il lui manque (voir [_submit]).
  List<String> get _missingFields => switch (widget.statut) {
        UserRole.lyceen => [
            if (_serieBac == null) 'Série au Bac',
            if (_niveau == null) 'Niveau',
            if (_etablissementController.text.trim().isEmpty) 'Établissement',
          ],
        UserRole.etudiant => [
            if (_universiteController.text.trim().isEmpty) 'Université / institut actuel',
            if (_formationController.text.trim().isEmpty) 'Filière / domaine d\'études',
            if (_niveauActuel == null) 'Niveau actuel',
          ],
        UserRole.diplome => [
            if (_dernierDiplomeController.text.trim().isEmpty) 'Dernier diplôme obtenu',
            if (_situationActuelle == null) 'Situation actuelle',
          ],
        _ => const ['statut'],
      };

  Map<String, dynamic> get _fields => switch (widget.statut) {
        UserRole.lyceen => {
            'serie_bac': _serieBac,
            'niveau': _niveau,
            'etablissement': _etablissementController.text.trim(),
            if (_anneeTerminale != null) 'annee_terminale': _anneeTerminale,
          },
        UserRole.etudiant => {
            'universite_actuelle': _universiteController.text.trim(),
            'formation_actuelle': _formationController.text.trim(),
            'niveau_actuel': _niveauActuel,
          },
        UserRole.diplome => {
            'dernier_diplome': _dernierDiplomeController.text.trim(),
            'domaine': _domaineController.text.trim().isEmpty ? null : _domaineController.text.trim(),
            'situation_actuelle': _situationActuelle,
          },
        _ => const {},
      };

  Future<void> _submit() async {
    final missing = _missingFields;
    if (missing.isNotEmpty) {
      context.showSnack('Champ obligatoire manquant : ${missing.join(', ')}', isError: true);
      return;
    }
    setState(() => _isSubmitting = true);
    final failure = await ref
        .read(authProvider.notifier)
        .completeProfile(statut: widget.statut, fields: _fields);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (failure != null) {
      context.showSnack(failure.message, isError: true);
      return;
    }
    if (mounted) context.go(RoutePaths.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        switch (widget.statut) {
          UserRole.lyceen => _lyceenFields(context),
          UserRole.etudiant => _etudiantFields(context),
          UserRole.diplome => _diplomeFields(context),
          _ => const SizedBox.shrink(),
        },
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Continuer'),
        ),
      ],
    );
  }

  Widget _lyceenFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Série au Bac', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final serie in _series)
              ChoiceChip(
                label: Text(serie),
                selected: _serieBac == serie,
                onSelected: (_) => setState(() => _serieBac = serie),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Niveau', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final (value, label) in _niveaux)
              ChoiceChip(
                label: Text(label),
                selected: _niveau == value,
                onSelected: (_) => setState(() => _niveau = value),
              ),
          ],
        ),
        const SizedBox(height: 16),
        AuthFormField(
          label: 'Établissement',
          controller: _etablissementController,
        ),
        const SizedBox(height: 16),
        Text('Année de terminale prévue', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final annee in [2026, 2027, 2028])
              ChoiceChip(
                label: Text('$annee'),
                selected: _anneeTerminale == annee,
                onSelected: (_) => setState(() => _anneeTerminale = annee),
              ),
          ],
        ),
      ],
    );
  }

  Widget _etudiantFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthFormField(
          label: 'Université / institut actuel',
          controller: _universiteController,
        ),
        const SizedBox(height: 16),
        AuthFormField(
          label: 'Filière / domaine d\'études',
          controller: _formationController,
        ),
        const SizedBox(height: 16),
        Text('Niveau actuel', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final niveau in _niveauxEtudiant)
              ChoiceChip(
                label: Text(niveau),
                selected: _niveauActuel == niveau,
                onSelected: (_) => setState(() => _niveauActuel = niveau),
              ),
          ],
        ),
      ],
    );
  }

  Widget _diplomeFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthFormField(
          label: 'Dernier diplôme obtenu',
          controller: _dernierDiplomeController,
        ),
        const SizedBox(height: 16),
        AuthFormField(
          label: 'Domaine (optionnel)',
          controller: _domaineController,
        ),
        const SizedBox(height: 16),
        Text('Situation actuelle', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (value, label) in _situations)
              ChoiceChip(
                label: Text(label),
                selected: _situationActuelle == value,
                onSelected: (_) => setState(() => _situationActuelle = value),
              ),
          ],
        ),
      ],
    );
  }
}
