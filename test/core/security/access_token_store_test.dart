import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/security/access_token_store.dart';

import '../../support/secure_storage_test_driver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SecureStorageTestDriver device;

  setUp(() {
    device = SecureStorageTestDriver()..install();
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    device.uninstall();
  });

  test('Android resumes the final token from secure storage', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final first = createAccessTokenStore();
    await first.replace('synthetic-final-token');

    final restarted = createAccessTokenStore();
    await restarted.restore();
    expect(restarted.accessToken, kIsWeb ? isNull : 'synthetic-final-token');
    expect(device.methods, kIsWeb ? isEmpty : ['write', 'read']);
  });

  test('non-Android platforms never read or write persistent tokens', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    device.values[SecureStorageTestDriver.tokenKey] = 'synthetic-old-token';
    final first = createAccessTokenStore();
    await first.replace('synthetic-final-token');
    expect(first.accessToken, 'synthetic-final-token');
    final restarted = createAccessTokenStore();
    await restarted.restore();
    expect(restarted.accessToken, isNull);
    await first.clear();
    expect(first.accessToken, isNull);
    expect(device.methods, isEmpty);
  });

  test(
    'logout deletes only the login token and prevents restoration',
    () async {
      device.values['unrelated'] = 'retained';
      final first = AccessTokenStore(storage: const FlutterSecureStorage());
      await first.replace('synthetic-final-token');
      await first.clear();
      expect(first.accessToken, isNull);
      final restarted = AccessTokenStore(storage: const FlutterSecureStorage());
      await restarted.restore();
      expect(restarted.accessToken, isNull);
      expect(device.values, {'unrelated': 'retained'});
    },
  );

  for (final stored in [null, '', '   ']) {
    test('missing or blank stored token does not resume: $stored', () async {
      if (stored != null) {
        device.values[SecureStorageTestDriver.tokenKey] = stored;
      }
      final store = AccessTokenStore(storage: const FlutterSecureStorage());
      await store.restore();
      expect(store.accessToken, isNull);
    });
  }

  test('unreadable storage requires login without crashing startup', () async {
    device.failingMethod = 'read';
    final store = AccessTokenStore(storage: const FlutterSecureStorage());
    await store.restore();
    expect(store.accessToken, isNull);
  });

  test('token is published only after its secure write succeeds', () async {
    device.writeCompletion = Completer<void>();
    final store = AccessTokenStore(storage: const FlutterSecureStorage());
    final saving = store.replace('synthetic-final-token');
    expect(store.accessToken, isNull);
    device.writeCompletion!.complete();
    await saving;
    expect(store.accessToken, 'synthetic-final-token');
  });

  test(
    'failed write never falls back to an authenticated memory token',
    () async {
      device.failingMethod = 'write';
      final store = AccessTokenStore(storage: const FlutterSecureStorage());
      await expectLater(
        store.replace('synthetic-token'),
        throwsA(isA<PlatformException>()),
      );
      expect(store.accessToken, isNull);
      expect(device.values, isEmpty);
    },
  );

  test(
    'failed deletion is reported instead of claiming token removal',
    () async {
      final store = AccessTokenStore(storage: const FlutterSecureStorage());
      await store.replace('synthetic-token');
      device.failingMethod = 'delete';
      await expectLater(store.clear(), throwsA(isA<PlatformException>()));
      expect(store.accessToken, 'synthetic-token');
      expect(
        device.values[SecureStorageTestDriver.tokenKey],
        'synthetic-token',
      );
    },
  );
}
