import 'package:fe_gangsta_flutter/design_system/tokens/app_colors.dart';
import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  static const String headlineFont = 'Plus Jakarta Sans';
  static const String bodyFont = 'Inter';

  static TextTheme textTheme() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: headlineFont,
        fontSize: 48,
        height: 56 / 48,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontFamily: headlineFont,
        fontSize: 40,
        height: 48 / 40,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      displaySmall: TextStyle(
        fontFamily: headlineFont,
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineLarge: TextStyle(
        fontFamily: headlineFont,
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: headlineFont,
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontFamily: headlineFont,
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontFamily: headlineFont,
        fontSize: 18,
        height: 28 / 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: headlineFont,
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontFamily: headlineFont,
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFont,
        fontSize: 16,
        height: 28 / 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        height: 24 / 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        height: 20 / 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      labelSmall: TextStyle(
        fontFamily: bodyFont,
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }
}
