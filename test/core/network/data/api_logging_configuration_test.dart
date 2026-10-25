import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/network/data/dio_factory.dart';
import 'package:pishkhan_mobile/core/network/data/interceptors/api_logging_interceptor.dart';

import 'api_logging_interceptor_test.dart' show LogTestAdapter;

void main() {
  for (final sharedClient in [true, false]) {
    test(
      'API_LOGS controls diagnostics without changing transport ($sharedClient)',
      () async {
        final logs = <String>[];
        final originalPrint = debugPrint;
        debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
        addTearDown(() => debugPrint = originalPrint);
        final dio = sharedClient
            ? createBankDio()
            : (Dio(BaseOptions(baseUrl: 'https://bank.test'))
                ..interceptors.add(ApiLoggingInterceptor(log: logs.add)));
        addTearDown(() => dio.close(force: true));
        var requests = 0;
        dio.httpClientAdapter = LogTestAdapter(() {
          requests++;
          return ResponseBody.fromString(
            'synthetic-captcha',
            200,
            headers: {
              'SessionId': ['synthetic-session'],
            },
          );
        });
        final response = await dio.get<String>(
          '/captcha',
          options: Options(responseType: ResponseType.plain),
        );
        expect(requests, 1);
        expect(response.data, 'synthetic-captcha');
        expect(response.headers.value('SessionId'), 'synthetic-session');
        if (AppConstants.apiLoggingEnabled) {
          expect(logs.join('\n'), contains('[API REQUEST]'));
          expect(logs.join('\n'), contains('synthetic-captcha'));
          expect(logs.join('\n'), contains('synthetic-session'));
        } else {
          expect(logs, isEmpty);
        }
      },
    );
  }
}
