import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/network/data/dio_factory.dart';
import 'package:pishkhan_mobile/core/network/data/interceptors/api_logging_interceptor.dart';

class LogTestAdapter implements HttpClientAdapter {
  LogTestAdapter(this.response);
  final ResponseBody Function() response;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => response();

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
      () => ResponseBody.fromString(
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

  test('shared bank client logs different API routes through its default debug sink', () async {
    final previousDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      logs.add(message ?? '');
    };
    addTearDown(() => debugPrint = previousDebugPrint);
    dio.close(force: true);
    dio = createBankDio();
    response('{"status":0}', 200);

    await dio.get('/deposits/catalog');
    await dio.post('/cards/request', data: {'sample': 'complete-body'});

    expect(logs.where((log) => log.startsWith('[API REQUEST]')), hasLength(2));
    expect(logs.where((log) => log.startsWith('[API SUCCESS]')), hasLength(2));
    expect(
      logs.join('\n'),
      contains('GET https://apii.rqbank.ir/deposits/catalog'),
    );
    expect(
      logs.join('\n'),
      contains('POST https://apii.rqbank.ir/cards/request'),
    );
    expect(logs.join('\n'), contains('complete-body'));
  });

  test('logs request URL and successful response with full values without changing its data', () async {
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
      expect(text, contains(secret));
    }
    expect(result.data!['token'], 'private-token');
    expect(result.data!['customer'], {'firstName': 'private-name'});
  });

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
    expect(logs.join('\n'), contains('private-token'));
  });

  test(
    'labels bank rejection in an HTTP 200 response as a business error',
    () async {
      response('{"status":2,"message":"Rejected"}', 200);
      await dio.post('/check-cif');
      expect(logs.join('\n'), contains('[API BUSINESS ERROR]'));
    },
  );

  test('logs both header sets and complete request fields including credentials and OTP', () async {
    dio.httpClientAdapter = LogTestAdapter(
      () => ResponseBody.fromString(
        '{"status":-1,"message":"WRONG_CAPTCHA","token":null}',
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
          'SessionId': ['private-session'],
          'set-cookie': ['private-cookie'],
        },
      ),
    );
    final result = await dio.post<Map<String, dynamic>>(
      '/check-sms',
      data: {'code': '1234', 'captcha': '5678', 'mobile': '09121127934'},
      options: Options(
        headers: {
          'token': 'private-challenge',
          'Cookie': 'private-request-cookie',
          'Accept-Language': 'fa-IR',
          'X-New-Secret': 'private-unknown-header',
        },
      ),
    );
    final text = logs.join('\n');
    expect(text, contains('Request headers:'));
    expect(text, contains('Response headers:'));
    expect(text, contains('Request body:'));
    expect(text, contains('Response body:'));
    expect(text, contains('fa-IR'));
    expect(text, contains('application/json'));
    expect(text, contains('"code": "1234"'));
    expect(text, contains('"token": "private-challenge"'));
    expect(text, contains('WRONG_CAPTCHA'));
    expect(text, contains('private-session'));
    expect(text, contains('Request #1'));
    expect(text, contains(' ms'));
    for (final secret in [
      '1234',
      '5678',
      '09121127934',
      'private-challenge',
      'private-cookie',
      'private-request-cookie',
      'private-unknown-header',
    ]) {
      expect(text, contains(secret));
    }
    expect(result.requestOptions.headers['token'], 'private-challenge');
    expect(result.requestOptions.data['code'], '1234');
    expect(result.headers.value('SessionId'), 'private-session');
  });

  test(
    'SessionId headers retain their exact value regardless of case or length',
    () async {
      const sessionId = 'captcha#12345678901234567890';
      dio.httpClientAdapter = LogTestAdapter(
        () => ResponseBody.fromString(
          '{"status":0}',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
            'sEsSiOnId': [sessionId],
            'token': ['private-response-token'],
          },
        ),
      );
      await dio.get(
        '/captcha',
        options: Options(
          headers: {
            'SessionID': sessionId,
            'Authorization': 'Bearer private-authorization',
          },
        ),
      );
      expect(logs.first, contains(sessionId));
      expect(logs.last, contains(sessionId));
      expect(logs.join('\n'), contains('private-response-token'));
      expect(logs.join('\n'), contains('private-authorization'));
    },
  );

  test('concurrent calls retain distinct matching request numbers', () async {
    response('{"status":0}', 200);
    await Future.wait([dio.get('/first'), dio.get('/second')]);
    final firstRequest = logs.singleWhere(
      (log) => log.startsWith('[API REQUEST]') && log.contains('/first'),
    );
    final firstResponse = logs.singleWhere(
      (log) => log.startsWith('[API SUCCESS]') && log.contains('/first'),
    );
    final secondRequest = logs.singleWhere(
      (log) => log.startsWith('[API REQUEST]') && log.contains('/second'),
    );
    final secondResponse = logs.singleWhere(
      (log) => log.startsWith('[API SUCCESS]') && log.contains('/second'),
    );
    expect(firstRequest, contains('Request #1'));
    expect(firstResponse, contains('Request #1'));
    expect(secondRequest, contains('Request #2'));
    expect(secondResponse, contains('Request #2'));
  });

  test(
    'large bodies, unknown headers and lists are printed without truncation',
    () async {
      final longValue = 'full-value-' * 900;
      final records = List.generate(45, (index) => {'record': 'record-$index'});
      response(
        jsonEncode({'status': 0, 'records': records, 'unknown': longValue}),
        200,
      );
      await dio.post(
        '/full?sessionId=raw-query',
        data: {'payload': longValue},
        options: Options(headers: {'X-Unknown-Header': longValue}),
      );
      final text = logs.join('\n');
      expect(text, contains('sessionId=raw-query'));
      expect(logs.first, contains(longValue));
      expect(logs.last, contains(longValue));
      expect(logs.last, contains('record-44'));
      expect(text, isNot(contains('[REDACTED]')));
      expect(text, isNot(contains('[truncated]')));
    },
  );

  test('multipart logging shows fields and file metadata without consuming uploads', () async {
    response('{"status":0}', 200);
    final form = FormData.fromMap({
      'nationalCode': '0012345678',
      'document': MultipartFile.fromString(
        'private-document',
        filename: 'private-name.txt',
      ),
    });
    await dio.post('/upload', data: form);
    final text = logs.join('\n');
    expect(text, contains('"filename": "private-name.txt"'));
    expect(text, contains('"length": 16'));
    expect(text, isNot(contains('private-document')));
    expect(text, contains('private-name.txt'));
    expect(text, contains('0012345678'));
  });

  test('prints complete CAPTCHA Base64 and non-JSON error pages', () async {
    response('private-captcha-base64', 200, type: 'image/jpeg');
    await dio.get<String>(
      '/captcha',
      options: Options(responseType: ResponseType.plain),
    );
    expect(logs.join('\n'), contains('private-captcha-base64'));
    logs.clear();
    response('<html>private-error-page</html>', 502, type: 'text/html');
    await expectLater(dio.get('/captcha'), throwsA(isA<DioException>()));
    expect(logs.join('\n'), contains('HTTP 502'));
    expect(logs.join('\n'), contains('private-error-page'));
  });

  test(
    'prints nested unknown fields and identifiers without redaction',
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
        expect(text, contains(secret));
      }
      expect(text, contains('Invalid mobile'));
    },
  );

  test(
    'network failures log URL, failure kind and exception details',
    () async {
      dio.httpClientAdapter = NetworkFailureAdapter();
      await expectLater(dio.get('/captcha'), throwsA(isA<DioException>()));
      expect(
        logs.join('\n'),
        contains('[API ERROR] GET https://bank.test/captcha'),
      );
      expect(logs.join('\n'), contains('connectionTimeout'));
      expect(logs.join('\n'), contains('private-exception-details'));
    },
  );
}
