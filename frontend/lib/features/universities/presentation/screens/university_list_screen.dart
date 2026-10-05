import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/entity_card.dart';
import '../../../../shared/widgets/region_dropdown_chip.dart';
import '../../../../shared/widgets/search_bar_custom.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/universite.dart';
import '../providers/university_provider.dart';

class UniversityListScreen extends ConsumerWidget {
  const UniversityListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universitiesAsync = ref.watch(universityListProvider);
    final filters = ref.watch(universityFiltersProvider);
    final selection = ref.watch(universityCompareSelectionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Universités'),
        actions: [
          if (selection.isNotEmpty)
            TextButton(
              onPressed: () => context.push(RoutePaths.universitiesCompare),
              child: Text('Comparer (${selection.length})'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(universityListProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SearchBarCustom(
                  hint: 'Nom d\'université ou région...',
                  onSubmitted: (value) => ref.read(universityFiltersProvider.notifier).state =
                      filters.copyWith(q: value.isEmpty ? null : value),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final type in EtablissementType.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(type.label),
                          selected: filters.type == type,
                          onSelected: (selected) {
                            ref.read(universityFiltersProvider.notifier).state = filters.copyWith(
                              type: selected ? type : null,
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Un clic déroule les 14 régions, un autre les range.
                    RegionDropdownChip(
                      selected: filters.region,
                      onSelected: (region) {
                        ref.read(universityFiltersProvider.notifier).state =
                            UniversityFilters(
                          region: region,
                          type: filters.type,
                          q: filters.q,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            universitiesAsync.when(
              loading: () => const SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(child: SkeletonCard(height: 180)),
              ),
              error: (error, _) => SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Impossible de charger les universités',
                  message: error is Failure ? error.message : null,
                  actionLabel: 'Réessayer',
                  onAction: () => ref.read(universityListProvider.notifier).refresh(),
                ),
              ),
              data: (page) => page.items.isEmpty
                  ? const SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.school_outlined,
                        title: 'Aucune université trouvée',
                        message: 'Modifiez vos critères de recherche.',
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: context.isMobile ? 220 : 260,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.82,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final u = page.items[i];
                            final isSelected = selection.contains(u.id);
                            return EntityCard(
                              imageUrl: u.imageUrl ?? '',
                              title: u.nom,
                              subtitle: u.localisation,
                              badge: u.type.label,
                              width: double.infinity,
                              height: double.infinity,
                              trailingText: isSelected ? '✓ Sélection' : null,
                              onTap: () =>
                                  context.push(RoutePaths.universityDetailPath(u.id)),
                              onFavoriteTap: () {
                                final notifier =
                                    ref.read(universityCompareSelectionProvider.notifier);
                                if (isSelected) {
                                  notifier.state =
                                      selection.where((id) => id != u.id).toList();
                                } else if (selection.length < 4) {
                                  notifier.state = [...selection, u.id];
                                } else {
                                  context.showSnack('Maximum 4 universités à comparer');
                                }
                              },
                              isFavorite: isSelected,
                            );
                          },
                          childCount: page.items.length,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
