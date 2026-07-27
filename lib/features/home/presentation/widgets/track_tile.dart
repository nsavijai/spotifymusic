import 'package:flutter/material.dart';
import 'package:vmusic/core/theme/app_color.dart';
import 'package:vmusic/core/theme/app_radius.dart';
import 'package:vmusic/core/theme/app_spacing.dart';
import 'package:vmusic/features/home/domain/models/track_model.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({super.key, required this.track});

  final TrackModel track;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Image.network(
              track.imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.title, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  track.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(track.duration, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: () {},
            icon: Icon(
              track.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: track.isFavorite ? AppColors.primary : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
