import 'package:flutter/material.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.playlist,
    this.onTap,
    this.size = 150,
  });

  final PlaylistModel playlist;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'playlist-${playlist.id}',
              child: AppNetworkImage(
                url: playlist.imageUrl,
                width: size,
                height: size,
                borderRadius: AppRadius.md,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              playlist.title,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${playlist.songs.length} songs',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
