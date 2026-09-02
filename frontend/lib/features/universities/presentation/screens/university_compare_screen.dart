import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/universite.dart';
import '../providers/university_provider.dart';

class UniversityCompareScreen extends ConsumerWidget {
  const UniversityCompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(universityCompareSelectionProvider);
    final compareAsync = ref.watch(universityCompareProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Comparer les universités'),
        actions: [
          if (selection.isNotEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(universityCompareSelectionProvider.notifier).state = [],
              child: const Text('Effacer'),
            ),
        ],
      ),
      body: selection.length < 2
          ? const EmptyState(
              icon: Icons.compare_arrows_rounded,
              title: 'Sélectionnez au moins 2 universités',
              message:
                  'Depuis la liste des universités, appuyez sur l\'icône favori d\'une carte '
                  'pour l\'ajouter à la comparaison (4 maximum).',
            )
          : compareAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Comparaison impossible',
                message: error is Failure ? error.message : null,
              ),
              data: (universites) => _CompareTable(universites: universites),
            ),
    );
  }
}

class _CompareTable extends StatelessWidget {
  const _CompareTable({required this.universites});
  final List<Universite> universites;

  static const _rows = [
    ('Type', _RowKind.type),
    ('Localisation', _RowKind.localisation),
    ('Formations', _RowKind.formationsCount),
    ('Bourses disponibles', _RowKind.boursesCount),
    ('Logement', _RowKind.logementsCount),
    ('Frais de scolarité', _RowKind.frais),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowColor: WidgetStateProperty.all(AppColors.greenSoft),
        columns: [
          const DataColumn(label: Text('Critère')),
          for (final u in universites)
            DataColumn(
              label: SizedBox(
                width: 140,
                child: Text(
                  u.nom,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
        rows: [
          for (final (label, kind) in _rows)
            DataRow(
              cells: [
                DataCell(Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
                for (final u in universites) DataCell(Text(_valueFor(u, kind))),
              ],
            ),
        ],
      ),
    );
  }

  String _valueFor(Universite u, _RowKind kind) {
    switch (kind) {
      case _RowKind.type:
        return u.type.label;
      case _RowKind.localisation:
        return u.localisation.isEmpty ? '—' : u.localisation;
      case _RowKind.formationsCount:
        return '${u.formations.length}';
      case _RowKind.boursesCount:
        return '${u.bourses.length}';
      case _RowKind.logementsCount:
        return u.logements.isEmpty ? 'Non renseigné' : '${u.logements.length} option(s)';
      case _RowKind.frais:
        return u.fraisScolarite.isEmpty
            ? 'Non renseigné'
            : '${u.fraisScolarite.first.montant.toStringAsFixed(0)} ${u.fraisScolarite.first.devise}';
    }
  }
}

enum _RowKind { type, localisation, formationsCount, boursesCount, logementsCount, frais }
