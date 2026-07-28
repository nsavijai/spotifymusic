// ─── Models ───────────────────────────────────────────────────────────────────

class SongModel {
  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.album,
    required this.albumId,
    required this.imageUrl,
    required this.durationSeconds,
    required this.year,
    this.audioUrl,
    this.isFavorite = false,
    this.isDownloaded = false,
    this.playCount = 0,
    this.lyrics,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      artistId: json['artist_id'] as String,
      album: json['album'] as String,
      albumId: json['album_id'] as String,
      imageUrl: json['image_url'] as String,
      audioUrl: json['audio_url'] as String?,
      durationSeconds: json['duration_seconds'] as int,
      year: json['year'] as int,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isDownloaded: false,
      playCount: json['play_count'] as int? ?? 0,
      lyrics: json['lyrics'] as String?,
    );
  }

  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String album;
  final String albumId;
  final String imageUrl;
  final String? audioUrl;
  final int durationSeconds;
  final int year;
  final bool isFavorite;
  final bool isDownloaded;
  final int playCount;
  final String? lyrics;

  String get duration {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  SongModel copyWith({bool? isFavorite, bool? isDownloaded, String? audioUrl}) =>
      SongModel(
        id: id,
        title: title,
        artist: artist,
        artistId: artistId,
        album: album,
        albumId: albumId,
        imageUrl: imageUrl,
        audioUrl: audioUrl ?? this.audioUrl,
        durationSeconds: durationSeconds,
        year: year,
        isFavorite: isFavorite ?? this.isFavorite,
        isDownloaded: isDownloaded ?? this.isDownloaded,
        playCount: playCount,
        lyrics: lyrics,
      );
}

class AlbumModel {
  const AlbumModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.imageUrl,
    required this.year,
    required this.description,
    required this.songs,
    this.genre = '',
  });

  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String imageUrl;
  final int year;
  final String description;
  final List<SongModel> songs;
  final String genre;

  int get totalDurationSeconds =>
      songs.fold(0, (sum, s) => sum + s.durationSeconds);

  String get totalDuration {
    final total = totalDurationSeconds;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

class ArtistModel {
  const ArtistModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.bannerUrl,
    required this.monthlyListeners,
    required this.genre,
    required this.biography,
    required this.isVerified,
    this.popularSongs = const [],
    this.albums = const [],
  });

  final String id;
  final String name;
  final String imageUrl;
  final String bannerUrl;
  final int monthlyListeners;
  final String genre;
  final String biography;
  final bool isVerified;
  final List<SongModel> popularSongs;
  final List<AlbumModel> albums;

  String get formattedListeners {
    if (monthlyListeners >= 1000000) {
      return '${(monthlyListeners / 1000000).toStringAsFixed(1)}M';
    }
    if (monthlyListeners >= 1000) {
      return '${(monthlyListeners / 1000).toStringAsFixed(1)}K';
    }
    return monthlyListeners.toString();
  }
}

class PlaylistModel {
  const PlaylistModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.owner,
    required this.followers,
    required this.songs,
    this.isPublic = true,
    this.isOwned = false,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String owner;
  final int followers;
  final List<SongModel> songs;
  final bool isPublic;
  final bool isOwned;

  String get formattedFollowers {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    }
    if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }

  int get totalDurationSeconds =>
      songs.fold(0, (sum, s) => sum + s.durationSeconds);
}

class GenreModel {
  const GenreModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.color,
  });

  final String id;
  final String name;
  final String imageUrl;
  final int color;
}

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.isPremium,
    required this.followersCount,
    required this.followingCount,
    this.bio = '',
  });

  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final bool isPremium;
  final int followersCount;
  final int followingCount;
  final String bio;
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────

