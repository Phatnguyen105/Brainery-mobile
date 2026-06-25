import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final alreadyRetried = error.requestOptions.extra['retried'] == true;
        final isAuthEndpoint =
            error.requestOptions.path.contains('/api/auth/login') ||
            error.requestOptions.path.contains('/api/auth/refresh');

        if (status == 401 && !alreadyRetried && !isAuthEndpoint) {
          final refreshToken = await storage.readRefreshToken();
          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
              final response = await refreshDio.post<Map<String, dynamic>>(
                ApiConstants.authRefresh,
                data: {'refreshToken': refreshToken},
              );
              final data = response.data?['data'] as Map<String, dynamic>?;
              final accessToken = data?['accessToken']?.toString();
              final newRefreshToken = data?['refreshToken']?.toString();
              if (accessToken != null && newRefreshToken != null) {
                await storage.saveTokens(
                  accessToken: accessToken,
                  refreshToken: newRefreshToken,
                );
                final retryOptions = error.requestOptions;
                retryOptions.extra['retried'] = true;
                retryOptions.headers['Authorization'] = 'Bearer $accessToken';
                final retryResponse = await dio.fetch<dynamic>(retryOptions);
                return handler.resolve(retryResponse);
              }
            } catch (_) {
              await storage.clear();
            }
          }
        }

        handler.next(error);
      },
    ),
  );

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<T> getData<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) parse,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return parse(response.data?['data']);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<T> postData<T>(
    String path, {
    Object? data,
    required T Function(Object? json) parse,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return parse(response.data?['data']);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<T> putData<T>(
    String path, {
    Object? data,
    required T Function(Object? json) parse,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(path, data: data);
      return parse(response.data?['data']);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<T> deleteData<T>(
    String path, {
    Object? data,
    required T Function(Object? json) parse,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: data,
      );
      return parse(response.data?['data']);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<T> patchData<T>(
    String path, {
    Object? data,
    required T Function(Object? json) parse,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(path, data: data);
      return parse(response.data?['data']);
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  ApiException _toApiException(DioException error) {
    final status = error.response?.statusCode;
    final body = error.response?.data;
    final message = body is Map<String, dynamic>
        ? body['message']?.toString()
        : null;

    return ApiException(
      message ?? _messageForStatus(status, error.type),
      statusCode: status,
    );
  }

  String _messageForStatus(int? status, DioExceptionType type) {
    if (type == DioExceptionType.connectionError ||
        type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout) {
      return 'Mat ket noi mang. Vui long thu lai.';
    }
    return switch (status) {
      400 => 'Du lieu gui len chua hop le.',
      401 => 'Phien dang nhap da het han.',
      403 => 'Ban khong co quyen thuc hien thao tac nay.',
      404 => 'Khong tim thay du lieu.',
      409 => 'Du lieu da ton tai hoac bi trung.',
      500 => 'Loi he thong. Vui long thu lai sau.',
      _ => 'Co loi xay ra. Vui long thu lai.',
    };
  }
}
