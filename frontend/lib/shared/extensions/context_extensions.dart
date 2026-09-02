import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

extension ContextExtensions on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;

  ScreenSize get breakpoint {
    final w = screenWidth;
    if (w >= 1024) return ScreenSize.desktop;
    if (w >= 600) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  bool get isMobile => breakpoint == ScreenSize.mobile;
  bool get isTablet => breakpoint == ScreenSize.tablet;
  bool get isDesktop => breakpoint == ScreenSize.desktop;

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colorScheme.error : null,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}
