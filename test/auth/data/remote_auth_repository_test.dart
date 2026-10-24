import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/network/access_token_store.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:pishkhan_mobile/features/auth/data/repositories/remote_auth_repository.dart';
import 'package:pishkhan_mobile/features/auth/domain/entities/login_captcha.dart';
import 'package:pishkhan_mobile/features/auth/domain/entities/login_identity.dart';

import '../../support/auth_test_dependencies.dart';

class StubBankAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  final responses = <ResponseBody>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return responses.removeAt(0);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;
  late StubBankAdapter adapter;
  late AccessTokenStore tokens;
  late RemoteAuthRepository repository;

  ResponseBody json(String body, [int status = 200]) => ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );

  setUp(() {
    adapter = StubBankAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://bank.test'))
      ..httpClientAdapter = adapter;
    tokens = AccessTokenStore();
    repository = RemoteAuthRepository(AuthRemoteDataSource(dio), tokens);
  });
  tearDown(() => dio.close(force: true));

  test('generated Retrofit client decodes Base64 under image/jpeg', () async {
    adapter.responses.add(
      ResponseBody.fromString(
        '${testCaptchaBase64.substring(0, 76)}\r\n${testCaptchaBase64.substring(76)}\r\n',
        200,
        headers: {
          Headers.contentTypeHeader: ['image/jpeg'],
          'sessionid': ['server#captcha-1'],
        },
      ),
    );
    final result = await repository.fetchCaptcha();
    expect(result, isA<Success<LoginCaptcha>>());
    final captcha = (result as Success<LoginCaptcha>).data;
    expect(captcha.bytes.take(4), [0x89, 0x50, 0x4e, 0x47]);
    expect(captcha.sessionId, 'server#captcha-1');
    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.headers.containsKey('version'), isFalse);
    expect(adapter.requests.single.path, '/captcha');
    expect(() => captcha.bytes[0] = 0, throwsUnsupportedError);
  });

  final jpeg = File('test/support/fixtures/synthetic_captcha.jpg')
      .readAsBytesSync();
  for (final layers in [1, 2]) {
    for (final missingEndBytes in [0, 1, 2]) {
      test(
        'JPEG with $layers Base64 layer(s) and $missingEndBytes missing EOI bytes decodes',
        () async {
          var body = base64Encode(
            jpeg.sublist(0, jpeg.length - missingEndBytes),
          );
          body = '${body.substring(0, 76)}\r\n${body.substring(76)}\r\n';
          if (layers == 2) body = base64Encode(utf8.encode(body));
          adapter.responses.add(
            ResponseBody.fromString(
              body,
              200,
              headers: {
                Headers.contentTypeHeader: ['image/jpeg'],
                'sessionid': ['server#jpeg-$layers-$missingEndBytes'],
              },
            ),
          );
          final result = await repository.fetchCaptcha();
          expect(result, isA<Success<LoginCaptcha>>());
          final captcha = (result as Success<LoginCaptcha>).data;
          expect(captcha.bytes, orderedEquals(jpeg));
          expect(captcha.sessionId, 'server#jpeg-$layers-$missingEndBytes');
          expect(adapter.requests.length, 1);
        },
      );
    }
  }

  for (final invalidBody in [
    base64Encode([0xff, 0xd8, 0xff, 0x00]),
    base64Encode([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    base64Encode(jpeg.sublist(0, 100)),
    base64Encode(utf8.encode(base64Encode(utf8.encode(testCaptchaBase64)))),
  ]) {
    test(
      'image signatures or excessive Base64 nesting never establish CAPTCHA success: ${invalidBody.length}',
      () async {
        adapter.responses.add(
          ResponseBody.fromString(
            invalidBody,
            200,
            headers: {
              'sessionid': ['server#invalid-image'],
            },
          ),
        );
        final result = await repository.fetchCaptcha();
        expect(result, isA<Err<LoginCaptcha>>());
        expect(
          (result as Err<LoginCaptcha>).failure.code,
          'auth.captcha_invalid_response',
        );
      },
    );
  }

  test(
    'invalid image bodies and gateway pages become failure values',
    () async {
      adapter.responses.add(
        ResponseBody.fromString(
          '<html>Gateway</html>',
          200,
          headers: {
            'sessionid': ['server#captcha-1'],
          },
        ),
      );
      expect(await repository.fetchCaptcha(), isA<Err<LoginCaptcha>>());
    },
  );

  for (final sessionId in [null, '', '   ']) {
    test(
      'CAPTCHA without a nonempty SessionId header is rejected: $sessionId',
      () async {
        adapter.responses.add(
          ResponseBody.fromString(
            testCaptchaBase64,
            200,
            headers: {
              if (sessionId != null) 'sessionid': [sessionId],
            },
          ),
        );
        expect(await repository.fetchCaptcha(), isA<Err<LoginCaptcha>>());
      },
    );
  }

  test(
    'check-cif uses the SessionId from each exact CAPTCHA response',
    () async {
      for (final sessionId in ['first#captcha', 'second#captcha']) {
        adapter.responses.add(
          ResponseBody.fromString(
            testCaptchaBase64,
            200,
            headers: {
              'SeSsIoNiD': [sessionId],
            },
          ),
        );
        final result = await repository.fetchCaptcha() as Success<LoginCaptcha>;
        adapter.responses.add(json('{"status":0,"token":"test-challenge"}'));
        await repository.requestOtp(
          LoginIdentity(
            nationalCode: testLoginIdentity.nationalCode,
            mobile: testLoginIdentity.mobile,
            captcha: '123456',
            sessionId: result.data.sessionId,
          ),
        );
        expect(adapter.requests.last.data['sessionId'], sessionId);
      }
    },
  );

  test(
    'identity request uses exact bank keys and owner-approved temporary IP',
    () async {
      adapter.responses.add(
        json('{"status":0,"message":"OK","token":"test-challenge"}'),
      );
      final result = await repository.requestOtp(testLoginIdentity);
      expect(result, isA<Success<LoginOtpChallenge>>());
      expect(adapter.requests.single.path, '/check-cif');
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.headers['version'], 'ng-1');
      expect(adapter.requests.single.data, {
        'nationalCode': testLoginIdentity.nationalCode,
        'ip': '192.168.0.1',
        'mobile': testLoginIdentity.mobile,
        'captcha': testLoginIdentity.captcha,
        'sessionId': testLoginIdentity.sessionId,
      });
      expect(tokens.accessToken, isNull);
    },
  );

  test('verification sends the raw challenge token header and stores the final token', () async {
    const challenge = LoginOtpChallenge(
      token: r'test#challenge$token!',
      identity: testLoginIdentity,
    );
    adapter.responses.add(
      json('''{"status":0,"token":"test-final-token",
      "customer":{"customerCode":"test-customer","nationalCode":"0081234562",
      "firstName":"Test","lastName":"Customer"},"deposits":[],"loans":[]}'''),
    );
    final result = await repository.verifyOtp(challenge, '123456');
    expect(result, isA<Success<AuthenticatedCustomer>>());
    expect(adapter.requests.single.path, '/check-sms');
    expect(adapter.requests.single.data, {'code': '123456'});
    expect(adapter.requests.single.headers['token'], challenge.token);
    expect(
      adapter.requests.single.headers.containsKey('Authorization'),
      isFalse,
    );
    expect(adapter.requests.single.headers.containsKey('version'), isFalse);
    expect(tokens.accessToken, 'test-final-token');
  });

  for (final response in [
    '{"status":1,"message":"rejected","token":"test-token"}',
    '{"status":0,"message":null,"token":null}',
    '{"status":0,"token":""}',
    '{"message":"OK","token":"test-token"}',
    '{}',
  ]) {
    test('HTTP 200 alone never creates an OTP challenge: $response', () async {
      adapter.responses.add(json(response));
      expect(
        await repository.requestOtp(testLoginIdentity),
        isA<Err<LoginOtpChallenge>>(),
      );
      expect(tokens.accessToken, isNull);
    });
  }

  test(
    'HTTP 200 WRONG_CAPTCHA returns a specific failure without a challenge',
    () async {
      adapter.responses.add(
        json('{"status":-1,"message":"WRONG_CAPTCHA","token":null}'),
      );
      final result = await repository.requestOtp(testLoginIdentity);
      expect(result, isA<Err<LoginOtpChallenge>>());
      expect(
        (result as Err<LoginOtpChallenge>).failure.code,
        'auth.wrong_captcha',
      );
      expect(adapter.requests.length, 1);
      expect(tokens.accessToken, isNull);
    },
  );

  test(
    'unknown bank rejection remains generic and does not expose server text',
    () async {
      adapter.responses.add(
        json('{"status":-1,"message":"UNKNOWN_BANK_DETAIL","token":null}'),
      );
      final result = await repository.requestOtp(testLoginIdentity);
      expect(result, isA<Err<LoginOtpChallenge>>());
      expect(
        (result as Err<LoginOtpChallenge>).failure.code,
        'auth.request_rejected',
      );
      expect(tokens.accessToken, isNull);
    },
  );

  test('OTP failure does not authenticate or store a token', () async {
    adapter.responses.add(json('{"status":1,"token":"test-token"}'));
    expect(
      await repository.verifyOtp(testOtpChallenge, '000000'),
      isA<Err<AuthenticatedCustomer>>(),
    );
    expect(tokens.accessToken, isNull);
  });

  test('a customer for a different national code is rejected', () async {
    adapter.responses.add(
      json('''{"status":0,"token":"test-token",
      "customer":{"customerCode":"test-customer","nationalCode":"other",
      "firstName":"Test","lastName":"Customer"}}'''),
    );
    expect(
      await repository.verifyOtp(testOtpChallenge, '123456'),
      isA<Err<AuthenticatedCustomer>>(),
    );
    expect(tokens.accessToken, isNull);
  });

  test(
    'HTTP errors are converted to failures, without retrying POST',
    () async {
      adapter.responses.add(json('{"message":"unauthorized"}', 401));
      expect(
        await repository.verifyOtp(testOtpChallenge, '123456'),
        isA<Err<AuthenticatedCustomer>>(),
      );
      expect(adapter.requests.length, 1);
      expect(tokens.accessToken, isNull);
    },
  );

  test('malformed JSON does not escape the repository', () async {
    adapter.responses.add(json('not json'));
    expect(
      await repository.requestOtp(testLoginIdentity),
      isA<Err<LoginOtpChallenge>>(),
    );
  });
}
