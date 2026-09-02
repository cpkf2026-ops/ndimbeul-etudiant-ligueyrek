import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

/// Bascule entre 3 mises en page selon la largeur d'écran :
/// < 600 mobile · 600-1024 tablette · >= 1024 desktop/web.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    switch (context.breakpoint) {
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.mobile:
        return mobile;
    }
  }
}