const _song1 = SongModel(
  id: 's1',
  title: 'Midnight Drive',
  artist: 'Luna Vale',
  artistId: 'a1',
  album: 'Velvet Phase',
  albumId: 'al1',
  imageUrl:
      'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600&q=80',
  durationSeconds: 204,
  year: 2024,
  isFavorite: true,
  playCount: 4200000,
  lyrics: '''[Verse 1]
City lights below me
Neon signs that glow free
Driving through the midnight air
Wind is in my hair

[Chorus]
Midnight drive, feel alive
Through the city we survive
Midnight drive, you and I
Underneath the velvet sky''',
);

const _song2 = SongModel(
  id: 's2',
  title: 'Neon Skyline',
  artist: 'Aria North',
  artistId: 'a2',
  album: 'Future Bloom',
  albumId: 'al2',
  imageUrl:
      'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=600&q=80',
  durationSeconds: 241,
  year: 2024,
  playCount: 2800000,
);

const _song3 = SongModel(
  id: 's3',
  title: 'Velvet Echo',
  artist: 'Milo Hart',
  artistId: 'a3',
  album: 'Afterglow',
  albumId: 'al3',
  imageUrl:
      'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=600&q=80',
  durationSeconds: 178,
  year: 2023,
  isFavorite: true,
  playCount: 5100000,
);

const _song4 = SongModel(
  id: 's4',
  title: 'Golden Hour',
  artist: 'Nora Lane',
  artistId: 'a4',
  album: 'Golden Hour',
  albumId: 'al4',
  imageUrl:
      'https://images.unsplash.com/photo-1498036882173-b41c28a8ba34?w=600&q=80',
  durationSeconds: 198,
  year: 2024,
  playCount: 3600000,
);

const _song5 = SongModel(
  id: 's5',
  title: 'Electric Soul',
  artist: 'Luna Vale',
  artistId: 'a1',
  album: 'Velvet Phase',
  albumId: 'al1',
  imageUrl:
      'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600&q=80',
  durationSeconds: 223,
  year: 2024,
  isFavorite: true,
  playCount: 1900000,
);

const _song6 = SongModel(
  id: 's6',
  title: 'Starfall',
  artist: 'Aria North',
  artistId: 'a2',
  album: 'Future Bloom',
  albumId: 'al2',
  imageUrl:
      'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&q=80',
  durationSeconds: 267,
  year: 2024,
  playCount: 2200000,
);

const _song7 = SongModel(
  id: 's7',
  title: 'Phantom Waves',
  artist: 'Milo Hart',
  artistId: 'a3',
  album: 'Afterglow',
  albumId: 'al3',
  imageUrl:
      'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&q=80',
  durationSeconds: 195,
  year: 2023,
  playCount: 3100000,
);

const _song8 = SongModel(
  id: 's8',
  title: 'Sunrise Protocol',
  artist: 'Nora Lane',
  artistId: 'a4',
  album: 'Golden Hour',
  albumId: 'al4',
  imageUrl:
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80',
  durationSeconds: 312,
  year: 2024,
  playCount: 1500000,
);

const _song9 = SongModel(
  id: 's9',
  title: 'Cascade',
  artist: 'Luna Vale',
  artistId: 'a1',
  album: 'Velvet Phase',
  albumId: 'al1',
  imageUrl:
      'https://images.unsplash.com/photo-1487180144351-b8472da7d491?w=600&q=80',
  durationSeconds: 189,
  year: 2024,
  playCount: 2700000,
);

const _song10 = SongModel(
  id: 's10',
  title: 'Hollow Moon',
  artist: 'Aria North',
  artistId: 'a2',
  album: 'Future Bloom',
  albumId: 'al2',
  imageUrl:
      'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=600&q=80',
  durationSeconds: 234,
  year: 2024,
  playCount: 4800000,
);

