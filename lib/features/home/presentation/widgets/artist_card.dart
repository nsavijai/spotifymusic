import 'package:flutter/material.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';

class ArtistCard extends StatelessWidget {
  const ArtistCard({
    super.key,
    required this.artist,
    this.onTap,
  });

  final ArtistModel artist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        child: Column(
          children: [
            Hero(
              tag: 'artist-${artist.id}',
              child: AppNetworkImage(
                url: artist.imageUrl,
                width: 90,
                height: 90,
                isCircle: true,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              artist.name,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              artist.genre,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
