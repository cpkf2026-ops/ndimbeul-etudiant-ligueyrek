import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/universities/presentation/providers/formation_provider.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_logo_button.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/profil_academique.dart';
import '../../domain/entities/profil_diplome.dart';
import '../../domain/entities/profil_etudiant.dart';
import '../../domain/entities/profil_lyceen.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: AppLogoButton(size: 32),
        ),
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              // Accueil d'abord : évite que la fenêtre "Connexion requise"
              // ne s'ouvre sur la page courante une fois déconnecté.
              context.go(RoutePaths.dashboard);
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary,
                child: Text(
                  user?.initiale ?? '?',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.nomComplet ?? '', style: context.textTheme.headlineMedium),
                    const SizedBox(height: 2),
                    Text(user?.email ?? '', style: context.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(user?.role?.label ?? '', style: context.textTheme.labelSmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ProfileLinkTile(
            icon: Icons.forum_outlined,
            title: 'Historique des conversations IA',
            onTap: () => context.push(RoutePaths.chatHistory),
          ),
          if (user?.role?.voitEmplois ?? true) ...[
            const SizedBox(height: 10),
            _ProfileLinkTile(
              icon: Icons.bookmark_border_rounded,
              title: 'Offres suivies',
              onTap: () => context.push(RoutePaths.jobsFavorites),
            ),
          ],
          if (user?.role?.isAdmin ?? false) ...[
            const SizedBox(height: 10),
            _ProfileLinkTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Back-office administration',
              onTap: () => context.push(RoutePaths.admin),
            ),
          ],
          const SizedBox(height: 24),
          Text('Formations suivies', style: context.textTheme.headlineMedium),
          const SizedBox(height: 10),
          Consumer(
            builder: (context, ref, _) {
              final favoritesAsync = ref.watch(favoriteFormationsProvider);
              return favoritesAsync.when(
                loading: () => const SkeletonLoader(height: 60),
                error: (error, _) => Text(
                  error is Failure ? error.message : 'Formations suivies indisponibles.',
                  style: context.textTheme.bodyMedium,
                ),
                data: (formations) => formations.isEmpty
                    ? Text(
                        'Ajoutez des formations à vos favoris depuis une fiche université.',
                        style: context.textTheme.bodyMedium,
                      )
                    : Column(
                        children: formations
                            .map(
                              (f) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _ProfileLinkTile(
                                  icon: Icons.school_outlined,
                                  title: f.intitule,
                                  subtitle: f.universiteNom,
                                  onTap: () => context
                                      .push(RoutePaths.universityDetailPath(f.universiteId)),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              );
            },
          ),
          const SizedBox(height: 28),
          profileAsync.when(
            loading: () => const Column(
              children: [
                SkeletonLoader(height: 20),
                SizedBox(height: 12),
                SkeletonLoader(height: 200),
              ],
            ),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Impossible de charger le profil',
              message: error is Failure ? error.message : null,
            ),
            data: (profil) => switch (profil) {
              ProfilAcademiqueLyceen(:final profil) => _LyceenForm(profil: profil),
              ProfilAcademiqueEtudiant(:final profil) => _EtudiantForm(profil: profil),
              ProfilAcademiqueDiplome(:final profil) => _DiplomeForm(profil: profil),
            },
          ),
        ],
      ),
    );
  }
}

