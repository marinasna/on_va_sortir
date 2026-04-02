import 'package:flutter/material.dart';
import 'package:create_good_app/app/core/accessibility_provider.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────
class AppColors {
  static bool get _isDark => AccessibilityProvider.instance.darkMode;
  static bool get _isHC => AccessibilityProvider.instance.highContrast;

  // Primary Action Color
  static Color get primary => _isHC 
      ? (_isDark ? Colors.white : Colors.black) 
      : (_isDark ? const Color(0xFF818CF8) : const Color(0xFF7A1E2A)); // Indigo clair en mode sombre

  // Helper for icons/text on primary background
  static Color get onPrimary => _isHC 
      ? (_isDark ? Colors.black : Colors.white)
      : Colors.white;
  
  static Color get orange => _isHC 
      ? (_isDark ? Colors.yellow : const Color(0xFFE8491C)) 
      : (_isDark ? const Color(0xFFFB923C) : const Color(0xFFFF6B35));
      
  static Color get green => _isHC ? Colors.greenAccent : const Color(0xFF3E8914);
  static Color get purple => const Color(0xFF6844AC);
  static Color get purpleDark => const Color(0xFF440EAB);
  
  // Backgrounds
  static Color get background => _isHC
      ? (_isDark ? Colors.black : Colors.white)
      : (_isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF));
      
  static Color get lightOrangeBg => _isHC
      ? (_isDark ? Colors.grey.shade900 : Colors.white)
      : (_isDark ? const Color(0xFF2C2C2E) : const Color(0xFFFFF5E6));
      
  static Color get inputBg => _isHC
      ? (_isDark ? Colors.black : Colors.white)
      : (_isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9FAFB));

  static Color get badgeBg => _isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF3F4F6);
  static Color get notifBg => _isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF0FDF4);

  // Text Colors
  static Color get textDark => _isHC
      ? (_isDark ? Colors.white : Colors.black)
      : (_isDark ? const Color(0xFFFFFFFF) : const Color(0xFF101828));
      
  static Color get textSecondary => _isHC
      ? (_isDark ? Colors.white70 : Colors.black87)
      : (_isDark ? const Color(0xFFCBD5E1) : const Color(0xFF6A7282)); // Plus clair en sombre
      
  static Color get textLabel => _isHC
      ? (_isDark ? Colors.white : Colors.black)
      : (_isDark ? const Color(0xFFE2E8F0) : const Color(0xFF364153));

  // Borders & Dividers
  static Color get border => _isHC
      ? (_isDark ? Colors.white : Colors.black)
      : (_isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB));
      
  static Color get inputBorder => _isDark ? const Color(0xFF4A5568) : const Color(0xFFD1D5DB);

  static Color get mapGrey => const Color(0xFFDDDDDD);
  static Color get salmonMarker => const Color(0xFFFFA07A);

  // Helper for gradients in CarteScreen
  static LinearGradient getGradient(String categoryLabel) {
    // Basic mapping, could be more complex
    return const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFE8491C)]);
  }
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}

class AppTextStyles {
  static const String fontFamily = 'Poppins';

  static TextStyle get heading1 => TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    height: 1.2,
  );

  static TextStyle get heading2 => TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    height: 1.3,
  );

  static TextStyle get heading3 => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.35,
  );

  static TextStyle get body => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get label => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.4,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static TextStyle get captionBold => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textLabel,
    height: 1.3,
  );

  static TextStyle get button => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.onPrimary,
    height: 1.5,
  );
}
