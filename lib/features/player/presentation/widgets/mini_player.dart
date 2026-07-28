import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../presentation/providers/player_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final song = player.currentSong;

    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/player'),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.circularLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.sm),
            AppNetworkImage(
              url: song.imageUrl,
              width: 44,
              height: 44,
              borderRadius: AppRadius.sm,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    song.artist,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () =>
                  ref.read(playerProvider.notifier).toggleFavorite(),
              icon: Icon(
                player.currentSong?.isFavorite == true
                    ? AppIcons.favorite
                    : AppIcons.favoriteBorder,
                color: player.currentSong?.isFavorite == true
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
            IconButton(
              onPressed: () => ref.read(playerProvider.notifier).togglePlay(),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  player.isPlaying ? AppIcons.pause : AppIcons.play,
                  key: ValueKey(player.isPlaying),
                  color: AppColors.textPrimary,
                  size: 28,
                ),
              ),
            ),
            IconButton(
              onPressed: () => ref.read(playerProvider.notifier).skipNext(),
              icon: const Icon(
                AppIcons.skipNext,
                color: AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
      )
          .animate()
          .slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOut)
          .fadeIn(duration: 200.ms),
    );
  }
}
