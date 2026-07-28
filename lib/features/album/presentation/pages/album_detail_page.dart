import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../home/presentation/widgets/track_tile.dart';
import '../../../player/presentation/providers/player_provider.dart';

class AlbumDetailPage extends ConsumerWidget {
  const AlbumDetailPage({super.key, required this.album});

  final AlbumModel album;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _AlbumAppBar(album: album),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      AppNetworkImage(
                        url: sampleArtists
                            .firstWhere((a) => a.id == album.artistId,
                                orElse: () => sampleArtists.first)
                            .imageUrl,
                        width: 28,
                        height: 28,
                        isCircle: true,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () {
                          final artist = sampleArtists.firstWhere(
                              (a) => a.id == album.artistId,
                              orElse: () => sampleArtists.first);
                          context.push('/artist/${artist.id}', extra: artist);
                        },
                        child: Text(
                          album.artist,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Album · ${album.year} · ${album.songs.length} songs · ${album.totalDuration}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    album.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 250.ms),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(AppIcons.favoriteBorder,
                            color: AppColors.textSecondary),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(AppIcons.download,
                            color: AppColors.textSecondary),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(AppIcons.more,
                            color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          if (album.songs.isNotEmpty) {
                            ref.read(playerProvider.notifier).playSong(
                                  album.songs[
                                      (album.songs.length * 0.5).floor()],
                                  queue: album.songs,
                                );
                          }
                        },
                        icon: const Icon(AppIcons.shuffle,
                            color: AppColors.textSecondary, size: 28),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () {
                          if (album.songs.isNotEmpty) {
                            ref.read(playerProvider.notifier).playSong(
                                  album.songs.first,
                                  queue: album.songs,
                                );
                          }
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Icon(AppIcons.play,
                              color: Colors.black, size: 32),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => TrackTile(
                song: album.songs[i],
                index: i + 1,
                showIndex: true,
                queue: album.songs,
              ).animate(delay: (i * 50).ms).fadeIn().slideX(begin: -0.05),
              childCount: album.songs.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _AlbumAppBar extends StatelessWidget {
  const _AlbumAppBar({required this.album});

  final AlbumModel album;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
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
        title: Text(
          album.title,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        titlePadding: const EdgeInsets.only(
            left: AppSpacing.md, bottom: AppSpacing.md, right: 80),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'album-${album.id}',
              child: AppNetworkImage(
                url: album.imageUrl,
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
          ],
        ),
      ),
    );
  }
}
