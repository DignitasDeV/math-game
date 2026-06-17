import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static const _radius = 20.0;
  static const _buttonRadius = 16.0;

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.lilacAccent,
      primary: AppColors.pinkAccent,
      onPrimary: Colors.white,
      secondary: AppColors.mintAccent,
      onSecondary: Colors.white,
      tertiary: AppColors.starGold,
      surface: AppColors.cloud,
      onSurface: AppColors.purpleText,
      secondaryContainer: AppColors.softLilac.withValues(alpha: 0.25),
      onSecondaryContainer: AppColors.purpleText,
    );

    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.nunitoTextTheme(),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cloud,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.purpleText,
        titleTextStyle: AppTypography.sectionTitle,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(56, 56),
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          backgroundColor: AppColors.pinkAccent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(56, 56),
          textStyle: AppTypography.button,
          foregroundColor: AppColors.purpleText,
          side: const BorderSide(
            color: AppColors.softLilac,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lilacAccent,
          textStyle: AppTypography.textButton,
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: AppTypography.chip,
        secondaryLabelStyle: AppTypography.chip.copyWith(
          color: AppColors.purpleText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
          borderSide: const BorderSide(color: AppColors.softLilac),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
          borderSide: const BorderSide(color: AppColors.softLilac, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
          borderSide:
              const BorderSide(color: AppColors.lilacAccent, width: 2.5),
        ),
        labelStyle: AppTypography.input,
        hintStyle: AppTypography.helper,
        floatingLabelStyle: AppTypography.label.copyWith(
          color: AppColors.lilacAccent,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.lilacAccent,
        size: 28,
      ),
    );
  }
}
