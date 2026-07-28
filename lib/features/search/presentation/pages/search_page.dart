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
import '../../../home/presentation/widgets/track_tile.dart';
import '../../../music/data/providers/music_providers.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String v) {
    if (v.isEmpty) {
      ref.read(searchProvider.notifier).clear();
    } else {
      ref.read(searchProvider.notifier).search(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final hasQuery = searchState.query.isNotEmpty;

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
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.circularFull,
                        border: Border.all(
                          color: _isFocused
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        focusNode: _focusNode,
                        onChanged: _onQueryChanged,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Artists, songs, podcasts',
                          prefixIcon: const Icon(AppIcons.search),
                          suffixIcon: hasQuery
                              ? IconButton(
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    ref
                                        .read(searchProvider.notifier)
                                        .clear();
                                  },
                                  icon: const Icon(AppIcons.close, size: 18),
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  if (_isFocused || hasQuery) ...[
                    const SizedBox(width: AppSpacing.sm),
                    TextButton(
                      onPressed: () {
                        _searchCtrl.clear();
                        ref.read(searchProvider.notifier).clear();
                        _focusNode.unfocus();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: hasQuery
                  ? _SearchResults(state: searchState)
                  : const _SearchBrowse(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Browse (no query) ────────────────────────────────────────────────────────

class _SearchBrowse extends ConsumerWidget {
  const _SearchBrowse();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresAsync = ref.watch(genresProvider);
    final genres = genresAsync.valueOrNull ?? sampleGenres;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('Recent searches',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...recentSearches.asMap().entries.map(
              (e) => ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 0),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(AppIcons.history,
                      color: AppColors.textMuted, size: 20),
                ),
                title: Text(e.value,
                    style: Theme.of(context).textTheme.bodyLarge),
                trailing: const Icon(AppIcons.close,
                    color: AppColors.textMuted, size: 18),
              )
                  .animate(delay: (e.key * 50).ms)
                  .fadeIn()
                  .slideX(begin: -0.1, end: 0),
            ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'Browse all'),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemCount: genres.length,
            itemBuilder: (_, i) => _GenreCard(genre: genres[i])
                .animate(delay: (i * 60).ms)
                .fadeIn()
                .scale(begin: const Offset(0.9, 0.9)),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'Trending searches'),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: trendingSearches
                .map(
                  (t) => Chip(
                    label: Text(t),
                    avatar: const Icon(AppIcons.trending,
                        size: 14, color: AppColors.primary),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}

// ─── Genre Card ───────────────────────────────────────────────────────────────

class _GenreCard extends StatelessWidget {
  const _GenreCard({required this.genre});

  final GenreModel genre;

  @override
  Widget build(BuildContext context) {
    final color = Color(genre.color);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(
            url: genre.imageUrl,
            width: double.infinity,
            height: double.infinity,
            borderRadius: 0,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.85),
                  color.withValues(alpha: 0.4),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                genre.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Results ───────────────────────────────────────────────────────────

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.search, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(state.error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    if (!state.hasResults) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.search, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text('No results for "${state.query}"',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text('Try different keywords',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Songs'),
              Tab(text: 'Artists'),
              Tab(text: 'Albums'),
              Tab(text: 'Playlists'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView.builder(
                  itemCount: state.songs.length,
                  itemBuilder: (_, i) =>
                      TrackTile(song: state.songs[i], queue: state.songs),
                ),
                ListView.builder(
                  itemCount: state.artists.length,
                  itemBuilder: (_, i) =>
                      _ArtistResultTile(artist: state.artists[i]),
                ),
                ListView.builder(
                  itemCount: state.albums.length,
                  itemBuilder: (_, i) =>
                      _AlbumResultTile(album: state.albums[i]),
                ),
                ListView.builder(
                  itemCount: state.playlists.length,
                  itemBuilder: (_, i) =>
                      _PlaylistResultTile(playlist: state.playlists[i]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistResultTile extends StatelessWidget {
  const _ArtistResultTile({required this.artist});

  final ArtistModel artist;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      onTap: () => context.push('/artist/${artist.id}', extra: artist),
      leading: AppNetworkImage(
          url: artist.imageUrl, width: 48, height: 48, isCircle: true),
      title:
          Text(artist.name, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text('${artist.formattedListeners} monthly listeners',
          style: Theme.of(context).textTheme.bodySmall),
      trailing:
          const Icon(AppIcons.chevronRight, color: AppColors.textMuted),
    );
  }
}

class _AlbumResultTile extends StatelessWidget {
  const _AlbumResultTile({required this.album});

  final AlbumModel album;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      onTap: () => context.push('/album/${album.id}', extra: album),
      leading: AppNetworkImage(
          url: album.imageUrl, width: 48, height: 48, borderRadius: 6),
      title:
          Text(album.title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text('${album.artist} · ${album.year}',
          style: Theme.of(context).textTheme.bodySmall),
      trailing:
          const Icon(AppIcons.chevronRight, color: AppColors.textMuted),
    );
  }
}

class _PlaylistResultTile extends StatelessWidget {
  const _PlaylistResultTile({required this.playlist});

  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      onTap: () =>
          context.push('/playlist/${playlist.id}', extra: playlist),
      leading: AppNetworkImage(
          url: playlist.imageUrl, width: 48, height: 48, borderRadius: 6),
      title: Text(playlist.title,
          style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text('${playlist.songs.length} songs · ${playlist.owner}',
          style: Theme.of(context).textTheme.bodySmall),
      trailing:
          const Icon(AppIcons.chevronRight, color: AppColors.textMuted),
    );
  }
}
