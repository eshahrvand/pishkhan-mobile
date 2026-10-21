import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../result/failure.dart';
import 'interceptors/api_logging_interceptor.dart';

/// HTTPS transport with redacted development logs and no automatic POST retries.
/// Bank-approved primary/backup SPKI pins are still required for production.
Dio createBankDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://apii.rqbank.ir',
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      followRedirects: false,
      headers: {'Accept-Language': 'fa-IR'},
    ),
  );
  // Architecture §9.4 requires approved current + backup SPKI pins. Until the
  // bank supplies those keys, do not silently ship an unpinned release client.
  if (kReleaseMode && !kIsWeb) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: const DataFailure('security.pinning_not_configured'),
            ),
          );
        },
      ),
    );
  }
  if (!kReleaseMode) {
    dio.interceptors.add(ApiLoggingInterceptor());
  }
  return dio;
}
