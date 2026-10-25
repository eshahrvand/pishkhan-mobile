import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../config/constant.dart';
import 'api_log_formatter.dart';

/// Terminal diagnostics for every request on the shared bank Dio client.
/// Full headers and bodies in every build mode while API_LOGS is enabled.
class ApiLoggingInterceptor extends Interceptor {
  ApiLoggingInterceptor({void Function(String)? log})
    : _log = log ?? ((message) => debugPrint(message, wrapWidth: 1000));

  final void Function(String) _log;
  final _requests = Expando<({int id, Stopwatch timer})>();
  int _nextRequestId = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!AppConstants.apiLoggingEnabled) {
      handler.next(options);
      return;
    }
    final request = (id: ++_nextRequestId, timer: Stopwatch()..start());
    _requests[options] = request;
    _log(
      '[API REQUEST] ${options.method} ${options.uri}\n'
      'Request #${request.id} | responseType: ${options.responseType.name}\n'
      'Timeouts: connect=${options.connectTimeout?.inMilliseconds} ms, '
      'send=${options.sendTimeout?.inMilliseconds} ms, '
      'receive=${options.receiveTimeout?.inMilliseconds} ms\n'
      'Request headers:\n${ApiLogFormatter.headers(options.headers)}\n'
      'Request body:\n${ApiLogFormatter.body(options.data)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!AppConstants.apiLoggingEnabled) {
      handler.next(response);
      return;
    }
    final data = response.data;
    final businessFailure =
        data is Map && data['status'] is num && data['status'] != 0;
    _log(
      '[API ${businessFailure ? 'BUSINESS ERROR' : 'SUCCESS'}] '
      '${response.requestOptions.method} '
      '${response.requestOptions.uri} '
      '| HTTP ${response.statusCode} ${_finishRequest(response.requestOptions)}\n'
      'Response headers:\n${ApiLogFormatter.headers(response.headers.map)}\n'
      'Response body:\n${ApiLogFormatter.body(data)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!AppConstants.apiLoggingEnabled) {
      handler.next(err);
      return;
    }
    _log(
      '[API ERROR] ${err.requestOptions.method} '
      '${err.requestOptions.uri} '
      '| HTTP ${err.response?.statusCode ?? '-'} | ${err.type.name} '
      '${_finishRequest(err.requestOptions)}\n'
      'Error message: ${err.message}\n'
      'Error cause: ${err.error}\n'
      'Response headers:\n${ApiLogFormatter.headers(err.response?.headers.map ?? {})}\n'
      'Response body:\n${ApiLogFormatter.body(err.response?.data)}',
    );
    handler.next(err);
  }

  String _finishRequest(RequestOptions options) {
    final request = _requests[options];
    request?.timer.stop();
    return '| Request #${request?.id ?? '-'} | '
        '${request?.timer.elapsedMilliseconds ?? 0} ms';
  }
}
