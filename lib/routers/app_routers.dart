import 'package:go_router/go_router.dart';
import 'package:vmusic/features/authentication/presentation/pages/welcome_page.dart';
import 'package:vmusic/features/home/presentation/pages/home_page.dart';
import 'package:vmusic/features/player/presentation/pages/player_page.dart';
import 'package:vmusic/features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(path: '/player', builder: (context, state) => const PlayerPage()),
    ],
  );
}
