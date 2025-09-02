import 'package:flutter/material.dart';

// Modern color palette
class AppColors {
  // Primary colors - Modern green palette
  static const Color primaryGreen = Color(0xFF2E7D32); // Deep forest green
  static const Color lightGreen = Color(0xFF66BB6A); // Light fresh green
  static const Color accentOrange = Color(0xFFFF7043); // Warm orange accent

  // Surface colors
  static const Color lightSurface = Color(0xFFFAFAFA);
  static const Color darkSurface = Color(0xFF121212);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnDark = Color(0xFFFFFFFF);
}

final ThemeData messLightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryGreen,
    primary: AppColors.primaryGreen,
    secondary: AppColors.accentOrange,
    surface: AppColors.lightSurface,
    surfaceContainerHighest: AppColors.cardLight,
    brightness: Brightness.light,
  ).copyWith(
    primaryContainer: AppColors.lightGreen.withValues(alpha: 0.15),
    secondaryContainer: AppColors.accentOrange.withValues(alpha: 0.15),
  ),
  scaffoldBackgroundColor: AppColors.lightSurface,

  // Modern AppBar design
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 4,
    surfaceTintColor: AppColors.primaryGreen.withValues(alpha: 0.05),
    titleTextStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    iconTheme: const IconThemeData(color: AppColors.primaryGreen, size: 24),
  ),

  // Enhanced typography
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w900,
      color: AppColors.textPrimary,
      letterSpacing: -1.0,
    ),
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: -0.8,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.3,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryGreen,
      letterSpacing: 0.5,
    ),
  ),

  // Modern card design
  cardTheme: CardThemeData(
    color: AppColors.cardLight,
    elevation: 2,
    shadowColor: Colors.black.withValues(alpha: 0.1),
    surfaceTintColor: AppColors.primaryGreen.withValues(alpha: 0.05),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
  ),

  // Enhanced button themes
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryGreen,
      side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryGreen,
    foregroundColor: Colors.white,
    elevation: 6,
    shape: CircleBorder(),
  ),

  // Modern navigation theme
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.cardLight,
    surfaceTintColor: AppColors.primaryGreen.withValues(alpha: 0.05),
    indicatorColor: AppColors.primaryGreen.withValues(alpha: 0.15),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryGreen,
        );
      }
      return const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AppColors.primaryGreen, size: 24);
      }
      return const IconThemeData(color: AppColors.textSecondary, size: 24);
    }),
  ),

  // Chip theme
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
    labelStyle: const TextStyle(
      color: AppColors.primaryGreen,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
);

final ThemeData messDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primaryGreen,
    brightness: Brightness.dark,
    primary: AppColors.lightGreen,
    secondary: AppColors.accentOrange,
    surface: AppColors.darkSurface,
    surfaceContainerHighest: AppColors.cardDark,
  ).copyWith(
    primaryContainer: AppColors.lightGreen.withValues(alpha: 0.2),
    secondaryContainer: AppColors.accentOrange.withValues(alpha: 0.2),
  ),
  scaffoldBackgroundColor: AppColors.darkSurface,

  // Dark AppBar design
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textOnDark,
    elevation: 0,
    scrolledUnderElevation: 4,
    surfaceTintColor: AppColors.lightGreen.withValues(alpha: 0.1),
    titleTextStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textOnDark,
      letterSpacing: -0.5,
    ),
    iconTheme: const IconThemeData(color: AppColors.lightGreen, size: 24),
  ),

  // Dark typography
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w900,
      color: AppColors.textOnDark,
      letterSpacing: -1.0,
    ),
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: AppColors.textOnDark,
      letterSpacing: -0.8,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textOnDark,
      letterSpacing: -0.5,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textOnDark,
      letterSpacing: -0.3,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textOnDark,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.textOnDark,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textOnDark,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFFBDBDBD),
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFFBDBDBD),
      height: 1.3,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.lightGreen,
      letterSpacing: 0.5,
    ),
  ),

  // Dark card design
  cardTheme: CardThemeData(
    color: AppColors.cardDark,
    elevation: 2,
    shadowColor: Colors.black.withValues(alpha: 0.3),
    surfaceTintColor: AppColors.lightGreen.withValues(alpha: 0.05),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
  ),

  // Dark button themes
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.lightGreen,
      foregroundColor: AppColors.darkSurface,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.lightGreen,
      side: const BorderSide(color: AppColors.lightGreen, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.lightGreen,
    foregroundColor: AppColors.darkSurface,
    elevation: 6,
    shape: CircleBorder(),
  ),

  // Dark navigation theme
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.cardDark,
    surfaceTintColor: AppColors.lightGreen.withValues(alpha: 0.1),
    indicatorColor: AppColors.lightGreen.withValues(alpha: 0.2),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.lightGreen,
        );
      }
      return const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Color(0xFFBDBDBD),
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AppColors.lightGreen, size: 24);
      }
      return const IconThemeData(color: Color(0xFFBDBDBD), size: 24);
    }),
  ),

  // Dark chip theme
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.lightGreen.withValues(alpha: 0.15),
    labelStyle: const TextStyle(
      color: AppColors.lightGreen,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
);


class AppThemes {
  static ThemeData createLightTheme(ColorScheme? lightDynamic) {
    if (lightDynamic != null) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: lightDynamic.copyWith(
          secondary: AppColors.primaryGreen,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 4,
        ),
      );
    }
    return messLightTheme;
  }


  static ThemeData createDarkTheme(ColorScheme? darkDynamic) {
    if (darkDynamic != null) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: darkDynamic.copyWith(
          secondary: AppColors.primaryGreen,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 4,
        ),
      );
    }
    return messDarkTheme;
  }
}
