import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/models/auth_user.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  /// Login with email and password.
  /// Returns the authenticated [AuthUser] and stores JWT tokens.
  Future<AuthUser> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.authLogin,
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final payload = data['data'] as Map<String, dynamic>;
        // Store tokens for future requests.
        final access = payload['access_token'] as String?;
        final refresh = payload['refresh_token'] as String?;
        if (access != null && refresh != null) {
          await SecureStorageService.instance.saveTokens(
            accessToken: access,
            refreshToken: refresh,
          );
        }
        final userJson = payload['user'] as Map<String, dynamic>?;
        if (userJson != null) {
          return AuthUser.fromJson(userJson);
        }
        throw const ApiException(message: 'User data missing in response');
      } else {
        final msg = data['message'] ?? 'Login failed';
        throw ApiException(message: msg.toString());
      }
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Network error');
    }
  }

  /// Register a new user.
  /// Returns the newly created [AuthUser] and stores JWT tokens.
  Future<AuthUser> register({required String email, required String username, required String password}) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.authRegister,
        data: {'email': email, 'username': username, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final payload = data['data'] as Map<String, dynamic>;
        final access = payload['access_token'] as String?;
        final refresh = payload['refresh_token'] as String?;
        if (access != null && refresh != null) {
          await SecureStorageService.instance.saveTokens(
            accessToken: access,
            refreshToken: refresh,
          );
        }
        final userJson = payload['user'] as Map<String, dynamic>?;
        if (userJson != null) {
          return AuthUser.fromJson(userJson);
        }
        throw const ApiException(message: 'User data missing in response');
      } else {
        final msg = data['message'] ?? 'Registration failed';
        throw ApiException(message: msg.toString());
      }
    } on DioException catch (e) {
      throw ApiException(message: e.message ?? 'Network error');
    }
  }

  /// Logout – calls backend endpoint and clears stored tokens.
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.authLogout);
    } catch (_) {
      // Ignore errors – we still want to clear local tokens.
    }
    await SecureStorageService.instance.clearTokens();
  }
}
