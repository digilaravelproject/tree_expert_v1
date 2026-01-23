import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/app_dimens.dart';
import '../app_colors.dart';
import '../app_text_theme.dart';

class AppLightTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    primaryColorDark: AppColors.primaryDark,
    secondaryHeaderColor: AppColors.white,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.lightSurface,
      onSecondary: AppColors.onSecondary,
      error: AppColors.error,
      onPrimary: AppColors.onPrimary,
      onSurfaceVariant: AppColors.lightIcon,
    ),
    shadowColor: AppColors.lightShadow,
    dividerColor: AppColors.lightBorder,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColorLight: AppColors.primaryLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightAppBar,
      elevation: 0,
      iconTheme: IconThemeData(
        color: AppColors.lightIcon,
        applyTextScaling: false,
      ),
      surfaceTintColor: AppColors.lightAppBar,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColors.lightAppBar,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        side: BorderSide(color: AppColors.lightBorder),
      ),
    ),
    textTheme: AppTextTheme.lightTextTheme,
    iconTheme: const IconThemeData(color: AppColors.lightIcon),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightDivider,
      thickness: 1,
      space: 1,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primary,
      disabledColor: AppColors.buttonDisabled,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        textStyle: TextStyle(
          color: AppColors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusXLarge),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        textStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightChipBg,
      disabledColor: AppColors.lightTextDisabled,
      selectedColor: AppColors.primary,
      secondarySelectedColor: AppColors.secondary,
      labelStyle: const TextStyle(color: AppColors.lightTextPrimary),
      secondaryLabelStyle: const TextStyle(color: AppColors.white),
      brightness: Brightness.light,
      padding: const EdgeInsets.all(4),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      hintStyle: TextStyle(color: AppColors.lightTextDisabled, fontSize: 12),
      labelStyle: TextStyle(color: AppColors.lightTextSecondary),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        side: BorderSide(color: AppColors.lightDivider, width: 1),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        highlightColor: AppColors.primary.withValues(alpha: 0.4),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(4),
        side: BorderSide(width: 0.6),
      ),
    ),
  );
}
