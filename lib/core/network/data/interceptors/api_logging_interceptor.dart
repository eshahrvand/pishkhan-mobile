import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_log_redactor.dart';

/// Terminal diagnostics for every request on the shared bank Dio client.
/// Register only in development/profile; never expose headers or request bodies.
class ApiLoggingInterceptor extends Interceptor {
  ApiLoggingInterceptor({void Function(String)? log})
    : _log = log ?? debugPrint;

  final void Function(String) _log;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('[API REQUEST] ${options.method} ${ApiLogRedactor.url(options.uri)}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    final businessFailure =
        data is Map && data['status'] is num && data['status'] != 0;
    _log(
      '[API ${businessFailure ? 'BUSINESS ERROR' : 'SUCCESS'}] '
      '${response.requestOptions.method} '
      '${ApiLogRedactor.url(response.requestOptions.uri)} '
      '| HTTP ${response.statusCode}\n${ApiLogRedactor.body(data)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      '[API ERROR] ${err.requestOptions.method} '
      '${ApiLogRedactor.url(err.requestOptions.uri)} '
      '| HTTP ${err.response?.statusCode ?? '-'} | ${err.type.name}\n'
      '${ApiLogRedactor.body(err.response?.data)}',
    );
    handler.next(err);
  }
}
