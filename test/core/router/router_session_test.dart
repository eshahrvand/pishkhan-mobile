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
  setUp(() => SharedPreferences.setMockInitialValues({}));
  setUpAll(() async {
    final loader = FontLoader(AppTypography.defaultFontFamily);
    loader.addFont(
      rootBundle.load(
        'packages/avp_ui/assets/fonts/IRANYekanXFaNum-Regular.ttf',
      ),
    );
    await loader.load();
  });

  test('first launch requires login; login survives a fresh session', () async {
    final first = await RouterSession.restorePrototype();
    expect(first.isAuthenticated, isFalse);
    await first.signIn();
    first.dispose();

    final restarted = await RouterSession.restorePrototype();
    addTearDown(restarted.dispose);
    expect(restarted.isAuthenticated, isTrue);
  });

  test('logout clears the remembered login and pending route data', () async {
    final first = await RouterSession.restorePrototype();
    await first.signIn();
    first.pendingExtra = Object();
    await first.signOut();
    expect(first.isAuthenticated, isFalse);
    expect(first.pendingExtra, isNull);
    first.dispose();

    final restarted = await RouterSession.restorePrototype();
    addTearDown(restarted.dispose);
    expect(restarted.isAuthenticated, isFalse);
  });

  test('isolated router scopes do not change remembered login', () async {
    final remembered = await RouterSession.restorePrototype();
    await remembered.signIn();
    remembered.dispose();

    final isolated = RouterSession();
    await isolated.signOut();
    isolated.dispose();

    final restarted = await RouterSession.restorePrototype();
    addTearDown(restarted.dispose);
    expect(restarted.isAuthenticated, isTrue);
  });

  testWidgets('login once skips login when the application is recreated', (
    tester,
  ) async {
    configureDependencies();
    addTearDown(() => getIt.reset());
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );
    final first = await tester.runAsync(RouterSession.restorePrototype);
    await tester.pumpWidget(PishkhanApp(session: first!));
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsOneWidget);
    final auth = tester
        .element(find.byType(BlocBuilder<AuthCubit, AuthState>).first)
        .read<AuthCubit>();
    auth.updateNationalId('0081234562');
    auth.updatePhoneNumber('09121234567');
    auth.updateCaptcha('123456');
    auth.submitOtpRequest();
    auth.updateOtp('1234');
    auth.submitLogin();
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());

    final restarted = await tester.runAsync(RouterSession.restorePrototype);
    await tester.pumpWidget(PishkhanApp(session: restarted!));
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);

    await tester.runAsync(restarted.signOut);
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
