import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(AppIcons.back),
        ),
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Mark all read')),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 120),
        itemCount: _notifications.length,
        itemBuilder: (_, i) => _NotificationTile(
          notification: _notifications[i],
        ).animate(delay: (i * 50).ms).fadeIn().slideX(begin: -0.05, end: 0),
      ),
    );
  }

  static final _notifications = [
    (
      imageUrl:
          'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=200&q=80',
      title: 'New release from Luna Vale',
      subtitle: '"Cascade" is now available',
      time: '2m ago',
      isRead: false,
    ),
    (
      imageUrl:
          'https://images.unsplash.com/photo-1487180144351-b8472da7d491?w=200&q=80',
      title: 'Aria North dropped a new album',
      subtitle: 'Future Bloom is out now',
      time: '1h ago',
      isRead: false,
    ),
    (
      imageUrl:
          'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=200&q=80',
      title: 'Your playlist was liked',
      subtitle: '12 people liked "Late Night Vibes"',
      time: '3h ago',
      isRead: true,
    ),
    (
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200&q=80',
      title: 'Weekly discovery ready',
      subtitle: 'Your personalized mix is here',
      time: '1d ago',
      isRead: true,
    ),
  ];
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final ({
    String imageUrl,
    String title,
    String subtitle,
    String time,
    bool isRead
  }) notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: notification.isRead
          ? Colors.transparent
          : AppColors.primary.withValues(alpha: 0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        leading: Stack(
          children: [
            AppNetworkImage(
              url: notification.imageUrl,
              width: 52,
              height: 52,
              borderRadius: AppRadius.sm,
            ),
            if (!notification.isRead)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          notification.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: notification.isRead
                    ? FontWeight.w400
                    : FontWeight.w600,
              ),
        ),
        subtitle: Text(
          notification.subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          notification.time,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
