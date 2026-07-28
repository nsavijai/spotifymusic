import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_color.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Wait for animations then check auth
    Future.delayed(const Duration(milliseconds: 1800), _checkAuth);
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;

    final storage = SecureStorageService.instance;
    final accessToken = await storage.getAccessToken();
    final refreshToken = await storage.getRefreshToken();

    // No tokens at all → go to welcome
    if (accessToken == null && refreshToken == null) {
      if (mounted) context.go('/welcome');
      return;
    }

    // Try to use existing access token by calling /users/me
    if (accessToken != null) {
      try {
        final res = await DioClient.instance.dio.get(ApiEndpoints.usersMe);
        if (res.statusCode == 200) {
          if (mounted) context.go('/home');
          return;
        }
      } catch (_) {
        // Access token invalid — try refresh
      }
    }

    // Attempt token refresh
    if (refreshToken != null) {
      final refreshed = await DioClient.instance.attemptTokenRefresh();
      if (refreshed) {
        if (mounted) context.go('/home');
        return;
      }
    }

    // All attempts failed → clear and go to welcome
    await storage.clearTokens();
    if (mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.black,
                size: 48,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            Text(
              'VMusic',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: -1,
                  ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            Text(
              'Your premium sound',
              style: Theme.of(context).textTheme.bodyMedium,
            )
                .animate(delay: 500.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 64),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
