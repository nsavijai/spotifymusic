import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../../core/network/api_exception.dart';
import 'music_repository_provider.dart';

// ─── Songs ────────────────────────────────────────────────────────────────────

final songsProvider = FutureProvider<List<SongModel>>((ref) async {
  return ref.watch(musicRepositoryProvider).getSongs();
});

final songProvider = FutureProvider.family<SongModel, String>((ref, id) async {
  return ref.watch(musicRepositoryProvider).getSong(id);
});

// ─── Albums ───────────────────────────────────────────────────────────────────

final albumsProvider = FutureProvider<List<AlbumModel>>((ref) async {
  return ref.watch(musicRepositoryProvider).getAlbums();
});

final albumProvider = FutureProvider.family<AlbumModel, String>((ref, id) async {
  return ref.watch(musicRepositoryProvider).getAlbum(id);
});

// ─── Artists ──────────────────────────────────────────────────────────────────

final artistsProvider = FutureProvider<List<ArtistModel>>((ref) async {
  return ref.watch(musicRepositoryProvider).getArtists();
});

final artistProvider = FutureProvider.family<ArtistModel, String>((ref, id) async {
  return ref.watch(musicRepositoryProvider).getArtist(id);
});

// ─── Playlists ────────────────────────────────────────────────────────────────

final playlistsProvider = FutureProvider<List<PlaylistModel>>((ref) async {
  return ref.watch(musicRepositoryProvider).getPlaylists();
});

// ─── Search ───────────────────────────────────────────────────────────────────

class SearchState {
  const SearchState({
    this.query = '',
    this.songs = const [],
    this.artists = const [],
    this.albums = const [],
    this.playlists = const [],
    this.isLoading = false,
    this.error,
  });

  final String query;
  final List<SongModel> songs;
  final List<ArtistModel> artists;
  final List<AlbumModel> albums;
  final List<PlaylistModel> playlists;
  final bool isLoading;
  final String? error;

  bool get hasResults =>
      songs.isNotEmpty ||
      artists.isNotEmpty ||
      albums.isNotEmpty ||
      playlists.isNotEmpty;

  SearchState copyWith({
    String? query,
    List<SongModel>? songs,
    List<ArtistModel>? artists,
    List<AlbumModel>? albums,
    List<PlaylistModel>? playlists,
    bool? isLoading,
    String? error,
  }) =>
      SearchState(
        query: query ?? this.query,
        songs: songs ?? this.songs,
        artists: artists ?? this.artists,
        albums: albums ?? this.albums,
        playlists: playlists ?? this.playlists,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._ref) : super(const SearchState());

