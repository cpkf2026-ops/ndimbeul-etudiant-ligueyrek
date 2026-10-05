import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import 'dashboard_mock_data.dart';

/// Sections enrichies de l'Accueil (chiffres clés, accès rapides, calendrier,
/// filières porteuses, parcours, logements, témoignages, partenaires, appel
/// à l'action final). Toutes partagent la même grammaire visuelle : titre
/// avec sur-titre doré, cartes blanches arrondies à ombre douce.

const _kTeal = Color(0xFF0E7C7B);

/// Onglets du shell : on y bascule (`go`) au lieu d'empiler (`push`) une
/// deuxième copie de l'application.
const _kShellRoots = {
  RoutePaths.dashboard,
  RoutePaths.orientation,
  RoutePaths.profile,
  RoutePaths.universities,
  RoutePaths.jobs,
  RoutePaths.news,
  RoutePaths.chat,
};
const _kViolet = Color(0xFF7A5AF8);
const _kCoral = Color(0xFFE5604D);

BoxDecoration _softCard({
  double radius = 22,
  Color color = AppColors.surface,
}) => BoxDecoration(
  color: color,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
  boxShadow: [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.05),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ],
);

// -----------------------------------------------------------------------------
// Titre de section
// -----------------------------------------------------------------------------

class DashboardSectionTitle extends StatelessWidget {
  const DashboardSectionTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.onSeeAll,
    this.padded = true,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    eyebrow.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.accentDark,
                      fontSize: 10.5,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: context.textTheme.headlineLarge?.copyWith(fontSize: 20),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: context.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.greenSoft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Voir tout',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 15),
              ],
            ),
          ),
      ],
    );

    if (!padded) return content;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
      child: content,
    );
  }
}

// -----------------------------------------------------------------------------
// Chiffres clés (compteurs animés)
// -----------------------------------------------------------------------------

class KeyFiguresStrip extends StatelessWidget {
  const KeyFiguresStrip({super.key});

  static const _icons = [
    Icons.account_balance_rounded,
    Icons.menu_book_rounded,
    Icons.map_rounded,
    Icons.auto_awesome_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern('fr_FR');
    final mobile = context.isMobile;

    final tiles = [
      for (var i = 0; i < kKeyFigures.length; i++)
        _KeyFigureTile(
          figure: kKeyFigures[i],
          icon: _icons[i % _icons.length],
          format: numberFormat,
        ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 18,
          horizontal: mobile ? 8 : 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF175A42)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: mobile
            ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: tiles[0]),
                      Expanded(child: tiles[1]),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(child: tiles[2]),
                      Expanded(child: tiles[3]),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0)
                      Container(
                        width: 1,
                        height: 44,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    Expanded(child: tiles[i]),
                  ],
                ],
              ),
      ),
    );
  }
}

