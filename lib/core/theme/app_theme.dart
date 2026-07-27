import 'package:flutter/material.dart';
import 'package:vmusic/core/theme/app_color.dart';

import 'app_text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),

    useMaterial3: true,

    textTheme: AppTextTheme.textTheme,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),

    dividerColor: AppColors.divider,

    cardColor: AppColors.card,

    splashFactory: InkRipple.splashFactory,
  );
}