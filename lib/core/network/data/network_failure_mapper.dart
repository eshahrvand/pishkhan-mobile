import 'package:dio/dio.dart';

import '../../result/failure.dart';

Failure mapNetworkFailure(Object error) {
  return switch (error) {
    DioException(error: final Failure failure) => failure,
    DioException(type: DioExceptionType.connectionTimeout) => const DataFailure(
      'network.connect_timeout',
    ),
    DioException(type: DioExceptionType.sendTimeout) => const DataFailure(
      'network.send_timeout',
    ),
    DioException(type: DioExceptionType.receiveTimeout) => const DataFailure(
      'network.receive_timeout',
    ),
    DioException(type: DioExceptionType.connectionError) => const DataFailure(
      'network.connection',
    ),
    DioException(type: DioExceptionType.badCertificate) => const DataFailure(
      'network.certificate',
    ),
    DioException(type: DioExceptionType.cancel) => const DataFailure(
      'network.cancelled',
    ),
    DioException(response: final response) => DataFailure(
      'http.${response?.statusCode ?? 'invalid_response'}',
    ),
    FormatException() => const DataFailure('auth.invalid_response'),
    _ => const UnexpectedFailure(),
  };
}
