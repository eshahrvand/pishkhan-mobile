import '../../support/auth_ui_finders.dart';
import '../../dashboard/support/dashboard_test_repositories.dart';

import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/router/app_router.dart';
import 'package:pishkhan_mobile/core/router/router_session.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/screens/auth_screen.dart';
import 'package:pishkhan_mobile/features/auth/presentation/login/cubit/auth_cubit.dart';
import 'package:pishkhan_mobile/features/cards/cards_routes.dart';
import 'package:pishkhan_mobile/features/cards/presentation/virtual_card_request/screens/virtual_card_request_screen.dart';
import 'package:pishkhan_mobile/features/launch/presentation/shared/widgets/route_unavailable_screen.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/features/launch/presentation/splash/screens/splash_screen.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/dashboard_screen.dart';

Widget app(GoRouter router) => RepositoryProvider.value(
  value: defaultDashboardTestRepositories,
  child: MaterialApp.router(
    routerConfig: router,
    theme: AppTheme.light(),
    locale: const Locale('fa'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
  ),
);

void main() {
  setUpAll(() async {
    final loader = FontLoader(AppTypography.defaultFontFamily);
    loader.addFont(
      rootBundle.load(
        'packages/avp_ui/assets/fonts/IRANYekanXFaNum-Regular.ttf',
      ),
    );
    await loader.load();
  });
  test('all implemented paths are unique and module-prefixed', () {
    final session = RouterSession();
    final routes = buildAppRoutes(session: session).cast<GoRoute>();
    final paths = routes.map((r) => r.path).toList();
    const modulePaths = {
      '/launch/': [LaunchRoutes.splash],
      '/dashboard/': [DashboardRoutes.home, DashboardRoutes.allServices],
      '/auth/': [AuthRoutes.login, AuthRoutes.passwords],
      '/cards/': [
        CardsRoutes.list,
        CardsRoutes.issuance,
        CardsRoutes.virtualRequest,
        CardsRoutes.changeDeposit,
        CardsRoutes.expiredGiftBalance,
      ],
      '/profile/': [ProfileRoutes.messages, ProfileRoutes.messageDetail],
      '/deposits/': [
        DepositsRoutes.list,
        DepositsRoutes.averageBalance,
        DepositsRoutes.financialCertificate,
      ],
    };
    final declaredPaths = modulePaths.values.expand((paths) => paths).toList();
    expect(paths, unorderedEquals(declaredPaths));
    expect(paths.toSet().length, paths.length);
    expect(declaredPaths.toSet().length, declaredPaths.length);
    for (final module in modulePaths.entries) {
      for (final path in module.value) {
        expect(path.startsWith(module.key), isTrue, reason: path);
      }
    }
    session.dispose();
  });
  test(
    'return destination accepts implemented local routes and rejects tampering',
    () {
      for (final value in [
        CardsRoutes.virtualRequest,
        CardsRoutes.changeDeposit,
        CardsRoutes.expiredGiftBalance,
        DepositsRoutes.list,
        '/cards/list?category=virtual',
        '/profile/messages/security-id',
        DashboardRoutes.allServices,
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
        '/dashboard/home?token=secret',
        '/cards/list#bad',
      ]) {
        expect(
          validatedReturnLocation(value),
          DashboardRoutes.home,
          reason: value,
        );
      }
    },
  );
  for (final authenticated in [false, true]) {
    testWidgets(
      authenticated
          ? 'authenticated start reaches dashboard home after splash'
          : 'unauthenticated start reaches login after splash',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        final session = RouterSession(authenticated);
        final router = createAppRouter(
          session: session,
          homeBuilder: (_) => const DashboardScreen(enableAnimations: false),
        );
        addTearDown(() {
          router.dispose();
          session.dispose();
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        await tester.pumpWidget(app(router));
        expect(find.byType(SplashScreen), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byType(SplashScreen), findsNothing);
        expect(
          router.routeInformationProvider.value.uri.path,
          authenticated ? DashboardRoutes.home : AuthRoutes.login,
        );
        expect(
          find.byType(authenticated ? DashboardScreen : AuthScreen),
          findsOneWidget,
        );
        expect(session.isAuthenticated, authenticated);
        if (!authenticated) {
          expect(
            router.routeInformationProvider.value.uri.queryParameters['from'],
            DashboardRoutes.home,
          );
        }
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
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
      await tester.tap(authControl(tester, 'submit_otp_button'));
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
