import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/security/access_token_store.dart';

void main() {
  test(
    'web does not persist tokens even when the browser platform is Android',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final first = createAccessTokenStore();
      await first.replace('synthetic-web-token');
      expect(first.accessToken, 'synthetic-web-token');
      final freshPage = createAccessTokenStore();
      await freshPage.restore();
      expect(freshPage.accessToken, isNull);
      await first.clear();
      expect(first.accessToken, isNull);
    },
    skip: !kIsWeb,
  );
}
