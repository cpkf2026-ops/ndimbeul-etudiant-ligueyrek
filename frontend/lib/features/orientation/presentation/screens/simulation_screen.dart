import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../universities/domain/entities/formation.dart';
import '../../../universities/domain/usecases/get_formations.dart';
import '../../../universities/presentation/providers/formation_provider.dart';

/// Simulation de parcours — visualise un enchaînement de niveaux
/// (Licence→Master→Doctorat ou BTS→Licence Pro→Master) avec, à chaque
/// étape, des formations réellement référencées (§4.4). Purement indicatif :
/// aucun endpoint backend dédié n'existe, la simulation s'appuie sur la
/// recherche de formations déjà exposée par la feature `universities`.
class SimulationScreen extends ConsumerStatefulWidget {
  const SimulationScreen({super.key});

  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _ParcoursTemplate {
  const _ParcoursTemplate(this.label, this.etapes);
  final String label;
  final List<NiveauFormation> etapes;
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  static const _domaines = [
    'Informatique',
    'Économie',
    'Droit',
    'Agronomie',
    'Marketing',
    'Lettres',
  ];

  static const _parcours = [
    _ParcoursTemplate('Licence → Master → Doctorat', [
      NiveauFormation.licence,
      NiveauFormation.master,
      NiveauFormation.doctorat,
    ]),
    _ParcoursTemplate('BTS → Licence → Master', [
      NiveauFormation.bts,
      NiveauFormation.licence,
      NiveauFormation.master,
    ]),
  ];

  String _domaine = _domaines.first;
  int _parcoursIndex = 0;

  @override
  Widget build(BuildContext context) {
    final template = _parcours[_parcoursIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Simulation de parcours')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Choisissez un domaine et un type de parcours pour visualiser des '
            'exemples d\'universités à chaque étape — une projection indicative, '
            'pas un chemin obligatoire.',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final domaine in _domaines)
                ChoiceChip(
                  label: Text(domaine),
                  selected: _domaine == domaine,
                  onSelected: (_) => setState(() => _domaine = domaine),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: [
              for (var i = 0; i < _parcours.length; i++)
                ButtonSegment(value: i, label: Text(_parcours[i].label)),
            ],
            selected: {_parcoursIndex},
            onSelectionChanged: (selection) =>
                setState(() => _parcoursIndex = selection.first),
          ),
          const SizedBox(height: 28),
          for (var i = 0; i < template.etapes.length; i++)
            _EtapeTile(
              index: i,
              isLast: i == template.etapes.length - 1,
              niveau: template.etapes[i],
              domaine: _domaine,
            ),
        ],
      ),
    );
  }
}

class _EtapeTile extends ConsumerWidget {
  const _EtapeTile({
    required this.index,
    required this.isLast,
    required this.niveau,
    required this.domaine,
  });

  final int index;
  final bool isLast;
  final NiveauFormation niveau;
  final String domaine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formationsAsync = ref.watch(
      _stepFormationsProvider((domaine: domaine, niveau: niveau)),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: AppColors.border)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(niveau.label, style: context.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  formationsAsync.when(
                    loading: () => const SkeletonLoader(height: 60),
                    error: (_, _) => Text(
                      'Aucune formation trouvée pour ce domaine à ce niveau.',
                      style: context.textTheme.bodyMedium,
                    ),
                    data: (formations) => formations.isEmpty
                        ? Text(
                            'Aucune formation référencée pour "$domaine" à ce niveau.',
                            style: context.textTheme.bodyMedium,
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final formation in formations.take(3))
                                ActionChip(
                                  avatar: const Icon(Icons.school_outlined, size: 16),
                                  label: Text(formation.universiteNom ?? formation.intitule),
                                  onPressed: () => context.push(
                                    RoutePaths.universityDetailPath(formation.universiteId),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef _StepKey = ({String domaine, NiveauFormation niveau});

final _stepFormationsProvider =
    FutureProvider.family<List<Formation>, _StepKey>((ref, key) async {
  final result = await ref.read(getFormationsUseCaseProvider).call(
        GetFormationsParams(domaine: key.domaine, niveau: key.niveau, perPage: 5),
      );
  return result.fold((failure) => throw failure, (page) => page.items);
});
