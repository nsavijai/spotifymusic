import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';

class DioClient {
  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.instance.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await attemptTokenRefresh();
            if (refreshed) {
              try {
                final response = await _retryRequest(error.requestOptions);
                return handler.resolve(response);
              } catch (_) {}
            }
          }
          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  static final DioClient instance = DioClient._();
  late final Dio _dio;

  Dio get dio => _dio;

  /// Public so SplashPage can call it directly during the auth check.
  Future<bool> attemptTokenRefresh() async {
    try {
      final refreshToken = await SecureStorageService.instance.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.authRefresh}',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        await SecureStorageService.instance.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        return true;
      }
    } catch (_) {
      await SecureStorageService.instance.clearTokens();
    }
    return false;
  }

  Future<Response> _retryRequest(RequestOptions options) async {
    final token = await SecureStorageService.instance.getAccessToken();
    final newHeaders = Map<String, dynamic>.from(options.headers);
    if (token != null) {
      newHeaders['Authorization'] = 'Bearer $token';
    }

    return _dio.fetch(
      options.copyWith(headers: newHeaders),
    );
  }

  ApiException handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(message: 'Connection timed out. Please try again.');
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final message = error.response?.data is Map
            ? error.response?.data['message'] ?? 'Server error ($status)'
            : 'Server error ($status)';
        return ApiException(message: message.toString());
      case DioExceptionType.connectionError:
        return const ApiException(message: 'No internet connection.');
      default:
        return ApiException(message: error.message ?? 'An unexpected error occurred.');
    }
  }
}
