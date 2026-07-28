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
import '../../../../core/widgets/empty_state.dart';
import '../../../home/presentation/widgets/track_tile.dart';
import '../../../music/data/providers/music_providers.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    // Load library from backend
    Future.microtask(() => ref.read(libraryProvider.notifier).load());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
              child: Row(
                children: [
                  Text('Your Library',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.push('/create-playlist'),
                    icon: const Icon(AppIcons.addCircle,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: 'Playlists'),
                Tab(text: 'Albums'),
                Tab(text: 'Artists'),
                Tab(text: 'Liked'),
                Tab(text: 'Downloads'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: const [
                  _PlaylistsTab(),
                  _AlbumsTab(),
                  _ArtistsTab(),
                  _LikedSongsTab(),
                  _DownloadsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Playlists Tab ────────────────────────────────────────────────────────────

class _PlaylistsTab extends ConsumerWidget {
  const _PlaylistsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);

    if (library.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    // Merge backend playlists with dummy fallback
    final playlists =
        library.playlists.isNotEmpty ? library.playlists : samplePlaylists;
    final owned = playlists.where((p) => p.isOwned).toList();
    final saved = playlists.where((p) => !p.isOwned).toList();

    return ListView(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 120),
      children: [
        if (owned.isNotEmpty) ...[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('My playlists',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textMuted,
                    )),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...owned.asMap().entries.map(
                (e) => _PlaylistTile(playlist: e.value)
                    .animate(delay: (e.key * 50).ms)
                    .fadeIn()
                    .slideX(begin: -0.05, end: 0),
              ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (saved.isNotEmpty) ...[
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text('Saved playlists',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textMuted,
                    )),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...saved.asMap().entries.map(
                (e) => _PlaylistTile(playlist: e.value)
                    .animate(
                        delay: ((owned.length + e.key) * 50).ms)
                    .fadeIn()
                    .slideX(begin: -0.05, end: 0),
              ),
        ],
      ],
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({required this.playlist});

  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      onTap: () =>
          context.push('/playlist/${playlist.id}', extra: playlist),
      leading: AppNetworkImage(
          url: playlist.imageUrl,
          width: 52,
          height: 52,
          borderRadius: 8),
      title: Text(playlist.title,
          style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(
        '${playlist.songs.length} songs · ${playlist.owner}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: playlist.isOwned
          ? const Icon(AppIcons.more,
              color: AppColors.textMuted, size: 20)
          : null,
    );
  }
}

// ─── Albums Tab ───────────────────────────────────────────────────────────────

class _AlbumsTab extends ConsumerWidget {
  const _AlbumsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final albums =
        library.albums.isNotEmpty ? library.albums : sampleAlbums;

    return ListView.builder(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 120),
      itemCount: albums.length,
      itemBuilder: (_, i) => ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        onTap: () =>
            context.push('/album/${albums[i].id}', extra: albums[i]),
        leading: AppNetworkImage(
            url: albums[i].imageUrl,
            width: 52,
            height: 52,
            borderRadius: 8),
        title: Text(albums[i].title,
            style: Theme.of(context).textTheme.titleSmall),
        subtitle: Text(
          '${albums[i].artist} · ${albums[i].year}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: const Icon(AppIcons.chevronRight,
            color: AppColors.textMuted, size: 18),
      )
          .animate(delay: (i * 50).ms)
          .fadeIn()
          .slideX(begin: -0.05, end: 0),
    );
  }
}

// ─── Artists Tab ──────────────────────────────────────────────────────────────

class _ArtistsTab extends ConsumerWidget {
  const _ArtistsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistsAsync = ref.watch(artistsProvider);
    final artists = artistsAsync.valueOrNull ?? sampleArtists;

    return ListView.builder(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 120),
      itemCount: artists.length,
      itemBuilder: (_, i) => ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        onTap: () => context.push('/artist/${artists[i].id}',
            extra: artists[i]),
        leading: AppNetworkImage(
            url: artists[i].imageUrl,
            width: 52,
            height: 52,
            isCircle: true),
        title: Text(artists[i].name,
            style: Theme.of(context).textTheme.titleSmall),
        subtitle: Text(
          '${artists[i].formattedListeners} monthly listeners',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: const Icon(AppIcons.chevronRight,
            color: AppColors.textMuted, size: 18),
      )
          .animate(delay: (i * 50).ms)
          .fadeIn()
          .slideX(begin: -0.05, end: 0),
    );
  }
}

// ─── Liked Songs Tab ──────────────────────────────────────────────────────────

class _LikedSongsTab extends ConsumerWidget {
  const _LikedSongsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final liked =
        library.likedSongs.isNotEmpty ? library.likedSongs : likedSongs;

    if (liked.isEmpty) {
      return const EmptyState(
        icon: AppIcons.favoriteBorder,
        title: 'No liked songs yet',
        subtitle: 'Songs you like will appear here',
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 120),
      children: [
        Container(
          margin:
              const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              const Icon(AppIcons.favorite,
                  color: Colors.white, size: 32),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Liked Songs',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white)),
                  Text('${liked.length} songs',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70)),
                ],
              ),
              const Spacer(),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(AppIcons.play,
                    color: Colors.black, size: 28),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...liked.map((s) => TrackTile(song: s, queue: liked)),
      ],
    );
  }
}

// ─── Downloads Tab ────────────────────────────────────────────────────────────

class _DownloadsTab extends StatelessWidget {
  const _DownloadsTab();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: AppIcons.download,
      title: 'No downloads yet',
      subtitle: 'Download songs to listen offline',
      actionLabel: 'Find music to download',
    );
  }
}
