import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/styles/colors.dart';

const String kThemeKey = 'selected_theme';

enum AppThemeType { yellow, blue, red }

class AppTheme {
  static Future<AppThemeType> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(kThemeKey);

    switch (themeName) {
      case 'blue':
        return AppThemeType.blue;
      case 'red':
        return AppThemeType.red;
      case 'yellow':
      default:
        return AppThemeType.yellow;
    }
  }

  static Future<void> saveTheme(AppThemeType theme) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(kThemeKey, theme.name);
  }

  static ThemeData getTheme(AppThemeType type) {
    Color primary;
    switch (type) {
      case AppThemeType.blue:
        primary = AppColors.bluePrimary;
        break;
      case AppThemeType.red:
        primary = AppColors.redPrimary;
        break;
      case AppThemeType.yellow:
      default:
        primary = AppColors.yellowPrimary;
    }

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: AppColors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.menuBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: AppColors.grayBlack,
        background: AppColors.black,
        surface: AppColors.menuBackground,
      ),
      iconTheme: const IconThemeData(color: AppColors.iconColor),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Customy',
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Customy',
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Customy',
          fontWeight: FontWeight.w300,
          fontSize: 14,
        ),

        titleMedium: TextStyle(
          fontFamily: 'Customy',
          fontSize: 14,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Customy',
          fontWeight: FontWeight.w700,
          fontSize: 32,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Customy',
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Customy',
          fontWeight: FontWeight.w400,
          fontSize: 18,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Customy',
          fontWeight: FontWeight.w300,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Customy',
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Customy',
          fontWeight: FontWeight.w300,
          fontSize: 12,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Customy', 
          fontWeight: FontWeight.w200,
          fontSize: 10,
        ),

      ),
    );
  }
}
