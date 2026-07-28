import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../player/presentation/widgets/mini_player.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    (icon: AppIcons.homeOutlined, activeIcon: AppIcons.home, label: 'Home'),
    (icon: AppIcons.search, activeIcon: AppIcons.search, label: 'Search'),
    (icon: AppIcons.libraryOutlined, activeIcon: AppIcons.library, label: 'Library'),
    (icon: AppIcons.profileOutlined, activeIcon: AppIcons.profile, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final hasPlayer = player.currentSong != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasPlayer) const MiniPlayer(),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: _tabs
                .map(
                  (tab) => NavigationDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.activeIcon),
                    label: tab.label,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
