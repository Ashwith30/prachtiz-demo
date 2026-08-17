import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Page Title (32)
  static TextStyle get pageTitle => GoogleFonts.poppins(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: AppColors.gray900,
        letterSpacing: 0,
      );

  // Section Title (24)
  static TextStyle get sectionTitle => GoogleFonts.poppins(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: AppColors.gray800,
        letterSpacing: 0,
      );

  // Card Title (15)
  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 15.0,
        fontWeight: FontWeight.w700,
        color: AppColors.greyText,
      );

  // Card Value (34)
  static TextStyle get cardValue => GoogleFonts.poppins(
        fontSize: 34.0,
        fontWeight: FontWeight.bold,
        color: AppColors.gray900,
        letterSpacing: 0,
        height: 1.1,
      );

  // Body Text (14)
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: AppColors.greyText,
      );

  // Body Semibold (14)
  static TextStyle get bodySemibold => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: AppColors.gray900,
      );

  // Caption (12)
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: AppColors.greyText,
      );

  // Muted Label (12)
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: AppColors.gray400,
      );

  // Backward Compatibility mappings
  static TextStyle get headline => pageTitle;
  static TextStyle get title => sectionTitle;
  static TextStyle get subtitle => cardTitle;

  // Material 3 Text Theme Mapping
  static TextTheme get textTheme => TextTheme(
        headlineLarge: pageTitle,
        headlineMedium: sectionTitle,
        titleLarge: cardTitle,
        bodyLarge: bodySemibold,
        bodyMedium: body,
        bodySmall: caption,
        labelSmall: label,
      );
}
