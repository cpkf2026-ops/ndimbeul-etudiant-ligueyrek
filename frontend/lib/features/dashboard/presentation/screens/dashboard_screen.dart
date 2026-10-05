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
import '../../../../shared/widgets/app_logo_button.dart';
import '../../../../shared/widgets/brand_illustration.dart';
import '../../../../shared/widgets/content_max_width.dart';
import '../../../../shared/widgets/entity_card.dart';
import '../../../../shared/widgets/responsive_grid.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../../shared/widgets/search_bar_custom.dart';
import '../../../../shared/widgets/section_reveal.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../news/presentation/providers/news_provider.dart';
import '../widgets/dashboard_mock_data.dart';
import '../widgets/dashboard_sections.dart';

/// Accueil — bannière hero avec recherche, chiffres clés, accès rapides,
/// actualités, calendrier académique & filières porteuses, assistant IA,
/// universités d'excellence, parcours en 4 étapes, logements, témoignages,
/// entreprises partenaires et appel à l'action final. Réorganisé par
/// breakpoint (listes horizontales → grilles, colonnes côte à côte) plutôt
/// que simplement redimensionné.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final isGuest = user == null;
    // Lycéens : pas concernés par Emploi & Stages (voir UserRole.voitEmplois).
    final voitEmplois = user?.role?.voitEmplois ?? true;
    // Orientation : lycéens uniquement (visiteurs : visible, la connexion est demandée).
    final voitOrientation = user?.role?.voitOrientation ?? true;
    final horizontal = context.pageHorizontalPadding;
    // Les 3 dernières actualités réelles (veille IA), sinon l'aperçu de démo.
    final actusReelles = ref.watch(newsListProvider).valueOrNull?.items;
    final actualites = (actusReelles == null || actusReelles.isEmpty)
        ? kMockActualites
        : [
            for (final a in actusReelles.take(3))
              DashboardActuality(
                title: a.titre,
                category: a.categorie.label,
                imageUrl: a.imageUrl ?? '',
              ),
          ];

    const sectionGap = SizedBox(height: 40);
    const titleGap = SizedBox(height: 16);

    Widget reveal(Widget child, [int delayMs = 0]) => SectionReveal(
      delay: Duration(milliseconds: delayMs),
      child: child,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ContentMaxWidth(
          maxWidth: 1200,
          child: CustomScrollView(
            slivers: [
              SliverList.list(
                children: [
                  reveal(_TopBar(prenom: user?.prenom, isGuest: isGuest)),
                  reveal(
                    _HeroSearchBanner(voitOrientation: voitOrientation),
                    60,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Encart visiteur / statistiques personnelles
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontal),
                    child: reveal(
                      isGuest
                          ? const _GuestSignupCard()
                          : _PersonalStats(voitEmplois: voitEmplois),
                      100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  reveal(const KeyFiguresStrip(), 140),
                  sectionGap,

                  // Accès rapides
                  reveal(
                    const DashboardSectionTitle(
                      eyebrow: 'Explorer',
                      title: 'Accès rapide',
                      subtitle:
                          'Tous les outils pour construire votre parcours',
                    ),
                    160,
                  ),
                  const SizedBox(height: 20),
                  reveal(
                    QuickActionsGrid(
                      voitEmplois: voitEmplois,
                      voitOrientation: voitOrientation,
                    ),
                    180,
                  ),
                  sectionGap,

                  // Actualités
                  reveal(
                    DashboardSectionTitle(
                      eyebrow: 'À la une',
                      title: 'Actualités Nationales',
                      subtitle:
                          'Inscriptions, bourses et événements au Sénégal',
                      onSeeAll: () => context.go(RoutePaths.news),
                    ),
                  ),
                  titleGap,
                  reveal(
                    ResponsiveLayout(
                      mobile: _HorizontalActualites(items: actualites),
                      tablet: _HorizontalActualites(items: actualites),
                      desktop: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontal),
                        child: ResponsiveGrid(
                          desktopColumns: actualites.length.clamp(1, 3),
                          spacing: 16,
                          children: [
                            for (final item in actualites)
                              EntityCard(
                                imageUrl: item.imageUrl,
                                title: item.title,
                                subtitle: item.category,
                                badge: item.category,
                                width: double.infinity,
                                height: 210,
                                onTap: () => context.go(RoutePaths.news),
                              ),
                          ],
                        ),
                      ),
                    ),
                    40,
                  ),
                  sectionGap,

                  // Calendrier + filières porteuses
                  reveal(
                    const DashboardSectionTitle(
                      eyebrow: 'Agenda & tendances',
                      title: 'Préparez la rentrée',
                      subtitle:
                          'Échéances clés et filières qui offrent le plus de débouchés',
                    ),
                  ),
                  titleGap,
                  reveal(
                    KeyDatesAndTrends(voitOrientation: voitOrientation),
                    40,
                  ),
                  sectionGap,

                  // Assistant IA
                  reveal(const AiAssistantPanel()),
                  sectionGap,

                  // Universités d'excellence
                  reveal(
                    DashboardSectionTitle(
                      eyebrow: 'Établissements',
                      title: "Universités d'Excellence",
                      subtitle: 'Les établissements les plus demandés du pays',
                      onSeeAll: () => context.go(RoutePaths.universities),
                    ),
                  ),
                  titleGap,
                  reveal(
                    ResponsiveLayout(
                      mobile: _HorizontalUniversities(items: kMockUniversities),
                      tablet: _HorizontalUniversities(items: kMockUniversities),
                      desktop: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontal),
                        child: ResponsiveGrid(
                          desktopColumns: kMockUniversities.length.clamp(1, 3),
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            for (final item in kMockUniversities)
                              EntityCard(
                                imageUrl: item.imageUrl,
                                title: item.nom,
                                subtitle: item.sousTitre,
                                trailingText: '${item.nbFormations} formations',
                                width: double.infinity,
                                height: 210,
                                onTap: () => context.push(
                                  RoutePaths.universityDetailPath(item.id),
                                ),
                              ),
                            const _CompareUniversitiesTile(),
                          ],
                        ),
                      ),
                    ),
                    40,
                  ),
                  sectionGap,

                  // Parcours
                  reveal(
                    const DashboardSectionTitle(
                      eyebrow: 'Comment ça marche',
                      title: 'Votre parcours en 4 étapes',
                      subtitle:
                          'Du bac à votre premier emploi, on vous accompagne',
                    ),
                  ),
                  titleGap,
                  reveal(const JourneySteps(), 40),
                  sectionGap,

                  // Logements
                  reveal(
                    DashboardSectionTitle(
                      eyebrow: 'Vie étudiante',
                      title: 'Logements à proximité',
                      subtitle: 'Chambres et studios près des campus',
                      onSeeAll: () => context.go(RoutePaths.chat),
                    ),
                  ),
                  titleGap,
                  reveal(const HousingSection(), 40),
                  sectionGap,

                  // Témoignages
                  reveal(
                    const DashboardSectionTitle(
                      eyebrow: 'Ils nous font confiance',
                      title: 'Ce que disent les étudiants',
                    ),
                  ),
                  titleGap,
                  reveal(const TestimonialsSection(), 40),

                  // Entreprises partenaires (non concerné pour les lycéens)
                  if (voitEmplois) ...[
                    sectionGap,
                    reveal(
                      DashboardSectionTitle(
                        eyebrow: 'Carrière',
                        title: 'Entreprises Partenaires',
                        subtitle: 'Elles recrutent nos étudiants et diplômés',
                        onSeeAll: () => context.go(RoutePaths.jobs),
                      ),
                    ),
                    titleGap,
                    reveal(const PartnersShowcase(), 40),
                  ],
                  sectionGap,
                  reveal(
                    FinalCallToAction(
                      isGuest: isGuest,
                      voitOrientation: voitOrientation,
                    ),
                  ),
                  const SizedBox(height: 110),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonalStats extends StatelessWidget {
  const _PersonalStats({required this.voitEmplois});
  final bool voitEmplois;

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: voitEmplois
              ? StatCard(
                  value: '5',
                  label: 'Offres suivies',
                  icon: Icons.bookmark_rounded,
                  tone: StatCardTone.amber,
                  onTap: () => context.push(RoutePaths.jobsFavorites),
                )
              : StatCard(
                  value: '3',
                  label: 'Filières conseillées',
                  icon: Icons.explore_rounded,
                  tone: StatCardTone.amber,
                  onTap: () =>
                      context.push(RoutePaths.orientationRecommendations),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: '4',
            label: 'Universités favoris',
            icon: Icons.school_rounded,
            tone: StatCardTone.blue,
            onTap: () => context.go(RoutePaths.universities),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.prenom, required this.isGuest});
  final String? prenom;

  /// Visiteur non connecté : accueil générique + bouton "Se connecter".
  final bool isGuest;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.pageHorizontalPadding,
        12,
        context.pageHorizontalPadding,
        14,
      ),
      child: Row(
        children: [
          const AppLogoButton(size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGuest
                      ? 'Bienvenue sur Ndimbeul 👋'
                      : '$_greeting, ${prenom ?? 'Étudiant'} 👋',
                  style: context.textTheme.titleLarge?.copyWith(fontSize: 17),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 12,
                      color: AppColors.accentDark,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        'Ndimbeul-Etudiant — Sénégal Études',
                        style: context.textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isGuest) ...[
            if (!context.isMobile) ...[
              TextButton(
                onPressed: () => context.push(RoutePaths.register),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                child: const Text(
                  "S'inscrire",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 6),
            ],
            FilledButton.icon(
              onPressed: () => context.push(RoutePaths.login),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              icon: const Icon(Icons.login_rounded, size: 17),
              label: const Text('Se connecter'),
            ),
          ] else
            Material(
              color: AppColors.surface,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.border),
              ),
              child: IconButton(
                onPressed: () => context.go(RoutePaths.news),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bannière hero de l'accueil — empilée (illustration en fond, texte +
/// recherche superposés) sur mobile/tablette, réorganisée en panneaux côte
/// à côte (texte + boutons à gauche, illustration à droite, recherche
/// pleine largeur en dessous) sur desktop/web.
class _HeroSearchBanner extends StatelessWidget {
  const _HeroSearchBanner({required this.voitOrientation});
  final bool voitOrientation;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const _HeroStacked(height: 210),
      tablet: const _HeroStacked(height: 240),
      desktop: _HeroWide(voitOrientation: voitOrientation),
    );
  }
}

/// Fond de la bannière : photo de marque + voile dégradé.
class _HeroBackground extends StatelessWidget {
  const _HeroBackground({required this.alignment});
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppImages.dashboardHero,
          fit: BoxFit.cover,
          alignment: alignment,
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
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.85),
                AppColors.primary.withValues(alpha: 0.35),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 13, color: AppColors.accent),
          SizedBox(width: 6),
          Text(
            "Plateforme d'orientation n°1 au Sénégal",
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
                borderRadius: BorderRadius.circular(26),
                child: SizedBox(
                  height: height,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const _HeroBackground(alignment: Alignment(0.2, -0.4)),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Opacity(
                          opacity: 0.9,
                          child: BrandIllustration(
                            variant: BrandIllustrationVariant.hero,
                            size: height * 0.5,
                            animated: false,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 42),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const _HeroBadge(),
                            const SizedBox(height: 10),
                            AppTypography.heroTitle(
                              straight: 'Trouvez votre voie,',
                              accent: 'ensemble.',
                              fontSize: height > 220 ? 26 : 22,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Découvrez des universités, des bourses ou des formations à travers le Sénégal',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12.5,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: -24,
                child: SearchBarCustom(
                  hint: 'Université, région ou filière...',
                  onSubmitted: (_) => context.go(RoutePaths.universities),
                  onFilterTap: () => context.go(RoutePaths.universities),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const _PopularUniversitiesRow(),
        ],
      ),
    );
  }
}

class _HeroWide extends StatelessWidget {
  const _HeroWide({required this.voitOrientation});

  /// Bouton principal : orientation (lycéens, visiteurs) ou offres (étudiants, diplômés).
  final bool voitOrientation;

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
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                  height: 360,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const _HeroBackground(alignment: Alignment(0.3, -0.3)),
                      Positioned(
                        top: 30,
                        right: 48,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.35),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: const BrandIllustration(
                            variant: BrandIllustrationVariant.hero,
                            size: 180,
                            animated: false,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(44, 40, 44, 56),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const _HeroBadge(),
                            const SizedBox(height: 16),
                            AppTypography.heroTitle(
                              straight: 'Trouvez votre voie,',
                              accent: 'ensemble.',
                              fontSize: 40,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: 480,
                              child: Text(
                                'Découvrez des universités, des bourses ou des formations à travers le Sénégal — accompagné par une IA qui vous connaît.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 15.5,
                                  height: 1.55,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                FilledButton.icon(
                                  onPressed: () => context.go(
                                    voitOrientation
                                        ? RoutePaths.orientation
                                        : RoutePaths.jobs,
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    foregroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  icon: Icon(
                                    voitOrientation
                                        ? Icons.explore_rounded
                                        : Icons.work_rounded,
                                    size: 19,
                                  ),
                                  label: Text(
                                    voitOrientation
                                        ? 'Commencer mon orientation'
                                        : 'Voir les offres',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      context.go(RoutePaths.universities),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.school_rounded,
                                    size: 19,
                                  ),
                                  label: const Text('Explorer les universités'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 44,
                bottom: -28,
                child: SizedBox(
                  width: 560,
                  child: SearchBarCustom(
                    hint: 'Université, région ou filière...',
                    onSubmitted: (_) => context.go(RoutePaths.universities),
                    onFilterTap: () => context.go(RoutePaths.universities),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 46),
          const _PopularUniversitiesRow(),
        ],
      ),
    );
  }
}

/// "Universités populaires" — pastilles cliquables sous la barre de
/// recherche du hero.
class _PopularUniversitiesRow extends StatelessWidget {
  const _PopularUniversitiesRow();

  @override
  Widget build(BuildContext context) {
    final items = kMockUniversities.take(5).toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 16,
            color: AppColors.accentDark,
          ),
          const SizedBox(width: 4),
          Text(
            'Populaires',
            style: context.textTheme.labelLarge?.copyWith(fontSize: 12.5),
          ),
          const SizedBox(width: 12),
          for (final u in items)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _UniversityVignette(university: u),
            ),
        ],
      ),
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
    return Material(
      color: AppColors.surface,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () =>
            context.push(RoutePaths.universityDetailPath(university.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 14, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: university.imageUrl.startsWith('assets/')
                      ? Image.asset(
                          university.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              _UniversityVignetteFallback(
                                university: university,
                              ),
                        )
                      : Image.network(
                          university.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              _UniversityVignetteFallback(
                                university: university,
                              ),
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                university.nom,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
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
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: context.pageHorizontalPadding,
        ),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return EntityCard(
            imageUrl: item.imageUrl,
            title: item.title,
            subtitle: item.category,
            badge: item.category,
            width: 240,
            onTap: () => context.go(RoutePaths.news),
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
        padding: EdgeInsets.symmetric(
          horizontal: context.pageHorizontalPadding,
        ),
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

/// Dernière case de la grille d'universités (desktop) — renvoie vers le
/// comparateur pour combler la ligne incomplète.
class _CompareUniversitiesTile extends StatelessWidget {
  const _CompareUniversitiesTile();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.greenSoft,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push(RoutePaths.universitiesCompare),
        child: SizedBox(
          height: 210,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.compare_arrows_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Comparer les établissements',
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Frais, formations, débouchés : choisissez en toute clarté.',
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Text(
                      'Ouvrir le comparateur',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Encart d'inscription affiché aux visiteurs à la place des statistiques
/// personnelles (conversations, offres suivies, favoris).
class _GuestSignupCard extends StatelessWidget {
  const _GuestSignupCard();

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;

    final icon = Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.accentGradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.rocket_launch_rounded,
        color: AppColors.primary,
        size: 24,
      ),
    );

    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Débloquez toute l'application",
          style: context.textTheme.titleLarge,
        ),
        const SizedBox(height: 3),
        Text(
          'Créez un compte gratuit pour explorer universités, offres, '
          "actualités et l'assistant IA.",
          style: context.textTheme.bodyMedium,
        ),
      ],
    );

    final button = FilledButton.icon(
      onPressed: () => context.push(RoutePaths.register),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
      label: const Text("S'inscrire gratuitement"),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF6DC), AppColors.amberSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    icon,
                    const SizedBox(width: 14),
                    Expanded(child: texts),
                  ],
                ),
                const SizedBox(height: 14),
                button,
              ],
            )
          : Row(
              children: [
                icon,
                const SizedBox(width: 16),
                Expanded(child: texts),
                const SizedBox(width: 12),
                button,
              ],
            ),
    );
  }
}
