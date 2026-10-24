import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/constant.dart';
import '../../result/failure.dart';
import 'interceptors/api_logging_interceptor.dart';

/// HTTPS transport with full debug-only logs and no automatic POST retries.
/// Bank-approved primary/backup SPKI pins are still required for production.
Dio createBankDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.bankBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      sendTimeout: AppConstants.sendTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
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
  if (kDebugMode) {
    dio.interceptors.add(ApiLoggingInterceptor());
  }
  return dio;
}
