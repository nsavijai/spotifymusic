import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../music/data/providers/music_providers.dart';
import '../../../player/presentation/providers/player_provider.dart';

class FeaturedBanner extends ConsumerStatefulWidget {
  const FeaturedBanner({super.key});

  @override
  ConsumerState<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends ConsumerState<FeaturedBanner> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(songsProvider);
    final songs = songsAsync.valueOrNull ?? allSongs;

    // Pick 3 featured songs
    final featured = [
      (
        song: songs.isNotEmpty ? songs[0] : allSongs[0],
        gradient: AppColors.primaryGradient,
        label: 'Featured release',
      ),
      (
        song: songs.length > 2 ? songs[2] : allSongs[2],
        gradient: AppColors.purpleGradient,
        label: "Editor's pick",
      ),
      (
        song: songs.length > 4 ? songs[4] : allSongs[4],
        gradient: AppColors.oceanGradient,
        label: 'New this week',
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: featured.length,
            itemBuilder: (_, i) {
              final item = featured[i];
              return _BannerCard(
                song: item.song,
                gradient: item.gradient,
                label: item.label,
                onPlay: () => ref
                    .read(playerProvider.notifier)
                    .playSong(item.song, queue: songs),
                onTap: () {
                  final album = sampleAlbums.firstWhere(
                    (a) => a.id == item.song.albumId,
                    orElse: () => sampleAlbums.first,
                  );
                  context.push('/album/${item.song.albumId}', extra: album);
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            featured.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? AppColors.primary
                    : AppColors.textMuted,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.song,
    required this.gradient,
    required this.label,
    required this.onPlay,
    required this.onTap,
  });

  final SongModel song;
  final List<Color> gradient;
  final String label;
  final VoidCallback onPlay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: AppRadius.circularXl,
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(AppRadius.xl),
                  bottomRight: Radius.circular(AppRadius.xl),
                ),
                child: Image.network(
                  song.imageUrl,
                  width: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.circularXl,
                gradient: LinearGradient(
                  colors: [
                    gradient.last.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: AppRadius.circularFull,
                    ),
                    child: Text(
                      label,
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                              ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color:
                                      Colors.white.withValues(alpha: 0.8),
                                ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FilledButton.icon(
                        onPressed: onPlay,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 0),
                          textStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: const Text('Play now'),
                      ),
                    ],
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
