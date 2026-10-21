import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/network/data/interceptors/api_logging_interceptor.dart';

class LogTestAdapter implements HttpClientAdapter {
  LogTestAdapter(this.response);
  final ResponseBody response;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => response;

  @override
  void close({bool force = false}) {}
}

class NetworkFailureAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionTimeout,
      message: 'private-exception-details',
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late List<String> logs;
  late Dio dio;

  void response(String body, int status, {String type = 'application/json'}) {
    dio.httpClientAdapter = LogTestAdapter(
      ResponseBody.fromString(
        body,
        status,
        headers: {
          Headers.contentTypeHeader: [type],
        },
      ),
    );
  }

  setUp(() {
    logs = [];
    dio = Dio(BaseOptions(baseUrl: 'https://bank.test'))
      ..interceptors.add(ApiLoggingInterceptor(log: logs.add));
  });
  tearDown(() => dio.close(force: true));

  test(
    'logs request URL and successful response without changing its data',
    () async {
      response(
        '{"status":0,"message":"OK","token":"private-token","customer":{"firstName":"private-name"}}',
        200,
      );
      final result = await dio.post<Map<String, dynamic>>(
        '/check-cif?sessionId=private-session',
        data: {'nationalCode': '0012345678', 'captcha': '123456'},
        options: Options(headers: {'Authorization': 'Bearer private-header'}),
      );
      final text = logs.join('\n');
      expect(text, contains('[API REQUEST] POST https://bank.test/check-cif?'));
      expect(text, contains('[API SUCCESS]'));
      expect(text, contains('HTTP 200'));
      expect(text, contains('"message": "OK"'));
      for (final secret in [
        'private-token',
        'private-name',
        'private-session',
        'private-header',
        '0012345678',
        '123456',
      ]) {
        expect(text, isNot(contains(secret)));
      }
      expect(result.data!['token'], 'private-token');
      expect(result.data!['customer'], {'firstName': 'private-name'});
    },
  );

  test('logs HTTP errors and preserves Dio error propagation', () async {
    response(
      '{"status":1,"message":"Unauthorized","access_token":"private-token"}',
      401,
    );
    await expectLater(dio.get('/check-sms'), throwsA(isA<DioException>()));
    expect(
      logs.join('\n'),
      contains('[API ERROR] GET https://bank.test/check-sms'),
    );
    expect(logs.join('\n'), contains('HTTP 401'));
    expect(logs.join('\n'), contains('Unauthorized'));
    expect(logs.join('\n'), isNot(contains('private-token')));
  });

  test(
    'labels bank rejection in an HTTP 200 response as a business error',
    () async {
      response('{"status":2,"message":"Rejected"}', 200);
      await dio.post('/check-cif');
      expect(logs.join('\n'), contains('[API BUSINESS ERROR]'));
    },
  );

  test('does not print raw CAPTCHA Base64 or a non-JSON error page', () async {
    response('private-captcha-base64', 200, type: 'image/jpeg');
    await dio.get<String>(
      '/captcha',
      options: Options(responseType: ResponseType.plain),
    );
    expect(logs.join('\n'), contains('[non-JSON response:'));
    expect(logs.join('\n'), isNot(contains('private-captcha-base64')));
    logs.clear();
    response('<html>private-error-page</html>', 502, type: 'text/html');
    await expectLater(dio.get('/captcha'), throwsA(isA<DioException>()));
    expect(logs.join('\n'), contains('HTTP 502'));
    expect(logs.join('\n'), isNot(contains('private-error-page')));
  });

  test(
    'masks nested unknown fields and identifiers inside diagnostic messages',
    () async {
      response(
        '{"status":1,"message":"Invalid mobile ۰۹۱۲۳۴۵۶۷۸۹ for user@example.test","errors":{"message":"Bearer private-credential","newSecretField":"private-secret"},"newBankData":{"address":"private-address"}}',
        400,
      );
      await expectLater(
        dio.get('/identity/0012345678'),
        throwsA(isA<DioException>()),
      );
      final text = logs.join('\n');
      for (final secret in [
        '۰۹۱۲۳۴۵۶۷۸۹',
        'user@example.test',
        'private-credential',
        'private-secret',
        'private-address',
        '0012345678',
      ]) {
        expect(text, isNot(contains(secret)));
      }
      expect(text, contains('Invalid mobile'));
    },
  );

  test(
    'network failures log URL and failure kind without exception details',
    () async {
      dio.httpClientAdapter = NetworkFailureAdapter();
      await expectLater(dio.get('/captcha'), throwsA(isA<DioException>()));
      expect(
        logs.join('\n'),
        contains('[API ERROR] GET https://bank.test/captcha'),
      );
      expect(logs.join('\n'), contains('connectionTimeout'));
      expect(logs.join('\n'), isNot(contains('private-exception-details')));
    },
  );
}
