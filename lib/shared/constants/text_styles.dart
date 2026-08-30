import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'IBM Plex Sans',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: 'IBM Plex Sans',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: 'IBM Plex Sans',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'IBM Plex Sans',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'IBM Plex Sans',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'IBM Plex Sans',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textInverse,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'IBM Plex Sans',
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle link = TextStyle(
    fontFamily: 'IBM Plex Sans',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.textSecondary,
  );
}
