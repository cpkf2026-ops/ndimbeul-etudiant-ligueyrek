import '../../shared/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Échelle d'espacement centralisée — remplace les magic numbers
/// `EdgeInsets.symmetric(horizontal: 20)` dispersés dans les écrans.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 28;
  static const double xxl = 40;

  static const double pageHorizontalMobile = 20;
  static const double pageHorizontalTablet = 32;
  static const double pageHorizontalDesktop = 48;
}

extension AppSpacingContext on BuildContext {
  double get pageHorizontalPadding {
    if (isDesktop) return AppSpacing.pageHorizontalDesktop;
    if (isTablet) return AppSpacing.pageHorizontalTablet;
    return AppSpacing.pageHorizontalMobile;
  }
}
