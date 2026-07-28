import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../widgets/primary_button.dart';
import '../../../../widgets/secondary_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A1628), Color(0xFF0D0D0D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  const Spacer(),
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: Colors.black,
                      size: 40,
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack)
                      .fadeIn(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'VMusic',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          letterSpacing: -1.5,
                        ),
                  ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3, end: 0),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Stream your next obsession',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3, end: 0),
                  const SizedBox(height: AppSpacing.xxl),
                  // Feature highlights
                  ..._features.asMap().entries.map(
                        (e) => _FeatureRow(
                          icon: e.value.$1,
                          text: e.value.$2,
                        )
                            .animate(delay: (300 + e.key * 100).ms)
                            .fadeIn()
                            .slideX(begin: -0.2, end: 0),
                      ),
                  const Spacer(),
                  // Buttons
                  PrimaryButton(
                    label: 'Get started',
                    isFullWidth: true,
                    onPressed: () => context.push('/register'),
                  ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.3, end: 0),
                  const SizedBox(height: AppSpacing.sm),
                  SecondaryButton(
                    label: 'I already have an account',
                    isFullWidth: true,
                    onPressed: () => context.push('/login'),
                  ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.3, end: 0),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'By continuing, you agree to our Terms & Privacy Policy',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ).animate(delay: 900.ms).fadeIn(),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _features = [
    (Icons.library_music_rounded, '80 million songs, ad-free'),
    (Icons.download_rounded, 'Download and listen offline'),
    (Icons.devices_rounded, 'Play on any device'),
  ];
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: AppRadius.circularSm,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