class _CompletionBar extends StatelessWidget {
  const _CompletionBar({required this.completude});
  final int completude;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Complétude du profil', style: context.textTheme.titleMedium),
              Text(
                '$completude%',
                style: context.textTheme.titleMedium?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: completude / 100,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation(
                completude >= 80 ? AppColors.success : AppColors.accent,
              ),
            ),
          ),
          if (completude < 100) ...[
            const SizedBox(height: 8),
            Text(
              'Complétez votre profil pour des recommandations plus précises.',
              style: context.textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _LyceenForm extends ConsumerStatefulWidget {
  const _LyceenForm({required this.profil});
  final ProfilLyceen profil;

  @override
  ConsumerState<_LyceenForm> createState() => _LyceenFormState();
}

class _LyceenFormState extends ConsumerState<_LyceenForm> {
  late ProfilLyceen _draft = widget.profil;
  late final _moyenneController =
      TextEditingController(text: widget.profil.moyenneGenerale?.toString() ?? '');
  bool _saving = false;

  static const _series = ['S1', 'S2', 'S3', 'L', 'L1', 'L2', 'ES', 'STI2D', 'STG'];
  static const _regions = [
    'Dakar',
    'Thiès',
    'Saint-Louis',
    'Diourbel',
    'Ziguinchor',
    'Kaolack',
    'Tambacounda',
    'Fatick',
    'Kolda',
    'Louga',
    'Matam',
    'Kaffrine',
    'Kédougou',
    'Sédhiou',
  ];

  @override
  void dispose() {
    _moyenneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final failure = await ref.read(profileProvider.notifier).saveLyceen(_draft);
    if (!mounted) return;
    setState(() => _saving = false);
    if (failure != null) {
      context.showSnack(failure.message, isError: true);
    } else {
      context.showSnack('Profil mis à jour');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CompletionBar(completude: widget.profil.completude),
        const SizedBox(height: 24),
        Text('Série au Bac', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final serie in _series)
              ChoiceChip(
                label: Text(serie),
                selected: _draft.serieBac == serie,
                onSelected: (_) => setState(() => _draft = _draft.copyWith(serieBac: serie)),
              ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _moyenneController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Moyenne générale (/20)'),
          onChanged: (v) =>
              _draft = _draft.copyWith(moyenneGenerale: double.tryParse(v)),
        ),
        const SizedBox(height: 16),
        Text('Année de terminale', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final annee in [2025, 2026, 2027])
              ChoiceChip(
                label: Text('$annee'),
                selected: _draft.anneeTerminale == annee,
                onSelected: (_) =>
                    setState(() => _draft = _draft.copyWith(anneeTerminale: annee)),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Région cible', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _draft.regionCible,
          hint: const Text('Choisir une région'),
          items: [
            for (final region in _regions) DropdownMenuItem(value: region, child: Text(region)),
          ],
          onChanged: (v) => setState(() => _draft = _draft.copyWith(regionCible: v)),
        ),
        const SizedBox(height: 20),
        Text('Préférence établissement', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final pref in PrefEtablissement.values)
              ChoiceChip(
                label: Text(pref.label),
                selected: _draft.prefPublicPrive == pref,
                onSelected: (_) =>
                    setState(() => _draft = _draft.copyWith(prefPublicPrive: pref)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Mobilité géographique'),
          subtitle: const Text('Prêt(e) à étudier en dehors de ma région'),
          value: _draft.mobilite,
          activeThumbColor: AppColors.primary,
          onChanged: (v) => setState(() => _draft = _draft.copyWith(mobilite: v)),
        ),
        const SizedBox(height: 12),
        Text('Passions / centres d\'intérêt', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        _ChipInput(
          values: _draft.passions,
          onChanged: (values) => setState(() => _draft = _draft.copyWith(passions: values)),
          hint: 'Ajouter une passion',
        ),
        const SizedBox(height: 12),
        Text('Matières fortes', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        _ChipInput(
          values: _draft.matieresFortes,
          onChanged: (values) =>
              setState(() => _draft = _draft.copyWith(matieresFortes: values)),
          hint: 'Ex : Mathématiques, Physique-Chimie...',
        ),
        const SizedBox(height: 12),
        Text('Métiers envisagés', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        _ChipInput(
          values: _draft.metiersEnvisages,
          onChanged: (values) =>
              setState(() => _draft = _draft.copyWith(metiersEnvisages: values)),
          hint: 'Ajouter un métier',
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Enregistrer'),
          ),
        ),
      ],
    );
  }
}

class _EtudiantForm extends ConsumerStatefulWidget {
  const _EtudiantForm({required this.profil});
  final ProfilEtudiant profil;

  @override
  ConsumerState<_EtudiantForm> createState() => _EtudiantFormState();
}

class _EtudiantFormState extends ConsumerState<_EtudiantForm> {
  late ProfilEtudiant _draft = widget.profil;
  late final _universiteController =
      TextEditingController(text: widget.profil.universiteActuelle ?? '');
  late final _formationController =
      TextEditingController(text: widget.profil.formationActuelle ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _universiteController.dispose();
    _formationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final failure = await ref.read(profileProvider.notifier).saveEtudiant(_draft);
    if (!mounted) return;
    setState(() => _saving = false);
    if (failure != null) {
      context.showSnack(failure.message, isError: true);
    } else {
      context.showSnack('Profil mis à jour');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _universiteController,
          decoration: const InputDecoration(labelText: 'Université actuelle'),
          onChanged: (v) => _draft = _draft.copyWith(universiteActuelle: v),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _formationController,
          decoration: const InputDecoration(labelText: 'Formation actuelle'),
          onChanged: (v) => _draft = _draft.copyWith(formationActuelle: v),
        ),
        const SizedBox(height: 20),
        Text('Niveau actuel', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final niveau in NiveauEtudiant.values)
              ChoiceChip(
                label: Text(niveau.label),
                selected: _draft.niveauActuel == niveau,
                onSelected: (_) => setState(() => _draft = _draft.copyWith(niveauActuel: niveau)),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Domaines d\'intérêt', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        _ChipInput(
          values: _draft.domainesInterets,
          onChanged: (values) =>
              setState(() => _draft = _draft.copyWith(domainesInterets: values)),
          hint: 'Ajouter un domaine',
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Je recherche un stage'),
          value: _draft.rechercheStage,
          activeThumbColor: AppColors.primary,
          onChanged: (v) => setState(() => _draft = _draft.copyWith(rechercheStage: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Je recherche un emploi'),
          value: _draft.rechercheEmploi,
          activeThumbColor: AppColors.primary,
          onChanged: (v) => setState(() => _draft = _draft.copyWith(rechercheEmploi: v)),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Enregistrer'),
          ),
        ),
      ],
    );
  }
}

class _DiplomeForm extends ConsumerStatefulWidget {
  const _DiplomeForm({required this.profil});
  final ProfilDiplome profil;

  @override
  ConsumerState<_DiplomeForm> createState() => _DiplomeFormState();
}

class _DiplomeFormState extends ConsumerState<_DiplomeForm> {
  late ProfilDiplome _draft = widget.profil;
  late final _dernierDiplomeController =
      TextEditingController(text: widget.profil.dernierDiplome ?? '');
  late final _domaineController = TextEditingController(text: widget.profil.domaine ?? '');
  late final _entrepriseController =
      TextEditingController(text: widget.profil.entreprise ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _dernierDiplomeController.dispose();
    _domaineController.dispose();
    _entrepriseController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final failure = await ref.read(profileProvider.notifier).saveDiplome(_draft);
    if (!mounted) return;
    setState(() => _saving = false);
    if (failure != null) {
      context.showSnack(failure.message, isError: true);
    } else {
      context.showSnack('Profil mis à jour');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _dernierDiplomeController,
          decoration: const InputDecoration(labelText: 'Dernier diplôme obtenu'),
          onChanged: (v) => _draft = _draft.copyWith(dernierDiplome: v),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _domaineController,
          decoration: const InputDecoration(labelText: 'Domaine'),
          onChanged: (v) => _draft = _draft.copyWith(domaine: v),
        ),
        const SizedBox(height: 20),
        Text('Situation actuelle', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final situation in SituationActuelle.values)
              ChoiceChip(
                label: Text(situation.label),
                selected: _draft.situationActuelle == situation,
                onSelected: (_) => setState(() => _draft = _draft.copyWith(situationActuelle: situation)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _entrepriseController,
          decoration: const InputDecoration(labelText: 'Entreprise'),
          onChanged: (v) => _draft = _draft.copyWith(entreprise: v),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Enregistrer'),
          ),
        ),
      ],
    );
  }
}

/// Saisie de tags libres (passions, métiers, domaines) — ajout via champ +
/// suppression via chip fermable.
class _ChipInput extends StatefulWidget {
  const _ChipInput({required this.values, required this.onChanged, required this.hint});

  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final String hint;

  @override
  State<_ChipInput> createState() => _ChipInputState();
}

class _ChipInputState extends State<_ChipInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || widget.values.contains(trimmed)) return;
    widget.onChanged([...widget.values, trimmed]);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in widget.values)
              Chip(
                label: Text(value),
                onDeleted: () =>
                    widget.onChanged(widget.values.where((v) => v != value).toList()),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _add(_controller.text),
            ),
          ),
          onSubmitted: _add,
        ),
      ],
    );
  }
}

class _ProfileLinkTile extends StatelessWidget {
  const _ProfileLinkTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
