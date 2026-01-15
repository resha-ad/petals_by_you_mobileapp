import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sprint1_project/core/api/api_endpoints.dart';
import 'package:sprint1_project/core/services/storage/secure_storage_service.dart';

// Provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));

class ApiClient {
  late final Dio _dio;
  final Ref ref;

  ApiClient(this.ref) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_AuthInterceptor(ref));

    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, attempt) {
          return error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError;
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;
}

// Auth Interceptor - adds token to protected requests
class _AuthInterceptor extends Interceptor {
  final Ref ref;

  _AuthInterceptor(this.ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login/register
    final isAuthEndpoint =
        options.path == ApiEndpoints.userLogin ||
        options.path == ApiEndpoints.users;

    if (!isAuthEndpoint) {
      final token = await ref.read(secureStorageProvider).getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired/invalid → clear it
      ref.read(secureStorageProvider).deleteToken();
      // You can add global logout/navigation here later
    }
    handler.next(err);
  }
}
