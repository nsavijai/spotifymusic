import 'package:flutter/material.dart';
import 'app_color.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get primary => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get miniPlayer => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.6),
          blurRadius: 32,
          offset: const Offset(0, -4),
        ),
      ];
}
