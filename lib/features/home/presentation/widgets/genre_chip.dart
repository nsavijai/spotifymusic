import 'package:flutter/material.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class GenreChip extends StatelessWidget {
  const GenreChip({super.key, required this.genre, this.onTap});

  final GenreModel genre;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(genre.color);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: AppRadius.circularFull,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          genre.name,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