// Albums
final sampleAlbums = <AlbumModel>[
  const AlbumModel(
    id: 'al1',
    title: 'Velvet Phase',
    artist: 'Luna Vale',
    artistId: 'a1',
    imageUrl:
        'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=600&q=80',
    year: 2024,
    description:
        'A midnight collection of cinematic synth-pop that blurs the line between dream and reality.',
    genre: 'Synth Pop',
    songs: [_song1, _song5, _song9],
  ),
  const AlbumModel(
    id: 'al2',
    title: 'Future Bloom',
    artist: 'Aria North',
    artistId: 'a2',
    imageUrl:
        'https://images.unsplash.com/photo-1487180144351-b8472da7d491?w=600&q=80',
    year: 2024,
    description:
        'Bright melodies with a powerful, electronic pulse. A journey into tomorrow.',
    genre: 'Electronic',
    songs: [_song2, _song6, _song10],
  ),
  const AlbumModel(
    id: 'al3',
    title: 'Afterglow',
    artist: 'Milo Hart',
    artistId: 'a3',
    imageUrl:
        'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=600&q=80',
    year: 2023,
    description: 'Warm rhythms and late-night soul. An intimate acoustic journey.',
    genre: 'Indie Soul',
    songs: [_song3, _song7],
  ),
  const AlbumModel(
    id: 'al4',
    title: 'Golden Hour',
    artist: 'Nora Lane',
    artistId: 'a4',
    imageUrl:
        'https://images.unsplash.com/photo-1498036882173-b41c28a8ba34?w=600&q=80',
    year: 2024,
    description: 'Chasing the light at the edge of day. Ambient pop at its finest.',
    genre: 'Ambient Pop',
    songs: [_song4, _song8],
  ),
];

// Artists
final sampleArtists = <ArtistModel>[
  ArtistModel(
    id: 'a1',
    name: 'Luna Vale',
    imageUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&q=80',
    bannerUrl:
        'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=1200&q=80',
    monthlyListeners: 18200000,
    genre: 'Synth Pop',
    biography:
        'Luna Vale is a Berlin-based synth-pop artist known for her ethereal vocals and cinematic soundscapes. Her debut album "Velvet Phase" catapulted her to international fame in 2024.',
    isVerified: true,
    popularSongs: [_song1, _song5, _song9],
    albums: [sampleAlbums[0]],
  ),
  ArtistModel(
    id: 'a2',
    name: 'Aria North',
    imageUrl:
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&q=80',
    bannerUrl:
        'https://images.unsplash.com/photo-1487180144351-b8472da7d491?w=1200&q=80',
    monthlyListeners: 9400000,
    genre: 'Electronic',
    biography:
        'Aria North blends electronic production with soulful songwriting. Based in London, she has collaborated with some of the biggest names in the industry.',
    isVerified: true,
    popularSongs: [_song2, _song6, _song10],
    albums: [sampleAlbums[1]],
  ),
  ArtistModel(
    id: 'a3',
    name: 'Milo Hart',
    imageUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600&q=80',
    bannerUrl:
        'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=1200&q=80',
    monthlyListeners: 12100000,
    genre: 'Indie Soul',
    biography:
        'Milo Hart is a multi-instrumentalist and producer from Nashville. His warm, organic sound has earned him a devoted global following.',
    isVerified: true,
    popularSongs: [_song3, _song7],
    albums: [sampleAlbums[2]],
  ),
  ArtistModel(
    id: 'a4',
    name: 'Nora Lane',
    imageUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=600&q=80',
    bannerUrl:
        'https://images.unsplash.com/photo-1498036882173-b41c28a8ba34?w=1200&q=80',
    monthlyListeners: 7600000,
    genre: 'Ambient Pop',
    biography:
        'Nora Lane creates immersive ambient pop landscapes that feel like a warm sunset. Her music has been featured in major films and TV series worldwide.',
    isVerified: false,
    popularSongs: [_song4, _song8],
    albums: [sampleAlbums[3]],
  ),
];

