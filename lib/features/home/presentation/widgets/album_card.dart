import 'package:flutter/material.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.album,
    this.onTap,
    this.size = 160,
  });

  final AlbumModel album;
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
              tag: 'album-${album.id}',
              child: AppNetworkImage(
                url: album.imageUrl,
                width: size,
                height: size,
                borderRadius: AppRadius.md,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              album.title,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              album.artist,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
