import 'package:flutter/material.dart';
import 'package:vmusic/core/theme/app_animation.dart';
import 'package:vmusic/core/theme/app_color.dart';
import 'package:vmusic/core/theme/app_radius.dart';
import 'package:vmusic/core/theme/app_spacing.dart';
import 'package:vmusic/widgets/primary_button.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppAnimation.normal,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: [Color(0xFF1DB954), Color(0xFF0C4A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Freshly curated',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your premium listening space',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(label: 'Explore now', onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Image.network(
              'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=600&q=80',
              width: 110,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
