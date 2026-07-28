import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as ja;
import '../../../../core/constants/dummy_data.dart';
import '../../../../features/music/data/providers/music_repository_provider.dart';

enum RepeatMode { off, all, one }

class PlayerState {
  const PlayerState({
    this.currentSong,
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isLoading = false,
    this.isShuffle = false,
    this.repeatMode = RepeatMode.off,
    this.progress = 0.0,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.showLyrics = false,
    this.error,
  });

  final SongModel? currentSong;
  final List<SongModel> queue;
  final int currentIndex;
  final bool isPlaying;
  final bool isLoading;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final double progress;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool showLyrics;
  final String? error;

  bool get hasNext => currentIndex < queue.length - 1;
  bool get hasPrev => currentIndex > 0;

  PlayerState copyWith({
    SongModel? currentSong,
    List<SongModel>? queue,
    int? currentIndex,
    bool? isPlaying,
    bool? isLoading,
    bool? isShuffle,
    RepeatMode? repeatMode,
    double? progress,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? showLyrics,
    String? error,
  }) =>
      PlayerState(
        currentSong: currentSong ?? this.currentSong,
        queue: queue ?? this.queue,
        currentIndex: currentIndex ?? this.currentIndex,
        isPlaying: isPlaying ?? this.isPlaying,
        isLoading: isLoading ?? this.isLoading,
        isShuffle: isShuffle ?? this.isShuffle,
        repeatMode: repeatMode ?? this.repeatMode,
        progress: progress ?? this.progress,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        volume: volume ?? this.volume,
        showLyrics: showLyrics ?? this.showLyrics,
        error: error,
      );
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  PlayerNotifier(this._ref) : super(const PlayerState()) {
    _init();
  }

  final Ref _ref;
  final ja.AudioPlayer _player = ja.AudioPlayer();
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<ja.PlayerState>? _playerStateSub;
  StreamSubscription<int?>? _currentIndexSub;

  Future<void> _init() async {
    // Configure audio session for music playback
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Position updates
    _positionSub = _player.positionStream.listen((pos) {
      final dur = state.duration;
      final progress =
          dur.inMilliseconds > 0 ? pos.inMilliseconds / dur.inMilliseconds : 0.0;
      state = state.copyWith(
        position: pos,
        progress: progress.clamp(0.0, 1.0),
      );
    });

    // Duration updates
    _durationSub = _player.durationStream.listen((dur) {
      if (dur != null) state = state.copyWith(duration: dur);
    });

    // Play/pause/loading state
    _playerStateSub = _player.playerStateStream.listen((ps) {
      final isPlaying = ps.playing;
      final isLoading = ps.processingState == ja.ProcessingState.loading ||
          ps.processingState == ja.ProcessingState.buffering;

      // Auto-advance on track completion
      if (ps.processingState == ja.ProcessingState.completed) {
        _onTrackComplete();
      }

      state = state.copyWith(isPlaying: isPlaying, isLoading: isLoading);
    });
  }

  void _onTrackComplete() {
    switch (state.repeatMode) {
      case RepeatMode.one:
        _player.seek(Duration.zero);
        _player.play();
      case RepeatMode.all:
        if (state.hasNext) {
          skipNext();
        } else {
          // Wrap around to first song
          _loadAndPlay(state.queue.first, index: 0);
        }
      case RepeatMode.off:
        if (state.hasNext) skipNext();
    }
  }

  Future<void> playSong(SongModel song, {List<SongModel>? queue}) async {
    final q = queue ?? [song];
    final idx = q.indexWhere((s) => s.id == song.id);
    final resolvedIdx = idx < 0 ? 0 : idx;

    state = state.copyWith(
      currentSong: song,
      queue: q,
      currentIndex: resolvedIdx,
      isLoading: true,
      progress: 0.0,
      position: Duration.zero,
      error: null,
    );

    await _loadAndPlay(song, index: resolvedIdx);

    // Record history non-blocking
    _ref.read(musicRepositoryProvider).recordHistory(song.id);
  }

  Future<void> _loadAndPlay(SongModel song, {required int index}) async {
    try {
      final url = _ref.read(musicRepositoryProvider).getStreamUrl(song);
      await _player.setUrl(url);
      await _player.play();
      state = state.copyWith(
        currentSong: song,
        currentIndex: index,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
        error: 'Failed to load audio',
      );
    }
  }

  Future<void> togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.play();

  Future<void> skipNext() async {
    if (!state.hasNext) return;
    final idx = state.currentIndex + 1;
    final song = state.queue[idx];
    state = state.copyWith(currentSong: song, currentIndex: idx, isLoading: true);
    await _loadAndPlay(song, index: idx);
  }

  Future<void> skipPrev() async {
    // If more than 3 seconds in, restart current track
    if (state.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    if (!state.hasPrev) return;
    final idx = state.currentIndex - 1;
    final song = state.queue[idx];
    state = state.copyWith(currentSong: song, currentIndex: idx, isLoading: true);
    await _loadAndPlay(song, index: idx);
  }

  Future<void> seek(double progress) async {
    final dur = state.duration;
    if (dur == Duration.zero) return;
    final position = Duration(
      milliseconds: (progress * dur.inMilliseconds).round(),
    );
    await _player.seek(position);
    state = state.copyWith(progress: progress.clamp(0.0, 1.0), position: position);
  }

  Future<void> seekToPosition(Duration position) async {
    await _player.seek(position);
  }

  void toggleShuffle() => state = state.copyWith(isShuffle: !state.isShuffle);

  void cycleRepeat() {
    final next = RepeatMode
        .values[(state.repeatMode.index + 1) % RepeatMode.values.length];
    state = state.copyWith(repeatMode: next);
  }

  Future<void> setVolume(double v) async {
    final clamped = v.clamp(0.0, 1.0);
    await _player.setVolume(clamped);
    state = state.copyWith(volume: clamped);
  }

  void toggleLyrics() => state = state.copyWith(showLyrics: !state.showLyrics);

  void toggleFavorite() {
    if (state.currentSong == null) return;
    final updated =
        state.currentSong!.copyWith(isFavorite: !state.currentSong!.isFavorite);
    // Sync to API non-blocking
    if (updated.isFavorite) {
      _ref.read(musicRepositoryProvider).likeSong(updated.id);
    } else {
      _ref.read(musicRepositoryProvider).unlikeSong(updated.id);
    }
    state = state.copyWith(currentSong: updated);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _currentIndexSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

final playerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier(ref);
});
