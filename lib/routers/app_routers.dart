import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/dummy_data.dart';
import '../features/album/presentation/pages/album_detail_page.dart';
import '../features/artist/presentation/pages/artist_detail_page.dart';
import '../features/authentication/presentation/pages/forget_password_page.dart';
import '../features/authentication/presentation/pages/login_page.dart';
import '../features/authentication/presentation/pages/signup_page.dart';
import '../features/authentication/presentation/pages/welcome_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/library/presentation/pages/library_page.dart';
import '../features/misc/presentation/pages/misc_pages.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/player/presentation/pages/player_page.dart';
import '../features/playlist/presentation/pages/create_playlist_page.dart';
import '../features/playlist/presentation/pages/playlist_detail_page.dart';
import '../features/premium/presentation/pages/premium_page.dart';
import '../features/profile/presentation/pages/edit_profile_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/search/presentation/pages/search_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/shell/presentation/pages/app_shell.dart';
import '../features/splash/presentation/pages/splash_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    errorBuilder: (_, __) => const NotFoundPage(),
    routes: [
      // Splash
      GoRoute(path: '/', builder: (_, __) => const SplashPage()),

      // Auth
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomePage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const SignupPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordPage(),
      ),

      // Player (full screen, above shell)
      GoRoute(
        path: '/player',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PlayerPage(),
      ),

      // Album detail
      GoRoute(
        path: '/album/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final album =
              state.extra as AlbumModel? ??
              sampleAlbums.firstWhere(
                (a) => a.id == state.pathParameters['id'],
                orElse: () => sampleAlbums.first,
              );
          return AlbumDetailPage(album: album);
        },
      ),

      // Artist detail
      GoRoute(
        path: '/artist/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final artist =
              state.extra as ArtistModel? ??
              sampleArtists.firstWhere(
                (a) => a.id == state.pathParameters['id'],
                orElse: () => sampleArtists.first,
              );
          return ArtistDetailPage(artist: artist);
        },
      ),

      // Playlist detail
      GoRoute(
        path: '/playlist/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final playlist =
              state.extra as PlaylistModel? ??
              samplePlaylists.firstWhere(
                (p) => p.id == state.pathParameters['id'],
                orElse: () => samplePlaylists.first,
              );
          return PlaylistDetailPage(playlist: playlist);
        },
      ),
    
      // Create / Edit playlist
      GoRoute(
        path: '/create-playlist',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const CreatePlaylistPage(),
      ),
      GoRoute(
        path: '/edit-playlist',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            CreatePlaylistPage(playlist: state.extra as PlaylistModel?),
      ),

      // Profile sub-pages
      GoRoute(
        path: '/edit-profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const SettingsPage(),
      ),
      GoRoute(
        path: '/premium',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PremiumPage(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/about',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AboutPage(),
      ),
      GoRoute(
        path: '/help',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const HelpPage(),
      ),
      GoRoute(
        path: '/terms',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const TermsPage(),
      ),
      GoRoute(
        path: '/privacy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const PrivacyPage(),
      ),

      // Main shell with bottom nav
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (_, __) => const LibraryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
