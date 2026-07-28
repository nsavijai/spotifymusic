class ApiEndpoints {
  ApiEndpoints._();

  // Change to 'http://localhost:8000' for desktop/web, '10.0.2.2' for Android emulator
  static const String baseUrl = 'http://10.0.2.2:8000';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Auth
  static const String authRegister = '/api/v1/auth/register';
  static const String authLogin    = '/api/v1/auth/login';
  static const String authRefresh  = '/api/v1/auth/refresh';
  static const String authLogout   = '/api/v1/auth/logout';
  static const String usersMe      = '/api/v1/users/me';

  // Music
  static const String songs     = '/api/v1/songs';
  static const String albums    = '/api/v1/albums';
  static const String artists   = '/api/v1/artists';
  static const String playlists = '/api/v1/playlists';
  static const String genres    = '/api/v1/genres';
  static const String search    = '/api/v1/search';
  static const String library   = '/api/v1/library';
  static const String history   = '/api/v1/history';
  static const String stream    = '/api/v1/stream';
}