class _KeyFigureTile extends StatelessWidget {
  const _KeyFigureTile({
    required this.figure,
    required this.icon,
    required this.format,
  });
  final DashboardKeyFigure figure;
  final IconData icon;
  final NumberFormat format;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accent, size: 19),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: figure.value.toDouble()),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Text(
                  '${format.format(v.round())}${figure.suffix}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
              Text(
                figure.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Accès rapides
// -----------------------------------------------------------------------------

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({
    super.key,
    required this.voitEmplois,
    required this.voitOrientation,
  });
  final bool voitEmplois;

  /// Orientation et simulation du bac : réservées aux lycéens (UserRole.voitOrientation).
  final bool voitOrientation;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      const _QuickAction(
        'Universités',
        Icons.school_rounded,
        AppColors.primary,
        RoutePaths.universities,
      ),
      if (voitOrientation) ...[
        const _QuickAction(
          'Orientation',
          Icons.explore_rounded,
          _kTeal,
          RoutePaths.orientation,
        ),
        const _QuickAction(
          'Simulation bac',
          Icons.calculate_rounded,
          _kViolet,
          RoutePaths.orientationSimulation,
        ),
      ],
      const _QuickAction(
        'Comparateur',
        Icons.compare_arrows_rounded,
        AppColors.info,
        RoutePaths.universitiesCompare,
      ),
      if (voitEmplois)
        const _QuickAction(
          'Emplois & stages',
          Icons.work_rounded,
          AppColors.accentDark,
          RoutePaths.jobs,
        ),
      const _QuickAction(
        'Bourses',
        Icons.savings_rounded,
        _kCoral,
        RoutePaths.news,
      ),
      const _QuickAction(
        'Actualités',
        Icons.newspaper_rounded,
        Color(0xFF2E9E5B),
        RoutePaths.news,
      ),
      const _QuickAction(
        'Assistant IA',
        Icons.smart_toy_rounded,
        Color(0xFF16241D),
        RoutePaths.chat,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 820 ? actions.length : 4;
          const spacing = 10.0;
          final width =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: 14,
            children: [
              for (final a in actions)
                SizedBox(
                  width: width,
                  child: _QuickActionTile(action: a),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction(this.label, this.icon, this.color, this.route);
  final String label;
  final IconData icon;
  final Color color;
  final String route;
}

class _QuickActionTile extends StatefulWidget {
  const _QuickActionTile({required this.action});
  final _QuickAction action;

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _kShellRoots.contains(a.route)
            ? context.go(a.route)
            : context.push(a.route),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 58,
              height: 58,
              transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [a.color, Color.lerp(a.color, Colors.black, 0.25)!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: a.color.withValues(alpha: _hover ? 0.45 : 0.25),
                    blurRadius: _hover ? 18 : 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(a.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              a.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Calendrier + filières porteuses (côte à côte sur desktop)
// -----------------------------------------------------------------------------

class KeyDatesAndTrends extends StatelessWidget {
  const KeyDatesAndTrends({super.key, required this.voitOrientation});
  final bool voitOrientation;

  @override
  Widget build(BuildContext context) {
    const dates = _KeyDatesCard();
    final trends = _TrendingFieldsCard(voitOrientation: voitOrientation);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
      child: context.isDesktop
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 6, child: dates),
                  const SizedBox(width: 16),
                  Expanded(flex: 5, child: trends),
                ],
              ),
            )
          : Column(children: [dates, const SizedBox(height: 16), trends]),
    );
  }
}

class _KeyDatesCard extends StatelessWidget {
  const _KeyDatesCard();

  Color _kindColor(String kind) => switch (kind) {
    'Inscriptions' => AppColors.primary,
    'Bourses' => _kCoral,
    'Concours' => _kViolet,
    _ => AppColors.info,
  };

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('dd', 'fr_FR');
    final month = DateFormat('MMM', 'fr_FR');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _softCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Icons.event_note_rounded,
            color: AppColors.primary,
            title: 'Calendrier académique',
            subtitle: 'Les échéances à ne pas manquer',
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < kKeyDates.length; i++) ...[
            if (i > 0) const Divider(height: 18, color: AppColors.divider),
            Builder(
              builder: (context) {
                final d = kKeyDates[i];
                final c = _kindColor(d.kind);
                final urgent = d.daysFromNow <= 7;
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.go(RoutePaths.news),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: c.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(
                              day.format(d.date),
                              style: TextStyle(
                                color: c,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              month
                                  .format(d.date)
                                  .toUpperCase()
                                  .replaceAll('.', ''),
                              style: TextStyle(
                                color: c,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.place_outlined,
                                  size: 12,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    d.place,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.labelSmall,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: urgent ? _kCoral : AppColors.background,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'J-${d.daysFromNow}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: urgent
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendingFieldsCard extends StatelessWidget {
  const _TrendingFieldsCard({required this.voitOrientation});

  /// Bouton "Mes filières recommandées" (module Orientation) : lycéens uniquement.
  final bool voitOrientation;

  @override
  Widget build(BuildContext context) {
    final maxGrowth = kTrendingFields
        .map((f) => f.growth)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _softCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Icons.trending_up_rounded,
            color: _kTeal,
            title: 'Filières qui recrutent',
            subtitle: 'Croissance de la demande sur 3 ans',
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < kTrendingFields.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: _TrendBar(
                rank: i + 1,
                field: kTrendingFields[i],
                ratio: kTrendingFields[i].growth / maxGrowth,
              ),
            ),
          const SizedBox(height: 2),
          if (voitOrientation)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.push(RoutePaths.orientationRecommendations),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kTeal,
                  side: BorderSide(color: _kTeal.withValues(alpha: 0.35)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.auto_awesome_rounded, size: 17),
                label: const Text('Mes filières recommandées'),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrendBar extends StatelessWidget {
  const _TrendBar({
    required this.rank,
    required this.field,
    required this.ratio,
  });
  final int rank;
  final DashboardTrendingField field;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '0$rank',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                field.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium?.copyWith(fontSize: 13),
              ),
            ),
            Text(
              '+${field.growth}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Pas de LayoutBuilder ici : la carte est mesurée par IntrinsicHeight
        // sur desktop, qui ne le supporte pas.
        Stack(
          children: [
            Container(
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: Duration(milliseconds: 900 + rank * 120),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => FractionallySizedBox(
                widthFactor: v,
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [_kTeal, Color(0xFF3CC7A6)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          field.debouches,
          style: context.textTheme.labelSmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.textTheme.titleLarge),
              Text(subtitle, style: context.textTheme.labelSmall),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Assistant IA — panneau avec questions suggérées
// -----------------------------------------------------------------------------

class AiAssistantPanel extends StatelessWidget {
  const AiAssistantPanel({super.key});

  static const _suggestions = [
    'Quelles filières avec un bac S2 et 13 de moyenne ?',
    'Comment obtenir une bourse d’excellence ?',
    'Trouver un logement près de l’UCAD',
    'Frais d’inscription à l’UGB ?',
  ];

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: Color(0xFF4ADE80)),
              SizedBox(width: 6),
              Text(
                'Assistant IA en ligne',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppTypography.heroTitle(
          straight: 'Posez votre question',
          accent: 'maintenant',
          fontSize: desktop ? 26 : 22,
        ),
        const SizedBox(height: 8),
        Text(
          "L'assistant IA Ndimbeul-Etudiant répond à vos questions sur les universités, "
          'bourses, logements et formations — en français, à tout moment.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.82),
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => context.go(RoutePaths.chat),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
          icon: const Icon(Icons.chat_bubble_rounded, size: 18),
          label: const Text('Ouvrir le chat IA'),
        ),
      ],
    );

    final suggestions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Questions fréquentes',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        for (final q in _suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.go(RoutePaths.chat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 15,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          q,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.north_east_rounded,
                        size: 15,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF0B2E22), AppColors.primary, Color(0xFF1B5A43)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Icon(
                Icons.smart_toy_rounded,
                size: 220,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(desktop ? 32 : 22),
              child: desktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 5, child: intro),
                        const SizedBox(width: 32),
                        Expanded(flex: 5, child: suggestions),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        intro,
                        const SizedBox(height: 22),
                        suggestions,
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Parcours en 4 étapes
// -----------------------------------------------------------------------------

class JourneySteps extends StatelessWidget {
  const JourneySteps({super.key});

  static const _steps = [
    (
      Icons.person_add_alt_1_rounded,
      'Créez votre profil',
      'Série, notes et centres d’intérêt en 2 minutes.',
    ),
    (
      Icons.calculate_rounded,
      'Simulez votre bac',
      'Découvrez les filières accessibles avec votre moyenne.',
    ),
    (
      Icons.auto_awesome_rounded,
      'Recevez vos recommandations',
      'L’IA vous propose les formations qui vous correspondent.',
    ),
    (
      Icons.rocket_launch_rounded,
      'Postulez & réussissez',
      'Inscriptions, bourses, logement : tout au même endroit.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 820
              ? 4
              : (constraints.maxWidth > 520 ? 2 : 1);
          const spacing = 12.0;
          final width =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (var i = 0; i < _steps.length; i++)
                SizedBox(
                  width: width,
                  child: _StepCard(
                    index: i + 1,
                    icon: _steps[i].$1,
                    title: _steps[i].$2,
                    text: _steps[i].$3,
                    compact: columns == 1,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.icon,
    required this.title,
    required this.text,
    required this.compact,
  });

  final int index;
  final IconData icon;
  final String title;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconBox = Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: AppColors.primary, size: 22),
    );

    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 3),
        Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(fontSize: 12.5),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _softCard(radius: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            top: -4,
            child: Text(
              '0$index',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.primary.withValues(alpha: 0.07),
              ),
            ),
          ),
          compact
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconBox,
                    const SizedBox(width: 14),
                    Expanded(child: texts),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [iconBox, const SizedBox(height: 14), texts],
                ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Logements à proximité
// -----------------------------------------------------------------------------

class HousingSection extends StatelessWidget {
  const HousingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontal = context.pageHorizontalPadding;
    if (context.isDesktop) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontal),
        child: LayoutBuilder(
          builder: (context, c) {
            final width = (c.maxWidth - 12 * 3) / 4;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final h in kMockHousing)
                  SizedBox(
                    width: width,
                    child: _HousingCard(housing: h),
                  ),
              ],
            );
          },
        ),
      );
    }
    return SizedBox(
      height: 236,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontal),
        itemCount: kMockHousing.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) =>
            SizedBox(width: 220, child: _HousingCard(housing: kMockHousing[i])),
      ),
    );
  }
}

