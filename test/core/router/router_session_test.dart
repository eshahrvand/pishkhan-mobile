import '../../support/auth_test_dependencies.dart';
import '../../support/secure_storage_test_driver.dart';

import 'package:flutter/foundation.dart';
import 'package:pishkhan_mobile/core/network/access_token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/router/router_session.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/screens/auth_screen.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/dashboard_screen.dart';
import 'package:pishkhan_mobile/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    configureAuthTestDependencies();
  });
  tearDown(() => getIt.reset());
  setUpAll(() async {
    final loader = FontLoader(AppTypography.defaultFontFamily);
    loader.addFont(
      rootBundle.load(
        'packages/avp_ui/assets/fonts/IRANYekanXFaNum-Regular.ttf',
      ),
    );
    await loader.load();
  });

  test(
    'fresh sessions require bank login instead of a persisted marker',
    () async {
      final first = await RouterSession.restore();
      expect(first.isAuthenticated, isFalse);
      await getIt<AccessTokenStore>().replace('test-final-token');
      await first.signIn();
      first.dispose();

      final restarted = await RouterSession.restore();
      addTearDown(restarted.dispose);
      expect(restarted.isAuthenticated, isFalse);
    },
  );

  test('logout clears the remembered login and pending route data', () async {
    final first = await RouterSession.restore();
    await getIt<AccessTokenStore>().replace('test-final-token');
    await first.signIn();
    first.pendingExtra = Object();
    await first.signOut();
    expect(getIt<AccessTokenStore>().accessToken, isNull);
    expect(first.isAuthenticated, isFalse);
    expect(first.pendingExtra, isNull);
    first.dispose();

    final restarted = await RouterSession.restore();
    addTearDown(restarted.dispose);
    expect(restarted.isAuthenticated, isFalse);
  });

  test('legacy prototype marker never restores authentication', () async {
    SharedPreferences.setMockInitialValues({
      'prototype.authenticated.v1': true,
    });
    final remembered = await RouterSession.restore();
    expect(remembered.isAuthenticated, isFalse);
    expect(
      (await SharedPreferences.getInstance()).containsKey(
        'prototype.authenticated.v1',
      ),
      isFalse,
    );
    await getIt<AccessTokenStore>().replace('test-final-token');
    await remembered.signIn();
    remembered.dispose();

    final isolated = RouterSession();
    await isolated.signOut();
    isolated.dispose();

    final restarted = await RouterSession.restore();
    addTearDown(restarted.dispose);
    expect(restarted.isAuthenticated, isFalse);
  });

  test('managed router cannot sign in without a verified bank token', () async {
    final session = RouterSession.managed();
    addTearDown(session.dispose);
    await expectLater(session.signIn(), throwsStateError);
    expect(session.isAuthenticated, isFalse);
  });

  test(
    'Android startup resumes a saved token without a validation API',
    () async {
      final device = SecureStorageTestDriver()..install();
      addTearDown(device.uninstall);
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await getIt.unregister<AccessTokenStore>();
      getIt.registerLazySingleton(createAccessTokenStore);
      final first = await RouterSession.restore();
      addTearDown(first.dispose);
      expect(first.isAuthenticated, isFalse);
      await getIt<AccessTokenStore>().replace('synthetic-final-token');
      await first.signIn();

      await getIt.resetLazySingleton<AccessTokenStore>();
      final restarted = await RouterSession.restore();
      addTearDown(restarted.dispose);
      expect(restarted.isAuthenticated, isTrue);
      expect(getIt<AccessTokenStore>().accessToken, 'synthetic-final-token');
      expect(device.methods, ['read', 'write', 'read']);

      await restarted.signOut();
      await getIt.resetLazySingleton<AccessTokenStore>();
      final afterLogout = await RouterSession.restore();
      addTearDown(afterLogout.dispose);
      expect(afterLogout.isAuthenticated, isFalse);
      expect(device.values, isEmpty);
    },
  );

  test('failed secure deletion does not report successful logout', () async {
    final device = SecureStorageTestDriver()..install();
    addTearDown(device.uninstall);
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await getIt.unregister<AccessTokenStore>();
    getIt.registerLazySingleton(createAccessTokenStore);
    final session = await RouterSession.restore();
    addTearDown(session.dispose);
    await getIt<AccessTokenStore>().replace('synthetic-final-token');
    await session.signIn();
    device.failingMethod = 'delete';
    await expectLater(session.signOut(), throwsA(isA<PlatformException>()));
    expect(session.isAuthenticated, isTrue);
    device.failingMethod = null;
    await session.signOut();
    expect(session.isAuthenticated, isFalse);
  });

  testWidgets(
    'verified login enters the app and a fresh launch requires login',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
          FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final first = await tester.runAsync(RouterSession.restore);
      await tester.pumpWidget(PishkhanApp(session: first!));
      await tester.pumpAndSettle();
      expect(find.byType(AuthScreen), findsOneWidget);
      final auth = tester
          .element(find.byType(BlocBuilder<AuthCubit, AuthState>).first)
          .read<AuthCubit>();
      auth.updateNationalId('0081234562');
      auth.updatePhoneNumber('09121234567');
      auth.updateCaptcha('123456');
      await auth.submitOtpRequest();
      auth.updateOtp('123456');
      await auth.submitLogin(auth.state.challenge!);
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());

      final restarted = await tester.runAsync(RouterSession.restore);
      await tester.pumpWidget(PishkhanApp(session: restarted!));
      await tester.pumpAndSettle();
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.byType(DashboardScreen), findsNothing);

      await tester.runAsync(restarted.signOut);
      await tester.pumpAndSettle();
      expect(find.byType(AuthScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
