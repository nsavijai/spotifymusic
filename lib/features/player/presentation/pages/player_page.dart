import 'dart:ui';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../providers/player_provider.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key});

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage>
    with TickerProviderStateMixin {
  late final AnimationController _rotationCtrl;
  late final AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final song = player.currentSong;

    if (song == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No song playing')),
      );
    }

    // Sync rotation with play state
    if (player.isPlaying) {
      _rotationCtrl.repeat();
    } else {
      _rotationCtrl.stop();
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background
          Image.network(
            song.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.background),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              color: AppColors.background.withValues(alpha: 0.75),
            ),
          ),
          // Content
          SafeArea(
            child: player.showLyrics
                ? _LyricsView(song: song, player: player)
                : _PlayerView(
                    song: song,
                    player: player,
                    rotationCtrl: _rotationCtrl,
                    scaleCtrl: _scaleCtrl,
                  ),
          ),
        ],
      ),
    );
  }
}

class _PlayerView extends ConsumerWidget {
  const _PlayerView({
    required this.song,
    required this.player,
    required this.rotationCtrl,
    required this.scaleCtrl,
  });

  final dynamic song;
  final PlayerState player;
  final AnimationController rotationCtrl;
  final AnimationController scaleCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(AppIcons.chevronDown, size: 28),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Now Playing',
                        style: Theme.of(context).textTheme.labelMedium),
                    Text(song.album,
                        style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showQueueSheet(context, ref),
                icon: const Icon(AppIcons.more, size: 24),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Rotating artwork
        RotationTransition(
          turns: rotationCtrl,
          child: ScaleTransition(
            scale: scaleCtrl,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: ClipOval(
                child: AppNetworkImage(
                  url: song.imageUrl,
                  width: 280,
                  height: 280,
                  isCircle: true,
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        // Song info + favorite
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      song.artist,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(playerProvider.notifier).toggleFavorite(),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    player.currentSong?.isFavorite == true
                        ? AppIcons.favorite
                        : AppIcons.favoriteBorder,
                    key: ValueKey(player.currentSong?.isFavorite),
                    color: player.currentSong?.isFavorite == true
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                ),
                child: Slider(
                  value: player.progress,
                  onChanged: (v) =>
                      ref.read(playerProvider.notifier).seek(v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(
                          (player.progress * song.durationSeconds).round()),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      song.duration,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () =>
                    ref.read(playerProvider.notifier).toggleShuffle(),
                icon: Icon(
                  AppIcons.shuffle,
                  color: player.isShuffle
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(playerProvider.notifier).skipPrev(),
                icon: const Icon(AppIcons.skipPrev,
                    color: AppColors.textPrimary, size: 36),
              ),
              GestureDetector(
                onTap: () => ref.read(playerProvider.notifier).togglePlay(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      player.isPlaying ? AppIcons.pause : AppIcons.play,
                      key: ValueKey(player.isPlaying),
                      color: Colors.black,
                      size: 36,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(playerProvider.notifier).skipNext(),
                icon: const Icon(AppIcons.skipNext,
                    color: AppColors.textPrimary, size: 36),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(playerProvider.notifier).cycleRepeat(),
                icon: Icon(
                  player.repeatMode == RepeatMode.one
                      ? AppIcons.repeatOne
                      : AppIcons.repeat,
                  color: player.repeatMode != RepeatMode.off
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Bottom actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () =>
                    ref.read(playerProvider.notifier).toggleLyrics(),
                icon: const Icon(
                  AppIcons.lyrics,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ),
              // Volume
              Expanded(
                child: Row(
                  children: [
                    const Icon(AppIcons.volumeMute,
                        color: AppColors.textMuted, size: 18),
                    Expanded(
                      child: Slider(
                        value: player.volume,
                        onChanged: (v) =>
                            ref.read(playerProvider.notifier).setVolume(v),
                      ),
                    ),
                    const Icon(AppIcons.volume,
                        color: AppColors.textMuted, size: 18),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showQueueSheet(context, ref),
                icon: const Icon(AppIcons.queue,
                    color: AppColors.textSecondary, size: 22),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _showQueueSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _QueueSheet(),
    );
  }
}

class _LyricsView extends ConsumerWidget {
  const _LyricsView({required this.song, required this.player});

  final dynamic song;
  final PlayerState player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              IconButton(
                onPressed: () =>
                    ref.read(playerProvider.notifier).toggleLyrics(),
                icon: const Icon(AppIcons.chevronDown, size: 28),
              ),
              Expanded(
                child: Text('Lyrics',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              song.lyrics ??
                  'Lyrics not available for this track.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 2.0,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // Mini controls
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () =>
                    ref.read(playerProvider.notifier).skipPrev(),
                icon: const Icon(AppIcons.skipPrev, size: 28),
              ),
              const SizedBox(width: AppSpacing.lg),
              GestureDetector(
                onTap: () => ref.read(playerProvider.notifier).togglePlay(),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    player.isPlaying ? AppIcons.pause : AppIcons.play,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              IconButton(
                onPressed: () =>
                    ref.read(playerProvider.notifier).skipNext(),
                icon: const Icon(AppIcons.skipNext, size: 28),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QueueSheet extends ConsumerWidget {
  const _QueueSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Text('Queue',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Text('${player.queue.length} songs',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: player.queue.length,
              itemBuilder: (_, i) {
                final s = player.queue[i];
                final isCurrent = i == player.currentIndex;
                return ListTile(
                  leading: AppNetworkImage(
                      url: s.imageUrl, width: 44, height: 44, borderRadius: 6),
                  title: Text(
                    s.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isCurrent
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                  ),
                  subtitle: Text(s.artist,
                      style: Theme.of(context).textTheme.bodySmall),
                  trailing: isCurrent
                      ? const Icon(Icons.equalizer_rounded,
                          color: AppColors.primary, size: 18)
                      : null,
                  onTap: () {
                    ref.read(playerProvider.notifier).playSong(s,
                        queue: player.queue);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
