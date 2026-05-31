import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryPink,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryPink,
        secondary: AppColors.secondaryPink,
        surface: AppColors.secondaryBackground,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: AppSizes.titleLarge,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: AppSizes.subtitle,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: AppSizes.bodyNormal,
          color: AppColors.white,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: AppSizes.bodyNormal - 2,
          color: AppColors.greyText,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: AppSizes.buttonText,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: AppSizes.subtitle,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        iconTheme: IconThemeData(
          color: AppColors.primaryPink,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.secondaryBackground,
        selectedItemColor: AppColors.primaryPink,
        unselectedItemColor: AppColors.greyText,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPink,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
          ),
          textStyle: const TextStyle(
            fontSize: AppSizes.buttonText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r16),
        ),
        elevation: 4,
      ),
    );
  }

  // Optional light theme if needed, but the implementation plan specifies dark is the official default.
  static ThemeData get lightTheme => darkTheme; // Default to dark for premium aesthetic.
}
