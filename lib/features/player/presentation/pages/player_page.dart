import 'package:flutter/material.dart';
import 'package:vmusic/core/theme/app_color.dart';
import 'package:vmusic/core/theme/app_radius.dart';
import 'package:vmusic/core/theme/app_spacing.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            Hero(
              tag: 'featured-Midnight Echoes',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: Image.network(
                  'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=900&q=80',
                  height: 280,
                  width: 280,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Midnight Echoes',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Astra Vale', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                thumbColor: AppColors.primary,
              ),
              child: Slider(value: 0.42, onChanged: (_) {}),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_previous_rounded, size: 32),
                ),
                FloatingActionButton.large(
                  onPressed: () {},
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.play_arrow_rounded, size: 32),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_next_rounded, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
