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

class PlaylistDetailPage extends ConsumerWidget {
  const PlaylistDetailPage({super.key, required this.playlist});

  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _PlaylistAppBar(playlist: playlist),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    playlist.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        playlist.owner,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                      Text(
                        ' · ${playlist.formattedFollowers} saves',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ).animate().fadeIn(delay: 250.ms),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
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
                        onPressed: () {},
                        icon: const Icon(AppIcons.shuffle,
                            color: AppColors.textSecondary, size: 28),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () {
                          if (playlist.songs.isNotEmpty) {
                            ref.read(playerProvider.notifier).playSong(
                                  playlist.songs.first,
                                  queue: playlist.songs,
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
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 2,
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
                song: playlist.songs[i],
                queue: playlist.songs,
              ).animate(delay: (i * 40).ms).fadeIn().slideX(begin: -0.05),
              childCount: playlist.songs.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _PlaylistAppBar extends StatelessWidget {
  const _PlaylistAppBar({required this.playlist});

  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(AppIcons.back),
      ),
      actions: [
        if (playlist.isOwned)
          IconButton(
            onPressed: () =>
                context.push('/edit-playlist', extra: playlist),
            icon: const Icon(AppIcons.edit),
          ),
        IconButton(
          onPressed: () {},
          icon: const Icon(AppIcons.more),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'playlist-${playlist.id}',
              child: AppNetworkImage(
                url: playlist.imageUrl,
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
                    AppColors.background.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Text(
                playlist.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
