import 'package:flutter/material.dart';
import '../../shared/services/settings_manager.dart';

class AppColors {
  // Brand Colors (Strictly mapped from design requirements)
  static Color get primary => SettingsManager.instance.activeAccentColor;
  static const Color secondary = Color(0xFF24C06F);     // Emerald Green
  static const Color sidebarBg = Color(0xFF13294B);     // Dark Navy Blue
  static const Color background = Color(0xFFF5F7FB);    // Light Grey/Blue Background
  static const Color cardBg = Color(0xFFFFFFFF);        // White Card Background
  static const Color danger = Color(0xFFF04438);        // Red Status
  static const Color warning = Color(0xFFF59E0B);       // Amber Status
  static const Color purple = Color(0xFF8B5CF6);        // Purple Accent
  static const Color greyText = Color(0xFF667085);      // Slate Grey Text

  // Dark Card and overlays
  static const Color darkCard = Color(0xFF10183C);
  
  // Status presets mapping
  static const Color success = secondary;
  static const Color successLight = Color(0xFFDCFCE7);  // Light green bg
  static const Color successDark = Color(0xFF15803D);

  static const Color dangerLight = Color(0xFFFEE2E2);   // Light red bg
  static const Color dangerDark = Color(0xFFB91C1C);

  static const Color warningLight = Color(0xFFFEF3C7);  // Light warning bg
  static const Color warningDark = Color(0xFFB45309);

  static const Color info = Color(0xFF0EA5E9);          // Info blue
  static const Color infoLight = Color(0xFFE0F2FE);
  static const Color infoDark = Color(0xFF0369A1);

  static const Color teal = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFFCCFBF1);
  static const Color tealDark = Color(0xFF0F766E);

  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);

  // Dividers and Borders
  static const Color divider = Color(0xFFE2E8F0);

  // Compatibility aliases
  static Color get primaryBlue => primary;
  static Color get primaryLight => primary.withOpacity(0.8);
  static Color get primaryDark => primary;
  static Color get primaryBg => primary.withOpacity(0.12);
  static Color get primaryBorder => primary.withOpacity(0.3);
  
  static const Color accentGreen = secondary;
  static const Color accentGreenLight = successLight;
  static const Color accentGreenDark = successDark;
  static const Color accentGreenBright = Color(0xFF22C55E);
  static const Color accentRed = danger;
  static const Color accentRedLight = dangerLight;
  static const Color accentOrange = warning;
  static const Color accentOrangeLight = warningLight;
  static const Color accentBlue = info;
  static const Color accentBlueLight = infoLight;
  static const Color accentPurple = purple;
  static const Color accentPurpleLight = Color(0xFFF5F3FF);
  static const Color accentTeal = teal;
  static const Color accentTealLight = tealLight;
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentPinkLight = Color(0xFFFDF2F8);

  static Color glassBg = Colors.white.withOpacity(0.82);
  static Color glassBgHover = Colors.white.withOpacity(0.92);
  static Color glassBorder = Colors.white.withOpacity(0.68);
  static Color get glassShadow => primary.withOpacity(0.06);
  static const double glassBlur = 20.0;
}
