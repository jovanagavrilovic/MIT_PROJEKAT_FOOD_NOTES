import 'package:flutter/material.dart';
import 'app_colors.dart';

class Styles {
  static ThemeData themeData({
    required bool isDarkTheme,
    required BuildContext context,
  }) {
    final scaffoldBg =
        isDarkTheme ? AppColors.darkScaffold : AppColors.lightScaffold;
    final surface =
        isDarkTheme ? AppColors.darkSurface : AppColors.lightSurface;
    final primary =
        isDarkTheme ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textColor =
        isDarkTheme ? AppColors.darkText : AppColors.lightText;

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      surface: surface,
      background: scaffoldBg,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,

      scaffoldBackgroundColor: scaffoldBg,
      cardColor: surface,

    appBarTheme: AppBarTheme(
  backgroundColor: isDarkTheme ? surface : primary,

  foregroundColor: isDarkTheme ? AppColors.darkPrimary : AppColors.appBarText,

  elevation: 0,
  centerTitle: false,

  titleTextStyle: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: isDarkTheme ? AppColors.darkPrimary : AppColors.appBarText,
  ),
),


      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface, // 
        indicatorColor: primary.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withOpacity(0.15),
        labelStyle: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
