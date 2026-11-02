import 'package:dio/dio.dart';

import '../../config/constant.dart';
import 'interceptors/api_logging_interceptor.dart';

/// HTTPS transport with configurable API diagnostics and no automatic POST retries.
/// Owner-approved test releases currently use ordinary HTTPS validation.
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
  if (AppConstants.apiLoggingEnabled) {
    dio.interceptors.add(ApiLoggingInterceptor());
  }
  // Owner-approved temporary review builds use ordinary HTTPS certificate
  // validation in every mode until the bank supplies its approved SPKI pins.
  return dio;
}
