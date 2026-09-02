import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';

/// Grille multi-colonnes pilotée par breakpoint — remplace les listes à
/// défilement horizontal figées par une vraie réorganisation en colonnes
/// sur tablette/desktop. Les enfants gardent leur hauteur naturelle
/// (utilise [Wrap], pas [GridView]) pour rester compatible avec des cartes
/// de hauteurs variables.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 12,
    this.runSpacing = 12,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;

  int _columnsFor(BuildContext context) {
    if (context.isDesktop) return desktopColumns;
    if (context.isTablet) return tabletColumns;
    return mobileColumns;
  }

  @override
  Widget build(BuildContext context) {
    final columns = _columnsFor(context).clamp(1, children.isEmpty ? 1 : children.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = spacing * (columns - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}
