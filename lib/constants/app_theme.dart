import 'package:flutter/material.dart';
import 'package:jfk_guys/constants/light_text_theme.dart';
import 'app_colors.dart';

class AppTheme {
  // Light theme
  static final ThemeData light = ThemeData(
    fontFamily: 'Aeonik',

    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.primaryTextColor,
      secondary: AppColors.secondaryAccent,
      onSecondary: AppColors.primaryTextColor,
      background: AppColors.scaffoldBackgroundColor,
      onBackground: AppColors.primaryTextColor,
      surface: AppColors.surfaceColor,
      onSurface: AppColors.primaryTextColor,
      error: AppColors.errorTextColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
    appBarTheme: AppBarTheme(
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.primaryTextColor),
      backgroundColor: AppColors.scaffoldBackgroundColor,
      titleTextStyle: TextStyle(
        fontFamily: 'Aeonik',
        color: AppColors.primaryTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    textTheme: lightTextTheme.apply(
      bodyColor: AppColors.primaryTextColor,
      displayColor: AppColors.primaryTextColor,
      fontFamily: 'Aeonik',
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.primaryTextColor,
        textStyle: TextStyle(color: Colors.white),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondaryAccent,
      foregroundColor: AppColors.primaryTextColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceColor,
      hintStyle: TextStyle(color: AppColors.secondaryTextColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceColor,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.secondaryTextColor,
    ),
    dividerColor: AppColors.darkTextSecondary,
  );

  // Dark theme
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimaryColor!,
      onPrimary: AppColors.darkTextPrimaryColor,
      secondary: AppColors.darkSecondaryAccent,
      onSecondary: AppColors.darkTextPrimaryColor,
      background: AppColors.darkScaffoldBackground,
      onBackground: AppColors.darkTextPrimaryColor,
      surface: AppColors.darkSurfaceColor,
      onSurface: AppColors.darkTextPrimaryColor,
      error: AppColors.darkErrorText,
      onError: Colors.black,
    ),
    dividerColor: AppColors.darkTextPrimaryColor,
    scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
    appBarTheme: AppBarTheme(
      color: AppColors.darkSurfaceColor,
      
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.darkTextPrimaryColor),
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Aeonik'
      ),
    ),
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: AppColors.darkTextPrimaryColor,
      displayColor: AppColors.darkTextPrimaryColor,

      fontFamily: 'Aeonik',
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimaryColor,
        foregroundColor: AppColors.darkTextPrimaryColor,
        textStyle: TextStyle(color: AppColors.primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkSecondaryAccent,
      foregroundColor: AppColors.darkTextPrimaryColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceColor,
      hintStyle: TextStyle(color: AppColors.darkTextSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurfaceColor,
      selectedItemColor: AppColors.darkPrimaryColor,
      unselectedItemColor: AppColors.darkTextSecondary,
    ),
  );
}
