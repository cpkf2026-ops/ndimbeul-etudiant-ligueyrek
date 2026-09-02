import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/constants/app_images.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/favorite_button.dart';
import '../../../../shared/widgets/source_badge.dart';
import '../../domain/entities/formation.dart';
import '../../domain/entities/universite.dart';
import '../providers/formation_provider.dart';
import '../providers/university_provider.dart';

class UniversityDetailScreen extends ConsumerWidget {
  const UniversityDetailScreen({super.key, required this.universityId});

  final String universityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universiteAsync = ref.watch(universityDetailProvider(universityId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: universiteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Scaffold(
          appBar: AppBar(),
          body: EmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Université introuvable',
            message: error is Failure ? error.message : null,
          ),
        ),
        data: (universite) => _UniversityDetailBody(universite: universite),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.chat),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.smart_toy_outlined, color: AppColors.primary),
        label: const Text(
          'Demander à l\'IA',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _UniversityDetailBody extends StatelessWidget {
  const _UniversityDetailBody({required this.universite});
  final Universite universite;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Builder(
                  builder: (context) {
                    final src = universite.imageUrl ?? AppImages.campusGeneric1;
                    return src.startsWith('assets/')
                        ? Image.asset(src, fit: BoxFit.cover)
                        : Image.network(
                            src,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                Image.network(AppImages.campusGeneric1, fit: BoxFit.cover),
                          );
                  },
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.primary.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              universite.nom,
              maxLines: 2,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.greenSoft,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        universite.type.label,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.place_outlined, size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(universite.localisation, style: context.textTheme.bodyMedium),
                    ),
                  ],
                ),
                if (universite.description != null) ...[
                  const SizedBox(height: 16),
                  Text(universite.description!, style: context.textTheme.bodyLarge),
                ],
                if (universite.siteWebOfficiel != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(universite.siteWebOfficiel!),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.language_rounded),
                    label: const Text('Site officiel'),
                  ),
                ],
                const SizedBox(height: 28),
                _Section(
                  title: 'Formations (${universite.formations.length})',
                  child: universite.formations.isEmpty
                      ? const Text('Aucune formation référencée pour le moment.')
                      : Column(
                          children: universite.formations
                              .map((f) => _FormationTile(
                                    formation: f,
                                    universiteId: universite.id,
                                  ))
                              .toList(),
                        ),
                ),
                if (universite.bourses.isNotEmpty)
                  _Section(
                    title: 'Bourses',
                    child: Column(
                      children: universite.bourses.map((b) {
                        return _InfoCard(
                          title: b.nom,
                          lines: [
                            if (b.montant != null)
                              '${b.montant!.toStringAsFixed(0)} ${b.devise} / an',
                            if (b.conditions != null) b.conditions!,
                            if (b.dateLimite != null)
                              'Date limite : ${DateFormatter.short(b.dateLimite!)}',
                          ],
                          source: b.source,
                          dateMaj: b.dateMaj,
                        );
                      }).toList(),
                    ),
                  ),
                if (universite.logements.isNotEmpty)
                  _Section(
                    title: 'Logement',
                    child: Column(
                      children: universite.logements.map((l) {
                        return _InfoCard(
                          title: l.nom,
                          lines: [
                            l.type.label,
                            if (l.tarifMensuel != null)
                              '${l.tarifMensuel!.toStringAsFixed(0)} ${l.devise} / mois',
                            if (l.capacite != null) 'Capacité : ${l.capacite} places',
                          ],
                          source: l.source,
                          dateMaj: l.dateMaj,
                        );
                      }).toList(),
                    ),
                  ),
                if (universite.fraisScolarite.isNotEmpty)
                  _Section(
                    title: 'Frais de scolarité',
                    child: Column(
                      children: universite.fraisScolarite.map((f) {
                        return _InfoCard(
                          title: '${f.montant.toStringAsFixed(0)} ${f.devise} / an',
                          lines: [
                            if (f.moyensPaiement != null && f.moyensPaiement!.isNotEmpty)
                              'Paiement : ${f.moyensPaiement!.join(', ')}',
                          ],
                          source: f.source,
                          dateMaj: f.dateMaj,
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.textTheme.headlineMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _FormationTile extends ConsumerWidget {
  const _FormationTile({required this.formation, required this.universiteId});
  final Formation formation;
  final String universiteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> toggleFavorite() async {
      final usecase = formation.estFavori
          ? ref.read(unfavoriteFormationUseCaseProvider)
          : ref.read(favoriteFormationUseCaseProvider);
      final result = await usecase.call(formation.id);
      result.fold(
        (failure) => context.showSnack(failure.message, isError: true),
        (_) => ref.invalidate(universityDetailProvider(universiteId)),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formation.intitule, style: context.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${formation.niveau.label} · ${formation.dureeAnnees ?? '?'} an(s) · ${formation.domaine}',
                  style: context.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          if (formation.moyenneMinimale != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.amberSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '≥ ${formation.moyenneMinimale}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 4),
          ],
          FavoriteButton(
            isFavorite: formation.estFavori,
            onTap: toggleFavorite,
            background: AppColors.background,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.lines,
    this.source,
    this.dateMaj,
  });

  final String title;
  final List<String> lines;
  final String? source;
  final DateTime? dateMaj;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.textTheme.titleMedium),
          for (final line in lines) ...[
            const SizedBox(height: 4),
            Text(line, style: context.textTheme.bodyMedium),
          ],
          if (source != null && dateMaj != null) ...[
            const SizedBox(height: 8),
            SourceBadge(source: source!, updatedAt: dateMaj!),
          ],
        ],
      ),
    );
  }
}
