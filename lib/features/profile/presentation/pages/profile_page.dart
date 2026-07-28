import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/dummy_data.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            pinned: true,
            title: const Text('Profile'),
            actions: [
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(AppIcons.settings),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                // Avatar
                Stack(
                  children: [
                    AppNetworkImage(
                      url: currentUser.avatarUrl,
                      width: 100,
                      height: 100,
                      isCircle: true,
                    ),
                    if (currentUser.isPremium)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(AppIcons.premium,
                              color: Colors.black, size: 16),
                        ),
                      ),
                  ],
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: AppSpacing.md),
                Text(
                  currentUser.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ).animate(delay: 100.ms).fadeIn(),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  currentUser.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate(delay: 150.ms).fadeIn(),
                if (currentUser.bio.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    currentUser.bio,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ).animate(delay: 200.ms).fadeIn(),
                ],
                const SizedBox(height: AppSpacing.lg),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatItem(
                      value: currentUser.followersCount.toString(),
                      label: 'Followers',
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: AppColors.divider,
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                    ),
                    _StatItem(
                      value: currentUser.followingCount.toString(),
                      label: 'Following',
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: AppColors.divider,
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                    ),
                    _StatItem(
                      value: likedSongs.length.toString(),
                      label: 'Liked',
                    ),
                  ],
                ).animate(delay: 250.ms).fadeIn(),
                const SizedBox(height: AppSpacing.lg),
                // Edit profile button
                OutlinedButton(
                  onPressed: () => context.push('/edit-profile'),
                  child: const Text('Edit profile'),
                ).animate(delay: 300.ms).fadeIn(),
                const SizedBox(height: AppSpacing.xl),
                // Premium banner
                if (currentUser.isPremium)
                  _PremiumBanner()
                else
                  _UpgradeBanner(),
                const SizedBox(height: AppSpacing.xl),
                // Menu items
                ..._buildMenuItems().asMap().entries.map(
                      (e) => _ProfileMenuItem(
                        icon: e.value.$1,
                        label: e.value.$2,
                        onTap: e.value.$3(context),
                      )
                          .animate(delay: (350 + e.key * 50).ms)
                          .fadeIn()
                          .slideX(begin: -0.05, end: 0),
                    ),
                const SizedBox(height: AppSpacing.lg),
                // Logout
                ListTile(
                  leading: const Icon(AppIcons.logout, color: AppColors.error),
                  title: Text(
                    'Log out',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.error),
                  ),
                  onTap: () => context.go('/welcome'),
                ).animate(delay: 600.ms).fadeIn(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
  static List<(IconData, String, VoidCallback Function(BuildContext))> _buildMenuItems() => [
    (AppIcons.settings, 'Settings', (ctx) => () => ctx.push('/settings')),
    (AppIcons.premium, 'Premium', (ctx) => () => ctx.push('/premium')),
    (AppIcons.notifications, 'Notifications', (ctx) => () => ctx.push('/notifications')),
    (AppIcons.history, 'Listening history', (ctx) => () {}),
    (AppIcons.privacy, 'Privacy', (ctx) => () => ctx.push('/privacy')),
    (AppIcons.help, 'Help & Support', (ctx) => () => ctx.push('/help')),
    (AppIcons.info, 'About VMusic', (ctx) => () => ctx.push('/about')),
  ];
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2C00), Color(0xFF1A1A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.premium, color: AppColors.gold, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VMusic Premium',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.gold,
                        )),
                Text('Active subscription',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/premium'),
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }
}

class _UpgradeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
          const Icon(AppIcons.premium, color: Colors.white, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Go Premium',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                        )),
                Text('Ad-free music, offline listening',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        )),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => context.push('/premium'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: const Icon(AppIcons.chevronRight,
          color: AppColors.textMuted, size: 18),
      onTap: onTap,
    );
  }
}