class _HousingCard extends StatelessWidget {
  const _HousingCard({required this.housing});
  final DashboardHousing housing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(RoutePaths.chat),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 130,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: housing.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const SkeletonLoader(
                        height: double.infinity,
                        borderRadius: 0,
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.greenSoft,
                        child: const Icon(
                          Icons.home_work_rounded,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${housing.prix} / mois',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      housing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.near_me_rounded,
                          size: 13,
                          color: _kTeal,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            housing.distance,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.labelSmall,
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '4.${(housing.title.length % 5) + 4}',
                          style: context.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
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
    );
  }
}

// -----------------------------------------------------------------------------
// Témoignages
// -----------------------------------------------------------------------------

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontal = context.pageHorizontalPadding;
    if (!context.isMobile) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontal),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < kTestimonials.length; i++) ...[
                if (i > 0) const SizedBox(width: 14),
                Expanded(
                  child: _TestimonialCard(
                    t: kTestimonials[i],
                    highlighted: i == 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontal),
        itemCount: kTestimonials.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => SizedBox(
          width: 290,
          child: _TestimonialCard(t: kTestimonials[i], highlighted: i == 1),
        ),
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.t, required this.highlighted});
  final DashboardTestimonial t;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final fg = highlighted ? Colors.white : AppColors.textPrimary;
    final sub = highlighted
        ? Colors.white.withValues(alpha: 0.7)
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: highlighted
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            )
          : _softCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 30,
                color: highlighted ? AppColors.accent : AppColors.accentDark,
              ),
              const Spacer(),
              for (var i = 0; i < 5; i++)
                const Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: AppColors.accent,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              t.quote,
              style: TextStyle(color: fg, fontSize: 13.5, height: 1.5),
              overflow: TextOverflow.fade,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: highlighted
                    ? AppColors.accent
                    : AppColors.greenSoft,
                child: Text(
                  t.name.characters.first,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    Text(
                      t.profile,
                      style: TextStyle(color: sub, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Entreprises partenaires (vitrine)
// -----------------------------------------------------------------------------

class PartnersShowcase extends StatelessWidget {
  const PartnersShowcase({super.key});

  static const _companies = [
    ('SONATEL', 'Télécoms', Icons.wifi_tethering_rounded, Color(0xFFFF7900)),
    ('SenElec', 'Énergie', Icons.bolt_rounded, Color(0xFF0B6E4F)),
    ('Orange Sn', 'Télécoms', Icons.phone_iphone_rounded, Color(0xFFE66A00)),
    ('SGBS', 'Banque', Icons.account_balance_rounded, Color(0xFFC0392B)),
    ('Auchan', 'Distribution', Icons.storefront_rounded, Color(0xFFD62B2B)),
  ];

  @override
  Widget build(BuildContext context) {
    final horizontal = context.pageHorizontalPadding;
    final tiles = [
      for (final (name, sector, icon, color) in _companies)
        _PartnerTile(name: name, sector: sector, icon: icon, color: color),
    ];

    if (context.isDesktop) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontal),
        child: Row(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: tiles[i]),
            ],
          ],
        ),
      );
    }
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontal),
        itemCount: tiles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => SizedBox(width: 170, child: tiles[i]),
      ),
    );
  }
}

