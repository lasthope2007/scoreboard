import 'package:flutter/material.dart';

import '../models/enums.dart';

class AppColors {
  static const red = Color(0xFFE5383B);
  static const blue = Color(0xFF2F80ED);
  static const amber = Color(0xFFFFB300);
  static const orange = Color(0xFFFB8C00);

  static Color side(Side s) => s == Side.red ? red : blue;

  /// Panel background: a subtle tint of the side colour over the surface.
  static Color panel(BuildContext context, Side s) {
    final surface = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Color.alphaBlend(
      side(s).withValues(alpha: isDark ? 0.16 : 0.10),
      surface,
    );
  }
}

class AppTheme {
  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: Color(0xFFEDEFF3),
      onPrimary: Color(0xFF0D1015),
      secondary: AppColors.blue,
      surface: Color(0xFF14181F),
      onSurface: Color(0xFFEDEFF3),
      surfaceContainerHighest: Color(0xFF232933),
      error: AppColors.red,
    );
    return _base(scheme, const Color(0xFF0D1015));
  }

  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: Color(0xFF14181F),
      onPrimary: Colors.white,
      secondary: AppColors.blue,
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF14181F),
      surfaceContainerHighest: Color(0xFFE6E9EF),
      error: AppColors.red,
    );
    return _base(scheme, const Color(0xFFF2F4F8));
  }

  static ThemeData _base(ColorScheme scheme, Color background) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
