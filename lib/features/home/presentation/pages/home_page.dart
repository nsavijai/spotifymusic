import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../widgets/section_header.dart';
import '../../../music/data/providers/music_providers.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../widgets/album_card.dart';
import '../widgets/artist_card.dart';
import '../widgets/featured_banner.dart';
import '../widgets/genre_chip.dart';
import '../widgets/playlist_card.dart';
import '../widgets/track_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);
    final albumsAsync = ref.watch(albumsProvider);
    final artistsAsync = ref.watch(artistsProvider);
    final playlistsAsync = ref.watch(playlistsProvider);
    final genresAsync = ref.watch(genresProvider);

    // Resolve with fallback to dummy data
    final songs = songsAsync.valueOrNull ?? allSongs;
    final albums = albumsAsync.valueOrNull ?? sampleAlbums;
    final artists = artistsAsync.valueOrNull ?? sampleArtists;
    final playlists = playlistsAsync.valueOrNull ?? samplePlaylists;
    final genres = genresAsync.valueOrNull ?? sampleGenres;

    final recentSongs = songs.take(5).toList();
    final trendingSongsList = songs.reversed.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _HomeAppBar(greeting: _greeting()),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FeaturedBanner()
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: 'Continue listening',
                  subtitle: 'Pick up where you left off',
                  onSeeAll: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                _QuickPicksGrid(songs: recentSongs),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: 'Popular albums',
                  subtitle: 'Fresh fits for your mood',
                  onSeeAll: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 220,
                  child: albumsAsync.when(
                    loading: () => const _HorizontalSkeleton(count: 4, width: 160),
                    error: (_, __) => _AlbumList(albums: albums),
                    data: (_) => _AlbumList(albums: albums),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: 'Made for you',
                  subtitle: 'Curated to match your taste',
                  onSeeAll: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 200,
                  child: playlistsAsync.when(
                    loading: () => const _HorizontalSkeleton(count: 4, width: 150),
                    error: (_, __) => _PlaylistList(playlists: playlists),
                    data: (_) => _PlaylistList(playlists: playlists),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: 'Trending now',
                  subtitle: 'What everyone is listening to',
                  onSeeAll: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
                ...trendingSongsList.asMap().entries.map(
                      (e) => TrackTile(
                        song: e.value,
                        index: e.key + 1,
                        showIndex: true,
                        queue: trendingSongsList,
                      ),
                    ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: 'Artists you love',
                  subtitle: 'Now playing in your orbit',
                  onSeeAll: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 160,
                  child: artistsAsync.when(
                    loading: () => const _HorizontalSkeleton(count: 5, width: 110),
                    error: (_, __) => _ArtistList(artists: artists),
                    data: (_) => _ArtistList(artists: artists),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: 'Browse genres',
                  subtitle: 'Explore a new mood',
                  onSeeAll: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children:
                        genres.map((g) => GenreChip(genre: g)).toList(),
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

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _HomeAppBar extends ConsumerWidget {
  const _HomeAppBar({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.background,
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting,
                    style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  currentUser.name.split(' ').first,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(AppIcons.notifications),
          ),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(currentUser.avatarUrl),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Picks ──────────────────────────────────────────────────────────────

class _QuickPicksGrid extends ConsumerWidget {
  const _QuickPicksGrid({required this.songs});

  final List<SongModel> songs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = songs.take(6).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.5,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _QuickPickItem(song: items[i], queue: songs),
      ),
    );
  }
}

class _QuickPickItem extends ConsumerWidget {
  const _QuickPickItem({required this.song, required this.queue});

  final SongModel song;
  final List<SongModel> queue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => ref
            .read(playerProvider.notifier)
            .playSong(song, queue: queue),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
              child: Image.network(
                song.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.surface,
                  child: const Icon(Icons.music_note_rounded,
                      color: AppColors.textMuted, size: 20),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                song.title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}

// ─── List helpers ─────────────────────────────────────────────────────────────

class _AlbumList extends StatelessWidget {
  const _AlbumList({required this.albums});
  final List<AlbumModel> albums;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      scrollDirection: Axis.horizontal,
      itemCount: albums.length,
      itemBuilder: (_, i) => AlbumCard(
        album: albums[i],
        onTap: () =>
            context.push('/album/${albums[i].id}', extra: albums[i]),
      ),
    );
  }
}

class _PlaylistList extends StatelessWidget {
  const _PlaylistList({required this.playlists});
  final List<PlaylistModel> playlists;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      scrollDirection: Axis.horizontal,
      itemCount: playlists.length,
      itemBuilder: (_, i) => PlaylistCard(
        playlist: playlists[i],
        onTap: () => context.push('/playlist/${playlists[i].id}',
            extra: playlists[i]),
      ),
    );
  }
}

class _ArtistList extends StatelessWidget {
  const _ArtistList({required this.artists});
  final List<ArtistModel> artists;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      scrollDirection: Axis.horizontal,
      itemCount: artists.length,
      itemBuilder: (_, i) => ArtistCard(
        artist: artists[i],
        onTap: () => context.push('/artist/${artists[i].id}',
            extra: artists[i]),
      ),
    );
  }
}

class _HorizontalSkeleton extends StatelessWidget {
  const _HorizontalSkeleton({required this.count, required this.width});
  final int count;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      scrollDirection: Axis.horizontal,
      itemCount: count,
      itemBuilder: (_, __) => Container(
        width: width,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