class _PartnerTile extends StatelessWidget {
  const _PartnerTile({
    required this.name,
    required this.sector,
    required this.icon,
    required this.color,
  });

  final String name;
  final String sector;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go(RoutePaths.jobs),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: 13.5,
                      ),
                    ),
                    Text(sector, style: context.textTheme.labelSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Appel à l'action final
// -----------------------------------------------------------------------------

class FinalCallToAction extends StatelessWidget {
  const FinalCallToAction({
    super.key,
    required this.isGuest,
    required this.voitOrientation,
  });
  final bool isGuest;

  /// Lycéen : simulation du bac. Étudiant / diplômé : offres de la veille IA.
  final bool voitOrientation;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktop;
    final text = Column(
      crossAxisAlignment: desktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        AppTypography.heroTitle(
          straight: 'Votre avenir commence',
          accent: "aujourd'hui.",
          fontSize: desktop ? 26 : 21,
          straightColor: AppColors.primary,
          accentColor: AppColors.accentDark,
        ),
        const SizedBox(height: 8),
        Text(
          isGuest
              ? 'Rejoignez des milliers de lycéens et d’étudiants sénégalais qui préparent leur avenir avec Ndimbeul.'
              : voitOrientation
              ? 'Faites le point sur votre orientation en lançant une simulation de votre bac.'
              : 'Découvrez les dernières offres, concours et bourses trouvés par la veille IA.',
          textAlign: desktop ? TextAlign.start : TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );

    final buttons = Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: () => isGuest
              ? context.push(RoutePaths.register)
              : voitOrientation
              ? context.push(RoutePaths.orientationSimulation)
              : context.go(RoutePaths.jobs),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
          icon: Icon(
            isGuest
                ? Icons.person_add_alt_1_rounded
                : voitOrientation
                ? Icons.calculate_rounded
                : Icons.work_rounded,
            size: 19,
          ),
          label: Text(
            isGuest
                ? 'Créer mon compte gratuit'
                : voitOrientation
                ? 'Simuler mon bac'
                : 'Voir les offres',
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go(RoutePaths.chat),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.3),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
          icon: const Icon(Icons.smart_toy_rounded, size: 19),
          label: const Text('Parler à l’IA'),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pageHorizontalPadding),
      child: Container(
        padding: EdgeInsets.all(desktop ? 32 : 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF6DC), Color(0xFFE6F3EA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: desktop
            ? Row(
                children: [
                  Expanded(child: text),
                  const SizedBox(width: AppSpacing.xl),
                  buttons,
                ],
              )
            : Column(children: [text, const SizedBox(height: 18), buttons]),
      ),
    );
  }
}
