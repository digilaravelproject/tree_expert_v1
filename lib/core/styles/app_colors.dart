import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// ========================
  /// BRAND COLORS - Nature Inspired
  /// ========================

  static const Color primary = Color(0xFF2E7D32);        // Forest Green
  static const Color primaryDark = Color(0xFF1B5E20);    // Deep Forest
  static const Color primaryLight = Color(0xFF81C784);   // Light Green
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// ========================
  /// SECONDARY - Earth Tones
  /// ========================

  static const Color secondary = Color(0xFF8D6E63);      // Earth Brown
  static const Color secondaryDark = Color(0xFF5D4037);  // Dark Brown
  static const Color secondaryLight = Color(0xFFBCAAA4); // Light Brown
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// ========================
  /// ACCENT - Natural Accents
  /// ========================

  static const Color accent = Color(0xFF66BB6A);         // Fresh Leaf Green
  static const Color accentLight = Color(0xFFA5D6A7);    // Pale Leaf
  static const Color skyBlue = Color(0xFF4FC3F7);        // Sky Blue

  /// ========================
  /// STATE COLORS
  /// ========================

  static const Color success = Color(0xFF4CAF50);        // Success Green
  static const Color warning = Color(0xFFFFA726);        // Warning Orange
  static const Color error = Color(0xFFEF5350);          // Error Red
  static const Color info = Color(0xFF29B6F6);           // Info Blue

  static const Color onSuccess = Colors.white;
  static const Color onWarning = Colors.black87;
  static const Color onError = Colors.white;

  /// ========================
  /// COMMON COLORS
  /// ========================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  /// =================================================
  /// LIGHT MODE – Nature & Clean
  /// =================================================

  static const Color lightBackground = Color(0xFFF1F8F4);    // Soft Mint
  static const Color lightSurface = Color(0xFFFFFFFF);       // Pure White
  static const Color lightCard = Color(0xFFFFFFFF);          // White Card
  static const Color lightAppBar = Color(0xFFE8F5E9);        // Pale Green

  static const Color lightTextPrimary = Color(0xFF1B5E20);   // Dark Green Text
  static const Color lightTextSecondary = Color(0xFF558B2F); // Medium Green
  static const Color lightTextDisabled = Color(0xFF9E9E9E);  // Gray

  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightBorder = Color(0xFFC8E6C9);        // Soft Green Border

  static const Color lightIcon = Color(0xFF2E7D32);          // Green Icons
  static const Color lightIconBg = Color(0xFFF1F8F4);        // Light Green BG

  static const Color lightChipBg = Color(0xFFE8F5E9);        // Chip Green
  static const Color lightShadow = Color(0x1A000000);

  static const Color lightPrimaryContainer = Color(0xFFC8E6C9);    // Light Container
  static const Color lightSecondaryContainer = Color(0xFFD7CCC8);  // Brown Container

  static const Color lightShimmerBase = Color(0xFFE8F5E9);
  static const Color lightShimmerHighlight = Color(0xFFF1F8F4);

  static List<Color> lightGradientPrimary = [
    Color(0xFF2E7D32),  // Forest Green
    Color(0xFF66BB6A),  // Fresh Green
  ];

  static List<Color> borderGradient = [
    Color(0xFF2E7D32),  // Primary
    Color(0xFF66BB6A),  // Accent
  ];

  static List<Color> lightBackgroundGradient = [
    Color(0xFFE8F5E9),  // Top - Pale Green
    Color(0xFFF1F8F4),  // Mid - Soft Mint
    Color(0xFFFAFDFB),  // Bottom - Almost White
  ];

  /// =================================================
  /// DARK MODE – Night Forest
  /// =================================================

  static const Color darkBackground = Color(0xFF0D1F12);     // Dark Forest
  static const Color darkSurface = Color(0xFF1B2E1F);        // Forest Floor
  static const Color darkCard = Color(0xFF263D2A);           // Elevated Surface
  static const Color darkAppBar = Color(0xFF1B5E20);         // Deep Green AppBar

  /// ------------ TEXT ------------
  static const Color darkTextPrimary = Color(0xFFE8F5E9);    // Light Green Text
  static const Color darkTextSecondary = Color(0xFFA5D6A7);  // Pale Green
  static const Color darkTextDisabled = Color(0xFF6B7F6F);   // Muted Green

  /// ------------ UI ELEMENTS ------------
  static const Color darkDivider = Color(0xFF2E4A32);
  static const Color darkBorder = Color(0xFF33503A);

  static const Color darkIcon = Color(0xFF81C784);           // Green Icons

  /// ------------ SMALL ELEMENTS ------------
  static const Color darkChipBg = Color(0xFF1F3823);
  static const Color darkShadow = Color(0x40000000);

  /// ------------ CONTAINERS ------------
  static const Color darkPrimaryContainer = Color(0xFF2E7D32);
  static const Color darkSecondaryContainer = Color(0xFF4E342E);

  /// ------------ SHIMMER EFFECT ------------
  static const Color darkShimmerBase = Color(0xFF1B2E1F);
  static const Color darkShimmerHighlight = Color(0xFF263D2A);

  /// ------------ GRADIENTS ------------
  static List<Color> darkGradientPrimary = [
    Color(0xFF1B5E20),  // Deep Forest
    Color(0xFF2E7D32),  // Forest Green
  ];

  static List<Color> darkBackgroundGradient = [
    Color(0xFF0A1A0E),  // Top - Very Dark
    Color(0xFF0D1F12),  // Mid - Dark Forest
    Color(0xFF1B2E1F),  // Bottom - Forest Floor
  ];

  /// ========================
  /// TREE-SPECIFIC UI COLORS
  /// ========================

  static const Color healthyTree = Color(0xFF4CAF50);        // Healthy Status
  static const Color moderateTree = Color(0xFFFFA726);       // Moderate Status
  static const Color criticalTree = Color(0xFFEF5350);       // Critical Status
  static const Color deadTree = Color(0xFF795548);           // Dead/Removed

  static const Color surveyActive = Color(0xFF66BB6A);       // Active Survey
  static const Color surveyPending = Color(0xFFFFB74D);      // Pending
  static const Color surveyCompleted = Color(0xFF81C784);    // Completed

  static const Color treeBadge = Color(0xFF2E7D32);          // Achievement Badge
  static const Color conservationBadge = Color(0xFF558B2F);  // Conservation Badge

  static const Color ratingActive = Color(0xFFFFD54F);       // Star Rating
  static const Color ratingInactive = Color(0xFFBDBDBD);

  static const Color buttonDisabled = Color(0xFFBDBDBD);
  static const Color buttonPressed = Color(0xFF1B5E20);
}

