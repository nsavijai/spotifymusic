import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../player/presentation/providers/player_provider.dart';

class TrackTile extends ConsumerWidget {
  const TrackTile({
    super.key,
    required this.song,
    this.index,
    this.showIndex = false,
    this.queue,
    this.onMoreTap,
    this.trailing,
  });

  final SongModel song;
  final int? index;
  final bool showIndex;
  final List<SongModel>? queue;
  final VoidCallback? onMoreTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final isCurrentSong = player.currentSong?.id == song.id;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      onTap: () => ref
          .read(playerProvider.notifier)
          .playSong(song, queue: queue ?? allSongs),
      leading: showIndex && index != null
          ? SizedBox(
              width: 64,
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(
                      '$index',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isCurrentSong
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AppNetworkImage(
                    url: song.imageUrl,
                    width: 40,
                    height: 40,
                    borderRadius: AppRadius.xs,
                  ),
                ],
              ),
            )
          : AppNetworkImage(
              url: song.imageUrl,
              width: 48,
              height: 48,
              borderRadius: AppRadius.sm,
            ),
      title: Text(
        song.title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: isCurrentSong ? AppColors.primary : AppColors.textPrimary,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing ??
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCurrentSong)
                  const Icon(Icons.equalizer_rounded,
                      color: AppColors.primary, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Text(song.duration,
                    style: Theme.of(context).textTheme.bodySmall),
                IconButton(
                  onPressed: onMoreTap ?? () => _showTrackOptions(context, ref),
                  icon: const Icon(AppIcons.more,
                      color: AppColors.textMuted, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
    );
  }

  void _showTrackOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TrackOptionsSheet(song: song),
    );
  }
}

class _TrackOptionsSheet extends ConsumerWidget {
  const _TrackOptionsSheet({required this.song});

  final SongModel song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            leading: AppNetworkImage(
                url: song.imageUrl, width: 48, height: 48, borderRadius: 8),
            title: Text(song.title,
                style: Theme.of(context).textTheme.titleSmall),
            subtitle: Text(song.artist,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          const Divider(),
          _OptionTile(
            icon: AppIcons.favorite,
            label: 'Add to liked songs',
            onTap: () => Navigator.pop(context),
          ),
          _OptionTile(
            icon: AppIcons.addCircle,
            label: 'Add to playlist',
            onTap: () => Navigator.pop(context),
          ),
          _OptionTile(
            icon: AppIcons.download,
            label: 'Download',
            onTap: () => Navigator.pop(context),
          ),
          _OptionTile(
            icon: AppIcons.share,
            label: 'Share',
            onTap: () => Navigator.pop(context),
          ),
          _OptionTile(
            icon: AppIcons.artist,
            label: 'Go to artist',
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      onTap: onTap,
    );
  }
}
