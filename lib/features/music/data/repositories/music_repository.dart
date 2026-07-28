import 'package:dio/dio.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';

class MusicRepository {
  const MusicRepository(this._dio);

  final Dio _dio;

  // ─── Songs ────────────────────────────────────────────────────────────────

  Future<List<SongModel>> getSongs() async {
    try {
      final res = await _dio.get(ApiEndpoints.songs);
      final list = res.data as List<dynamic>;
      return list
          .map((e) => SongModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to load songs');
    }
  }

  Future<SongModel> getSong(String id) async {
    try {
      final res = await _dio.get('${ApiEndpoints.songs}/$id');
      final data = _unwrap(res.data);
      return SongModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to load song');
    }
  }

  // ─── Albums ───────────────────────────────────────────────────────────────

  Future<List<AlbumModel>> getAlbums() async {
    try {
      final res = await _dio.get(ApiEndpoints.albums);
      final list = _unwrap(res.data) as List<dynamic>;
      return list
          .map((e) => _albumFromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to load albums');
    }
  }

  Future<AlbumModel> getAlbum(String id) async {
    try {
      final res = await _dio.get('${ApiEndpoints.albums}/$id');
      return _albumFromJson(_unwrap(res.data) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to load album');
    }
  }

  // ─── Artists ──────────────────────────────────────────────────────────────

  Future<List<ArtistModel>> getArtists() async {
    try {
      final res = await _dio.get(ApiEndpoints.artists);
      final list = _unwrap(res.data) as List<dynamic>;
      return list
          .map((e) => _artistFromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to load artists');
    }
  }

  Future<ArtistModel> getArtist(String id) async {
    try {
      final res = await _dio.get('${ApiEndpoints.artists}/$id');
      return _artistFromJson(_unwrap(res.data) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to load artist');
    }
  }

  // ─── Playlists ────────────────────────────────────────────────────────────

  Future<List<PlaylistModel>> getPlaylists() async {
    try {
      final res = await _dio.get(ApiEndpoints.playlists);
      final list = _unwrap(res.data) as List<dynamic>;
      return list
          .map((e) => _playlistFromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to load playlists');
    }
  }

  Future<PlaylistModel> createPlaylist({
    required String title,
    required String description,
    required bool isPublic,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.playlists,
        data: {'title': title, 'description': description, 'is_public': isPublic},
      );
      return _playlistFromJson(_unwrap(res.data) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to create playlist');
    }
  }

  Future<PlaylistModel> updatePlaylist(
    String id, {
    required String title,
    required String description,
  }) async {
    try {
      final res = await _dio.put(
        '${ApiEndpoints.playlists}/$id',
        data: {'title': title, 'description': description},
      );
      return _playlistFromJson(_unwrap(res.data) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to update playlist');
    }
  }

  Future<void> deletePlaylist(String id) async {
    try {
      await _dio.delete('${ApiEndpoints.playlists}/$id');
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to delete playlist');
    }
  }

  // ─── Library ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getLibrary() async {
    try {
      final res = await _dio.get(ApiEndpoints.library);
      return _unwrap(res.data) as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to load library');
    }
  }

  Future<void> likeSong(String songId) async {
    try {
      await _dio.post('${ApiEndpoints.library}/like', data: {'song_id': songId});
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to like song');
    }
  }

  Future<void> unlikeSong(String songId) async {
    try {
      await _dio.delete('${ApiEndpoints.library}/like/$songId');
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to unlike song');
    }
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> search(String query) async {
    try {
      final res = await _dio.get(ApiEndpoints.search, queryParameters: {'q': query});
      return _unwrap(res.data) as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Search failed');
    }
  }

  // ─── History ──────────────────────────────────────────────────────────────

  Future<List<SongModel>> getHistory() async {
    try {
      final res = await _dio.get(ApiEndpoints.history);
      final list = _unwrap(res.data) as List<dynamic>;
      return list
          .map((e) => SongModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to load history');
    }
  }

  Future<void> recordHistory(String songId) async {
    try {
      await _dio.post(ApiEndpoints.history, data: {'song_id': songId});
    } catch (_) {
      // Non-critical — swallow silently
    }
  }

  // ─── Genres ───────────────────────────────────────────────────────────────

  Future<List<GenreModel>> getGenres() async {
    try {
      final res = await _dio.get(ApiEndpoints.genres);
      final list = _unwrap(res.data) as List<dynamic>;
      return list.map((e) {
        final j = e as Map<String, dynamic>;
        return GenreModel(
          id: j['id'] as String? ?? '',
          name: j['name'] as String? ?? '',
          imageUrl: j['image_url'] as String? ?? '',
          color: j['color'] as int? ?? 0xFF1ED760,
        );
      }).toList();
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Failed to load genres');
    }
  }

  // ─── Stream URL ───────────────────────────────────────────────────────────

  /// Returns the direct audio URL for a song.
  /// Prefers the song's own audioUrl, falls back to the stream endpoint.
  String getStreamUrl(SongModel song) {
    if (song.audioUrl != null && song.audioUrl!.isNotEmpty) {
      return song.audioUrl!;
    }
    return '${ApiEndpoints.baseUrl}/api/v1/stream/${song.id}';
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Unwraps `{ success, message, data }` envelope if present,
  /// otherwise returns the raw value (e.g. plain list from /songs).
  dynamic _unwrap(dynamic raw) {
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      return raw['data'];
    }
    return raw;
  }

  AlbumModel _albumFromJson(Map<String, dynamic> j) {
    final rawSongs = j['songs'] as List<dynamic>? ?? [];
    return AlbumModel(
      id: j['id'] as String,
      title: j['title'] as String,
      artist: j['artist'] as String,
      artistId: j['artist_id'] as String,
      imageUrl: j['image_url'] as String,
      year: j['year'] as int,
      description: j['description'] as String? ?? '',
      genre: j['genre'] as String? ?? '',
      songs: rawSongs
          .map((s) => SongModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  ArtistModel _artistFromJson(Map<String, dynamic> j) {
    final rawSongs = j['popular_songs'] as List<dynamic>? ?? [];
    final rawAlbums = j['albums'] as List<dynamic>? ?? [];
    return ArtistModel(
      id: j['id'] as String,
      name: j['name'] as String,
      imageUrl: j['image_url'] as String,
      bannerUrl: j['banner_url'] as String? ?? j['image_url'] as String,
      monthlyListeners: j['monthly_listeners'] as int? ?? 0,
      genre: j['genre'] as String? ?? '',
      biography: j['biography'] as String? ?? '',
      isVerified: j['is_verified'] as bool? ?? false,
      popularSongs: rawSongs
          .map((s) => SongModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      albums: rawAlbums.map((a) => _albumFromJson(a as Map<String, dynamic>)).toList(),
    );
  }

  PlaylistModel _playlistFromJson(Map<String, dynamic> j) {
    final rawSongs = j['songs'] as List<dynamic>? ?? [];
    return PlaylistModel(
      id: j['id'] as String,
      title: j['title'] as String,
      description: j['description'] as String? ?? '',
      imageUrl: j['image_url'] as String,
      owner: j['owner'] as String? ?? 'VMusic',
      followers: j['followers'] as int? ?? 0,
      isPublic: j['is_public'] as bool? ?? true,
      isOwned: j['is_owned'] as bool? ?? false,
      songs: rawSongs
          .map((s) => SongModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