// Playlists
final samplePlaylists = <PlaylistModel>[
  const PlaylistModel(
    id: 'p1',
    title: 'Late Night Vibes',
    description: 'A reflective mix for urban evenings and quiet moments.',
    imageUrl:
        'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&q=80',
    owner: 'You',
    followers: 12300,
    songs: [_song1, _song3, _song5, _song7, _song9],
    isOwned: true,
  ),
  const PlaylistModel(
    id: 'p2',
    title: 'Sunset Runs',
    description: 'Energetic beats for the golden hour workout.',
    imageUrl:
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80',
    owner: 'VMusic',
    followers: 84000,
    songs: [_song4, _song8, _song2, _song6],
  ),
  const PlaylistModel(
    id: 'p3',
    title: 'Focus Flow',
    description: 'Deep concentration music for work and study.',
    imageUrl:
        'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=600&q=80',
    owner: 'VMusic',
    followers: 230000,
    songs: [_song9, _song10, _song3, _song7, _song1],
  ),
  const PlaylistModel(
    id: 'p4',
    title: 'Morning Ritual',
    description: 'Start your day with the perfect soundtrack.',
    imageUrl:
        'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600&q=80',
    owner: 'VMusic',
    followers: 156000,
    songs: [_song4, _song2, _song8, _song6],
  ),
  const PlaylistModel(
    id: 'p5',
    title: 'Chill Electronica',
    description: 'Smooth electronic beats for any occasion.',
    imageUrl:
        'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&q=80',
    owner: 'You',
    followers: 4200,
    songs: [_song2, _song6, _song10, _song5],
    isOwned: true,
  ),
];

// Genres
final sampleGenres = <GenreModel>[
  const GenreModel(
    id: 'g1',
    name: 'Synthwave',
    imageUrl:
        'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=400&q=80',
    color: 0xFF9B59B6,
  ),
  const GenreModel(
    id: 'g2',
    name: 'Indie Pop',
    imageUrl:
        'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=400&q=80',
    color: 0xFF1ED760,
  ),
  const GenreModel(
    id: 'g3',
    name: 'Lo-fi',
    imageUrl:
        'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400&q=80',
    color: 0xFFE67E22,
  ),
  const GenreModel(
    id: 'g4',
    name: 'R&B',
    imageUrl:
        'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&q=80',
    color: 0xFFE74C3C,
  ),
  const GenreModel(
    id: 'g5',
    name: 'House',
    imageUrl:
        'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&q=80',
    color: 0xFF3498DB,
  ),
  const GenreModel(
    id: 'g6',
    name: 'Alternative',
    imageUrl:
        'https://images.unsplash.com/photo-1487180144351-b8472da7d491?w=400&q=80',
    color: 0xFF1ABC9C,
  ),
  const GenreModel(
    id: 'g7',
    name: 'Hip-Hop',
    imageUrl:
        'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400&q=80',
    color: 0xFFF39C12,
  ),
  const GenreModel(
    id: 'g8',
    name: 'Jazz',
    imageUrl:
        'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400&q=80',
    color: 0xFF8E44AD,
  ),
];

// Current User
const currentUser = UserModel(
  id: 'u1',
  name: 'Alex Rivera',
  email: 'alex@vmusic.app',
  avatarUrl:
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
  isPremium: true,
  followersCount: 248,
  followingCount: 91,
  bio: 'Music is the shorthand of emotion.',
);

// All songs flat list
final allSongs = <SongModel>[
  _song1, _song2, _song3, _song4, _song5,
  _song6, _song7, _song8, _song9, _song10,
];

// Trending songs
final trendingSongs = <SongModel>[
  _song10, _song1, _song3, _song6, _song4,
];

// Recently played
final recentlyPlayed = <SongModel>[
  _song1, _song5, _song3, _song8, _song2,
];

// Liked songs
final likedSongs = allSongs.where((s) => s.isFavorite).toList();

// Recent searches
final recentSearches = ['Luna Vale', 'Velvet Phase', 'Lo-fi Nights', 'Aria North'];

// Trending search terms
final trendingSearches = [
  'Midnight Drive',
  'Neon Skyline',
  'Future Bloom',
  'Synthwave',
  'Lo-fi Beats',
  'Indie Pop 2024',
];

// AppSong / AppAlbum / AppArtist / AppPlaylist kept for backward compat
typedef AppSong = SongModel;
typedef AppAlbum = AlbumModel;
typedef AppArtist = ArtistModel;
typedef AppPlaylist = PlaylistModel;
