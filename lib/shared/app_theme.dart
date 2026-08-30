import 'package:budget_wise/shared/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'constants/spacing.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primaryBackground,
      primaryColor: AppColors.primaryAccent,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryAccent,
        onPrimary: AppColors.textInverse,
        surface: AppColors.secondaryBackground,
        onSurface: AppColors.textPrimary,
        secondary: AppColors.primaryAccent,
      ),

      datePickerTheme: DatePickerThemeData(
        headerBackgroundColor: AppColors.primaryAccent,
        headerForegroundColor: AppColors.textInverse,
        backgroundColor: AppColors.secondaryBackground,
        dividerColor: AppColors.borderColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),

      // Text Theme
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'IBM Plex Sans',
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'IBM Plex Sans',
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: AppColors.primaryAccent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),

      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'IBM Plex Sans',
          ),
        ),
      ),

      // TextButton Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            fontFamily: 'IBM Plex Sans',
          ),
        ),
      ),
    );
  }
}
