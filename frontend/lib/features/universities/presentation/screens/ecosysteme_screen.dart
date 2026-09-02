import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../features/news/presentation/providers/news_provider.dart';
import '../../../../shared/constants/app_images.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_logo_button.dart';
import '../../../../shared/widgets/entity_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/entities/logement.dart';
import '../providers/university_provider.dart';

/// Écosystème étudiant — logements référencés par les universités et
/// entreprises partenaires, accessible depuis l'onglet 3 de la navigation
/// principale (voir maquette Accueil/Orientation/Écosystème).
class EcosystemeScreen extends ConsumerWidget {
  const EcosystemeScreen({super.key});

  static const _featuredUniversityIds = ['univ_ucad', 'univ_ugb', 'univ_isep_dmn'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final universites = _featuredUniversityIds
        .map((id) => ref.watch(universityDetailProvider(id)))
        .toList();
    final newsAsync = ref.watch(newsListProvider);
    final isLoading = universites.any((u) => u.isLoading);
    final logements = universites
        .where((u) => u.hasValue)
        .expand((u) => u.value!.logements.map((l) => (l, u.value!.nom)))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: AppLogoButton(size: 32),
        ),
        title: const Text('Écosystème étudiant'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          const SizedBox(height: 12),
          SectionHeader(
            title: 'Logements référencés',
            onSeeAll: () => context.push(RoutePaths.universities),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SkeletonCard(height: 190),
            )
          else if (logements.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Aucun logement référencé pour le moment.'),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: logements.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final (logement, universiteNom) = logements[i];
                  return EntityCard(
                    imageUrl: _logementImage(logement.type),
                    title: logement.nom,
                    subtitle: universiteNom,
                    trailingText: logement.tarifMensuel != null
                        ? '${logement.tarifMensuel!.toStringAsFixed(0)} ${logement.devise}'
                        : null,
                    width: 190,
                    height: 200,
                    badge: logement.type.label,
                  );
                },
              ),
            ),
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Actualités',
            onSeeAll: () => context.push(RoutePaths.news),
          ),
          const SizedBox(height: 12),
          newsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SkeletonCard(height: 170),
            ),
            error: (error, _) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Actualités indisponibles pour le moment.'),
            ),
            data: (page) => page.items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Aucune actualité pour le moment.'),
                  )
                : SizedBox(
                    height: 170,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: page.items.take(6).length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final actualite = page.items[i];
                        return EntityCard(
                          imageUrl: actualite.imageUrl ?? AppImages.etudiantsGroupe,
                          title: actualite.titre,
                          subtitle: actualite.categorie.label,
                          width: 200,
                          height: 170,
                          onTap: () => context.push(RoutePaths.news),
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Entreprises partenaires',
            onSeeAll: () => context.push(RoutePaths.jobs),
          ),
          const SizedBox(height: 12),
          const _PartnerCompaniesGrid(),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.amberSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.work_outline_rounded, color: AppColors.accentDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Découvrez les offres d\'emploi, stages et bourses du moment',
                      style: context.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(RoutePaths.jobs),
                    child: const Text('Voir'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _logementImage(TypeLogement type) {
    switch (type) {
      case TypeLogement.residence:
        return 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=600&q=65';
      case TypeLogement.foyer:
        return 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=600&q=65';
      case TypeLogement.partenaire:
        return 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=600&q=65';
    }
  }
}

class _PartnerCompaniesGrid extends StatelessWidget {
  const _PartnerCompaniesGrid();

  static const _companies = [
    ('Sonatel', Icons.wifi_tethering_rounded),
    ('Orange Sénégal', Icons.phone_iphone_rounded),
    ('SGBS', Icons.account_balance_rounded),
    ('Wave', Icons.account_balance_wallet_rounded),
    ('Auchan Sénégal', Icons.storefront_rounded),
    ('SenElec', Icons.bolt_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.4,
        ),
        itemCount: _companies.length,
        itemBuilder: (context, i) {
          final (name, icon) = _companies[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: context.textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
