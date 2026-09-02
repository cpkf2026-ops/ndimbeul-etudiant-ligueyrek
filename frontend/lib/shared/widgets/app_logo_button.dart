import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_paths.dart';
import 'brand_illustration.dart';

/// Logo cliquable (chapeau + immeubles, même illustration que le splash) —
/// utilisé en en-tête des 4 écrans du shell principal. Un tap ramène à
/// l'accueil, comportement standard "logo = retour à l'accueil".
class AppLogoButton extends StatelessWidget {
  const AppLogoButton({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(size / 3),
      onTap: () => context.go(RoutePaths.dashboard),
      child: BrandIllustration(
        variant: BrandIllustrationVariant.logo,
        size: size,
        animated: false,
      ),
    );
  }
}
