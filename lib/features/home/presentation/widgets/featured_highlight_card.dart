import 'package:flutter/material.dart';
import 'package:vmusic/core/theme/app_color.dart';
import 'package:vmusic/core/theme/app_radius.dart';
import 'package:vmusic/core/theme/app_spacing.dart';
import 'package:vmusic/features/home/domain/models/track_model.dart';

class FeaturedHighlightCard extends StatelessWidget {
  const FeaturedHighlightCard({super.key, required this.track});

  final TrackModel track;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'featured-${track.title}',
      child: Container(
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: const LinearGradient(
            colors: [Color(0xFF1DB954), Color(0xFF0D3B2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -16,
              bottom: -16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: Image.network(
                  track.imageUrl,
                  width: 190,
                  height: 190,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured release',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        track.subtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.background,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Play now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