class AppGradients {
  static LinearGradient primaryLight = LinearGradient(
    colors: AppColors.lightGradientPrimary,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient primaryDark = LinearGradient(
    colors: AppColors.darkGradientPrimary,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient backgroundLight = LinearGradient(
    colors: AppColors.lightBackgroundGradient,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient backgroundDark = LinearGradient(
    colors: AppColors.darkBackgroundGradient,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Tree Health Gradient
  static LinearGradient healthyGradient = LinearGradient(
    colors: [
      Color(0xFF66BB6A),
      Color(0xFF4CAF50),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warning Gradient
  static LinearGradient warningGradient = LinearGradient(
    colors: [
      Color(0xFFFFB74D),
      Color(0xFFFFA726),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Critical Gradient
  static LinearGradient criticalGradient = LinearGradient(
    colors: [
      Color(0xFFEF5350),
      Color(0xFFE53935),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Nature Gradient (for cards/backgrounds)
  static LinearGradient natureGradient = LinearGradient(
    colors: [
      Color(0xFF1B5E20),
      Color(0xFF2E7D32),
      Color(0xFF388E3C),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient getPrimaryGradient(bool isDarkMode) {
    return isDarkMode ? primaryDark : primaryLight;
  }

  static LinearGradient getBackgroundGradient(bool isDarkMode) {
    return isDarkMode ? backgroundDark : backgroundLight;
  }

  /// Get tree health gradient based on status
  static LinearGradient getTreeHealthGradient(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return healthyGradient;
      case 'moderate':
      case 'warning':
        return warningGradient;
      case 'critical':
      case 'unhealthy':
        return criticalGradient;
      default:
        return healthyGradient;
    }
  }
}