import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/router/app_router.dart';
import 'package:pishkhan_mobile/core/router/router_session.dart';
import 'package:pishkhan_mobile/features/auth/auth_routes.dart';
import 'package:pishkhan_mobile/features/auth/presentation/flows/login/screens/auth_screen.dart';
import 'package:pishkhan_mobile/features/auth/presentation/flows/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/cards/cards_routes.dart';
import 'package:pishkhan_mobile/features/cards/presentation/flows/virtual_card_request/screens/virtual_card_request_screen.dart';
import 'package:pishkhan_mobile/features/shell/shell_routes.dart';
import 'package:pishkhan_mobile/features/shell/presentation/shared/widgets/route_unavailable_screen.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

Widget app(GoRouter router) => MaterialApp.router(
  routerConfig: router,
  theme: AppTheme.light(),
  locale: const Locale('fa'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
);
void main() {
  test('all implemented paths are unique and module-prefixed', () {
    final session = RouterSession();
    final routes = buildAppRoutes(session: session).cast<GoRoute>();
    final paths = routes.map((r) => r.path).toList();
    expect(paths.length, 9);
    expect(paths.toSet().length, paths.length);
    for (final path in paths) {
      expect(
        RegExp(r'^/(auth|cards|shell|profile)/').hasMatch(path),
        isTrue,
        reason: path,
      );
    }
    session.dispose();
  });
  test(
    'return destination accepts implemented local routes and rejects tampering',
    () {
      for (final value in [
        CardsRoutes.virtualRequest,
        '/cards/list?category=virtual',
        '/profile/messages/security-id',
        ShellRoutes.allServices,
      ]) {
        expect(validatedReturnLocation(value), value);
      }
      for (final value in [
        null,
        '',
        'https://evil.example/cards/list',
        '//evil.example/cards/list',
        AuthRoutes.login,
        '/unknown',
        '/cards/list?category=virtual&category=gift',
        '/cards/list?category=unsupported',
        '/shell/home?token=secret',
        '/cards/list#bad',
      ]) {
        expect(validatedReturnLocation(value), ShellRoutes.home, reason: value);
      }
    },
  );
  testWidgets(
    'protected deep link survives login; logout closes the protected flow',
    (tester) async {
      final session = RouterSession();
      final router = createAppRouter(
        session: session,
        initialLocation: CardsRoutes.virtualRequest,
        homeBuilder: (_) => const Scaffold(body: Text('Home')),
      );
      addTearDown(() {
        router.dispose();
        session.dispose();
      });
      await tester.pumpWidget(app(router));
      await tester.pumpAndSettle();
      router.go(
        CardsRoutes.virtualRequest,
        extra: const CardRouteArguments(initialDepositNumber: '10.123.1'),
      );
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, AuthRoutes.login);
      expect(
        router.routeInformationProvider.value.uri.queryParameters['from'],
        CardsRoutes.virtualRequest,
      );
      final cubit = tester.element(find.byType(AuthScreen)).read<AuthCubit>();
      cubit.nationalIdChanged('0081234562');
      cubit.phoneChanged('09121234567');
      cubit.captchaChanged('123456');
      expect(cubit.requestOtp(), isTrue);
      cubit.otpChanged('1234');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('submit_otp_button')));
      await tester.pumpAndSettle();
      expect(session.isAuthenticated, isTrue);
      expect(
        router.routeInformationProvider.value.uri.path,
        CardsRoutes.virtualRequest,
      );
      expect(find.byType(VirtualCardRequestScreen), findsOneWidget);
      expect(
        tester
            .widget<VirtualCardRequestScreen>(
              find.byType(VirtualCardRequestScreen),
            )
            .initialDepositNumber,
        '10.123.1',
      );
      expect(router.canPop(), isFalse);
      session.signOut();
      await tester.pumpAndSettle();
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.byType(VirtualCardRequestScreen), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('unsupported URL has a recoverable screen', (tester) async {
    final session = RouterSession(true);
    final router = createAppRouter(
      session: session,
      initialLocation: '/missing',
      homeBuilder: (_) => const Scaffold(body: Text('Home')),
    );
    addTearDown(() {
      router.dispose();
      session.dispose();
    });
    await tester.pumpWidget(app(router));
    await tester.pumpAndSettle();
    expect(find.byType(RouteUnavailableScreen), findsOneWidget);
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(router.canPop(), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
