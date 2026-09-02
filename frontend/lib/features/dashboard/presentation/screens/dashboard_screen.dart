import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/constants/app_images.dart';
import '../../../../shared/widgets/ai_banner.dart';
import '../../../../shared/widgets/app_logo_button.dart';
import '../../../../shared/widgets/brand_illustration.dart';
import '../../../../shared/widgets/content_max_width.dart';
import '../../../../shared/widgets/entity_card.dart';
import '../../../../shared/widgets/responsive_grid.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/search_bar_custom.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/section_reveal.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../widgets/dashboard_mock_data.dart';

/// Accueil — écran principal fidèle à la maquette : bannière hero avec
/// recherche en overlay, actualités, universités d'excellence, bannière
/// IA, stats tricolores, logements et entreprises partenaires. Réorganisé
/// par breakpoint (hero empilé → panneau côte à côte, listes horizontales
/// → grilles) plutôt que simplement redimensionné.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ContentMaxWidth(
          maxWidth: 1200,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SectionReveal(
                  child: _TopBar(prenom: user?.prenom ?? 'Étudiant'),
                ),
              ),
              const SliverToBoxAdapter(
                child: SectionReveal(delay: Duration(milliseconds: 60), child: _HeroSearchBanner()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
              SliverToBoxAdapter(
                child: SectionReveal(
                  delay: const Duration(milliseconds: 120),
                  child: SectionHeader(
                    title: 'Actualités Nationales',
                    onSeeAll: () => context.push(RoutePaths.news),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: SectionReveal(
                  delay: const Duration(milliseconds: 160),
                  child: ResponsiveLayout(
                    mobile: _HorizontalActualites(items: kMockActualites),
                    tablet: _HorizontalActualites(items: kMockActualites),
                    desktop: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ResponsiveGrid(
                        desktopColumns: kMockActualites.length.clamp(1, 3),
                        children: [
                          for (final item in kMockActualites)
                            EntityCard(
                              imageUrl: item.imageUrl,
                              title: item.title,
                              subtitle: item.category,
                              badge: item.category,
                              width: double.infinity,
                              height: 190,
                              onTap: () => context.push(RoutePaths.news),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionReveal(
                    delay: const Duration(milliseconds: 200),
                    child: AiBanner(
                      straightTitle: 'Posez votre question',
                      accentTitle: 'maintenant',
                      subtitle:
                          'L\'assistant IA Ndimbeul-Etudiant répond à vos questions sur les universités, bourses, logements et formations — en français, à tout moment.',
                      onOpenChat: () => context.push(RoutePaths.chat),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              SliverToBoxAdapter(
                child: SectionReveal(
                  delay: const Duration(milliseconds: 240),
                  child: SectionHeader(
                    title: 'Universités d\'Excellence',
                    onSeeAll: () => context.push(RoutePaths.universities),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: SectionReveal(
                  delay: const Duration(milliseconds: 280),
                  child: ResponsiveLayout(
                    mobile: _HorizontalUniversities(items: kMockUniversities),
                    tablet: _HorizontalUniversities(items: kMockUniversities),
                    desktop: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ResponsiveGrid(
                        desktopColumns: kMockUniversities.length.clamp(1, 3),
                        children: [
                          for (final item in kMockUniversities)
                            EntityCard(
                              imageUrl: item.imageUrl,
                              title: item.nom,
                              subtitle: item.sousTitre,
                              trailingText: '${item.nbFormations} formations',
                              width: double.infinity,
                              height: 190,
                              onTap: () => context
                                  .push(RoutePaths.universityDetailPath(item.id)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionReveal(
                    delay: const Duration(milliseconds: 320),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            value: '12',
                            label: 'Conversations IA',
                            icon: Icons.forum_rounded,
                            tone: StatCardTone.green,
                            onTap: () => context.push(RoutePaths.chatHistory),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            value: '5',
                            label: 'Offres suivies',
                            icon: Icons.bookmark_rounded,
                            tone: StatCardTone.amber,
                            onTap: () => context.push(RoutePaths.jobsFavorites),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            value: '4',
                            label: 'Universités favoris',
                            icon: Icons.school_rounded,
                            tone: StatCardTone.blue,
                            onTap: () => context.push(RoutePaths.universities),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              SliverToBoxAdapter(
                child: SectionReveal(
                  delay: const Duration(milliseconds: 360),
                  child: SectionHeader(
                    title: 'Logements à proximité',
                    onSeeAll: () => context.push(RoutePaths.ecosysteme),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: SectionReveal(
                  delay: const Duration(milliseconds: 400),
                  child: ResponsiveLayout(
                    mobile: _HorizontalHousing(items: kMockHousing),
                    tablet: _HorizontalHousing(items: kMockHousing),
                    desktop: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ResponsiveGrid(
                        desktopColumns: kMockHousing.length.clamp(1, 3),
                        children: [
                          for (final item in kMockHousing)
                            EntityCard(
                              imageUrl: item.imageUrl,
                              title: item.title,
                              subtitle: item.distance,
                              trailingText: item.prix,
                              width: double.infinity,
                              height: 190,
                              onTap: () => context.push(RoutePaths.ecosysteme),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              SliverToBoxAdapter(
                child: SectionReveal(
                  delay: const Duration(milliseconds: 440),
                  child: SectionHeader(
                    title: 'Entreprises Partenaires',
                    onSeeAll: () => context.push(RoutePaths.jobs),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: SectionReveal(
                  delay: const Duration(milliseconds: 480),
                  child: const _PartnerCompaniesRow(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.prenom});
  final String prenom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.pageHorizontalPadding, 8, context.pageHorizontalPadding, 4),
      child: Row(
        children: [
          const AppLogoButton(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, $prenom 👋',
                  style: context.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Ndimbeul-Etudiant — Sénégal Études',
                  style: context.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push(RoutePaths.news),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bannière hero de l'accueil — empilée (illustration en fond, texte +
/// recherche superposés) sur mobile/tablette, réorganisée en panneaux côte
/// à côte (texte à gauche, illustration à droite, recherche pleine largeur
/// en dessous) sur desktop/web : une vraie réorganisation, pas un simple
/// redimensionnement.
class _HeroSearchBanner extends StatelessWidget {
  const _HeroSearchBanner();

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _HeroStacked(height: 190),
      tablet: const _HeroStacked(height: 220),
      desktop: const _HeroWide(),
    );
  }
}

class _HeroStacked extends StatelessWidget {
  const _HeroStacked({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: height,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        AppImages.campusAerial,
                        fit: BoxFit.cover,
                        alignment: const Alignment(0.2, -0.4),
                        errorBuilder: (context, error, stack) => const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.primaryGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.92),
                              AppColors.primary.withValues(alpha: 0.55),
                            ],
                            stops: const [0.45, 1],
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppTypography.heroTitle(
                              straight: 'Trouvez votre voie,',
                              accent: 'ensemble.',
                              fontSize: height > 200 ? 24 : 19,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Découvrez des universités, des bourses ou des formations à travers le Sénégal',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.35),
                          ),
                          child: BrandIllustration(
                            variant: BrandIllustrationVariant.hero,
                            size: height * 0.58,
                            animated: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: -22,
                child: SearchBarCustom(
                  hint: 'Université, région ou filière...',
                  onSubmitted: (_) => context.push(RoutePaths.universities),
                  onFilterTap: () => context.push(RoutePaths.universities),
                ),
              ),
            ],
          ),
          const SizedBox(height: 56),
          const _PopularUniversitiesRow(),
        ],
      ),
    );
  }
}

/// "Universités populaires" — bandeau de vignettes cliquables sous la barre
/// de recherche du hero (alternative "plus lisible" à un skyline flou en
/// bande basse).
class _PopularUniversitiesRow extends StatelessWidget {
  const _PopularUniversitiesRow();

  @override
  Widget build(BuildContext context) {
    final items = kMockUniversities.take(5).toList();
    return Row(
      children: [
        for (final u in items)
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _UniversityVignette(university: u),
          ),
      ],
    );
  }
}

class _UniversityVignetteFallback extends StatelessWidget {
  const _UniversityVignetteFallback({required this.university});
  final DashboardUniversity university;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.greenSoft,
      alignment: Alignment.center,
      child: Text(
        university.nom.characters.first,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _UniversityVignette extends StatelessWidget {
  const _UniversityVignette({required this.university});
  final DashboardUniversity university;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () => context.push(RoutePaths.universityDetailPath(university.id)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: SizedBox(
              width: 48,
              height: 48,
              child: university.imageUrl.startsWith('assets/')
                  ? Image.asset(
                      university.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          _UniversityVignetteFallback(university: university),
                    )
                  : Image.network(
                      university.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          _UniversityVignetteFallback(university: university),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 56,
            child: Text(
              university.nom,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroWide extends StatelessWidget {
  const _HeroWide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Image.network(
                  AppImages.campusAerial,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.3, -0.3),
                  errorBuilder: (context, error, stack) => Container(
                    height: 300,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.92),
                        AppColors.primary.withValues(alpha: 0.35),
                      ],
                      stops: const [0.5, 1],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppTypography.heroTitle(
                        straight: 'Trouvez votre voie,',
                        accent: 'ensemble.',
                        fontSize: 34,
                      ),
                      SizedBox(
                        width: 460,
                        child: Text(
                          'Découvrez des universités, des bourses ou des formations à travers le Sénégal — accompagné par une IA qui vous connaît.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 24,
                  right: 40,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                    child: const BrandIllustration(
                      variant: BrandIllustrationVariant.hero,
                      size: 170,
                      animated: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 520,
            child: SearchBarCustom(
              hint: 'Université, région ou filière...',
              onSubmitted: (_) => context.push(RoutePaths.universities),
              onFilterTap: () => context.push(RoutePaths.universities),
            ),
          ),
          const SizedBox(height: 24),
          const _PopularUniversitiesRow(),
        ],
      ),
    );
  }
}

class _HorizontalActualites extends StatelessWidget {
  const _HorizontalActualites({required this.items});
  final List<DashboardActuality> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return EntityCard(
            imageUrl: item.imageUrl,
            title: item.title,
            subtitle: item.category,
            width: 220,
            height: 190,
            badge: item.category,
            onTap: () => context.push(RoutePaths.news),
          );
        },
      ),
    );
  }
}

class _HorizontalUniversities extends StatelessWidget {
  const _HorizontalUniversities({required this.items});
  final List<DashboardUniversity> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return EntityCard(
            imageUrl: item.imageUrl,
            title: item.nom,
            subtitle: item.sousTitre,
            trailingText: '${item.nbFormations} formations',
            onTap: () => context.push(RoutePaths.universityDetailPath(item.id)),
          );
        },
      ),
    );
  }
}

class _HorizontalHousing extends StatelessWidget {
  const _HorizontalHousing({required this.items});
  final List<DashboardHousing> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return EntityCard(
            imageUrl: item.imageUrl,
            title: item.title,
            subtitle: item.distance,
            trailingText: item.prix,
            width: 200,
            height: 190,
            onTap: () => context.push(RoutePaths.ecosysteme),
          );
        },
      ),
    );
  }
}

class _PartnerCompaniesRow extends StatelessWidget {
  const _PartnerCompaniesRow();

  static const _companies = [
    ('SONATEL', Icons.wifi_tethering_rounded),
    ('SenElec', Icons.bolt_rounded),
    ('Orange Sn', Icons.phone_iphone_rounded),
    ('SGBS', Icons.account_balance_rounded),
    ('Auchan', Icons.storefront_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (name, icon) in _companies) _PartnerChip(name: name, icon: icon),
          ],
        ),
      );
    }

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
        itemCount: _companies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final (name, icon) = _companies[i];
          return _PartnerChip(name: name, icon: icon);
        },
      ),
    );
  }
}

class _PartnerChip extends StatelessWidget {
  const _PartnerChip({required this.name, required this.icon});
  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(RoutePaths.jobs),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 6),
            Text(
              name,
              style: context.textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