  final Ref _ref;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }
    state = state.copyWith(query: query, isLoading: true, error: null);
    try {
      final result = await _ref.read(musicRepositoryProvider).search(query);
      final rawSongs = result['songs'] as List<dynamic>? ?? [];
      final rawArtists = result['artists'] as List<dynamic>? ?? [];
      final rawAlbums = result['albums'] as List<dynamic>? ?? [];
      final rawPlaylists = result['playlists'] as List<dynamic>? ?? [];

      state = state.copyWith(
        isLoading: false,
        songs: rawSongs
            .map((e) => SongModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        artists: rawArtists
            .map((e) => _artistFromJson(e as Map<String, dynamic>))
            .toList(),
        albums: rawAlbums
            .map((e) => _albumFromJson(e as Map<String, dynamic>))
            .toList(),
        playlists: rawPlaylists
            .map((e) => _playlistFromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'Search failed. Please try again.');
    }
  }

  void clear() => state = const SearchState();

  static ArtistModel _artistFromJson(Map<String, dynamic> j) => ArtistModel(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        imageUrl: j['image_url'] as String? ?? '',
        bannerUrl:
            j['banner_url'] as String? ?? j['image_url'] as String? ?? '',
        monthlyListeners: j['monthly_listeners'] as int? ?? 0,
        genre: j['genre'] as String? ?? '',
        biography: j['biography'] as String? ?? '',
        isVerified: j['is_verified'] as bool? ?? false,
      );

  static AlbumModel _albumFromJson(Map<String, dynamic> j) {
    final rawSongs = j['songs'] as List<dynamic>? ?? [];
    return AlbumModel(
      id: j['id'] as String? ?? '',
      title: j['title'] as String? ?? '',
      artist: j['artist'] as String? ?? '',
      artistId: j['artist_id'] as String? ?? '',
      imageUrl: j['image_url'] as String? ?? '',
      year: j['year'] as int? ?? 2024,
      description: j['description'] as String? ?? '',
      songs: rawSongs
          .map((e) => SongModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static PlaylistModel _playlistFromJson(Map<String, dynamic> j) {
    final rawSongs = j['songs'] as List<dynamic>? ?? [];
    return PlaylistModel(
      id: j['id'] as String? ?? '',
      title: j['title'] as String? ?? '',
      description: j['description'] as String? ?? '',
      imageUrl: j['image_url'] as String? ?? '',
      owner: j['owner'] as String? ?? 'VMusic',
      followers: j['followers'] as int? ?? 0,
      songs: rawSongs
          .map((e) => SongModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(ref),
);

// ─── Library ──────────────────────────────────────────────────────────────────

class LibraryState {
  const LibraryState({
    this.likedSongs = const [],
    this.playlists = const [],
    this.albums = const [],
    this.recentlyPlayed = const [],
    this.isLoading = false,
    this.error,
  });

  final List<SongModel> likedSongs;
  final List<PlaylistModel> playlists;
  final List<AlbumModel> albums;
  final List<SongModel> recentlyPlayed;
  final bool isLoading;
  final String? error;

  LibraryState copyWith({
    List<SongModel>? likedSongs,
    List<PlaylistModel>? playlists,
    List<AlbumModel>? albums,
    List<SongModel>? recentlyPlayed,
    bool? isLoading,
    String? error,
  }) =>
      LibraryState(
        likedSongs: likedSongs ?? this.likedSongs,
        playlists: playlists ?? this.playlists,
        albums: albums ?? this.albums,
        recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  LibraryNotifier(this._ref) : super(const LibraryState());

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _ref.read(musicRepositoryProvider).getLibrary();
      final rawLiked = data['liked_songs'] as List<dynamic>? ?? [];
      final rawPlaylists = data['playlists'] as List<dynamic>? ?? [];
      final rawAlbums = data['albums'] as List<dynamic>? ?? [];
      final rawRecent = data['recently_played'] as List<dynamic>? ?? [];

      state = state.copyWith(
        isLoading: false,
        likedSongs: rawLiked
            .map((e) => SongModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        playlists: rawPlaylists
            .map((e) => _playlistFromJson(e as Map<String, dynamic>))
            .toList(),
        albums: rawAlbums
            .map((e) => _albumFromJson(e as Map<String, dynamic>))
            .toList(),
        recentlyPlayed: rawRecent
            .map((e) => SongModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load library.');
    }
  }

  void toggleLike(SongModel song) {
    final liked = List<SongModel>.from(state.likedSongs);
    final idx = liked.indexWhere((s) => s.id == song.id);
    if (idx >= 0) {
      liked.removeAt(idx);
      _ref.read(musicRepositoryProvider).unlikeSong(song.id);
    } else {
      liked.insert(0, song.copyWith(isFavorite: true));
      _ref.read(musicRepositoryProvider).likeSong(song.id);
    }
    state = state.copyWith(likedSongs: liked);
  }

  bool isLiked(String songId) => state.likedSongs.any((s) => s.id == songId);

  static PlaylistModel _playlistFromJson(Map<String, dynamic> j) {
    final rawSongs = j['songs'] as List<dynamic>? ?? [];
    return PlaylistModel(
      id: j['id'] as String? ?? '',
      title: j['title'] as String? ?? '',
      description: j['description'] as String? ?? '',
      imageUrl: j['image_url'] as String? ?? '',
      owner: j['owner'] as String? ?? 'VMusic',
      followers: j['followers'] as int? ?? 0,
      isPublic: j['is_public'] as bool? ?? true,
      isOwned: j['is_owned'] as bool? ?? false,
      songs: rawSongs
          .map((e) => SongModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static AlbumModel _albumFromJson(Map<String, dynamic> j) {
    final rawSongs = j['songs'] as List<dynamic>? ?? [];
    return AlbumModel(
      id: j['id'] as String? ?? '',
      title: j['title'] as String? ?? '',
      artist: j['artist'] as String? ?? '',
      artistId: j['artist_id'] as String? ?? '',
      imageUrl: j['image_url'] as String? ?? '',
      year: j['year'] as int? ?? 2024,
      description: j['description'] as String? ?? '',
      songs: rawSongs
          .map((e) => SongModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

final libraryProvider =
    StateNotifierProvider<LibraryNotifier, LibraryState>(
  (ref) => LibraryNotifier(ref),
);

// ─── History ──────────────────────────────────────────────────────────────────

final historyProvider = FutureProvider<List<SongModel>>((ref) async {
  return ref.watch(musicRepositoryProvider).getHistory();
});

// ─── Genres ───────────────────────────────────────────────────────────────────

final genresProvider = FutureProvider<List<GenreModel>>((ref) async {
  return ref.watch(musicRepositoryProvider).getGenres();
});
