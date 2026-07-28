import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../widgets/section_header.dart';
import '../../../home/presentation/widgets/album_card.dart';
import '../../../home/presentation/widgets/track_tile.dart';
import '../../../player/presentation/providers/player_provider.dart';

class ArtistDetailPage extends ConsumerWidget {
  const ArtistDetailPage({super.key, required this.artist});

  final ArtistModel artist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedArtists =
        sampleArtists.where((a) => a.id != artist.id).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _ArtistAppBar(artist: artist),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats + Follow
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${artist.formattedListeners} monthly listeners',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            artist.genre,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                        ),
                        child: const Text('Follow'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () {
                          if (artist.popularSongs.isNotEmpty) {
                            ref.read(playerProvider.notifier).playSong(
                                  artist.popularSongs.first,
                                  queue: artist.popularSongs,
                                );
                          }
                        },
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.4),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Icon(AppIcons.play,
                              color: Colors.black, size: 28),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Popular songs
                SectionHeader(
                  title: 'Popular',
                  onSeeAll: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                ...artist.popularSongs.asMap().entries.map(
                      (e) => TrackTile(
                        song: e.value,
                        index: e.key + 1,
                        showIndex: true,
                        queue: artist.popularSongs,
                      )
                          .animate(delay: (e.key * 50).ms)
                          .fadeIn()
                          .slideX(begin: -0.05),
                    ),
                const SizedBox(height: AppSpacing.lg),

                // Albums
                if (artist.albums.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Albums',
                    onSeeAll: () {},
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      scrollDirection: Axis.horizontal,
                      itemCount: artist.albums.length,
                      itemBuilder: (_, i) => AlbumCard(
                        album: artist.albums[i],
                        onTap: () => context.push(
                            '/album/${artist.albums[i].id}',
                            extra: artist.albums[i]),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Biography
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppRadius.lg),
                        child: Stack(
                          children: [
                            AppNetworkImage(
                              url: artist.bannerUrl,
                              width: double.infinity,
                              height: 180,
                              borderRadius: 0,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(
                                    AppSpacing.md),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black
                                          .withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Text(
                                  '${artist.formattedListeners} monthly listeners',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        artist.biography,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Related artists
                SectionHeader(
                  title: 'Fans also like',
                  onSeeAll: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    scrollDirection: Axis.horizontal,
                    itemCount: relatedArtists.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => context.push(
                          '/artist/${relatedArtists[i].id}',
                          extra: relatedArtists[i]),
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: AppSpacing.md),
                        child: Column(
                          children: [
                            AppNetworkImage(
                              url: relatedArtists[i].imageUrl,
                              width: 90,
                              height: 90,
                              isCircle: true,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              relatedArtists[i].name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              relatedArtists[i].genre,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistAppBar extends StatelessWidget {
  const _ArtistAppBar({required this.artist});

  final ArtistModel artist;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(AppIcons.back),
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(AppIcons.share)),
        IconButton(onPressed: () {}, icon: const Icon(AppIcons.more)),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'artist-${artist.id}',
              child: AppNetworkImage(
                url: artist.bannerUrl,
                width: double.infinity,
                height: double.infinity,
                borderRadius: 0,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (artist.isVerified)
                          Row(
                            children: [
                              const Icon(AppIcons.verified,
                                  color: AppColors.primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Verified Artist',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Text(
                          artist.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
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
