import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// App theme configurations for Aqua Sort Master
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundTop,
      primaryColor: AppColors.primaryCyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryCyan,
        secondary: AppColors.primaryBlue,
        tertiary: AppColors.primaryPurple,
        surface: AppColors.backgroundMid,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 1.1,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.glassFill,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.glassBorder, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.backgroundMid,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: AppColors.glassBorder, width: 2),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCyan,
          foregroundColor: const Color(0xFF002244),
          elevation: 6,
          shadowColor: AppColors.primaryCyan.withAlpha(128),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Glassmorphic container decoration helper
  static BoxDecoration glassBox({
    Color? color,
    Color? borderColor,
    double borderRadius = 20,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.glassFill,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.glassBorder,
        width: 1.5,
      ),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
    );
  }

  /// Glowing gradient button decoration
  static BoxDecoration gradientButtonBox({
    List<Color>? colors,
    double borderRadius = 18,
    bool glow = true,
  }) {
    final gradientColors = colors ??
        [
          AppColors.primaryCyan,
          AppColors.primaryBlue,
        ];

    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: glow
          ? [
              BoxShadow(
                color: gradientColors.first.withAlpha(102),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }
}
