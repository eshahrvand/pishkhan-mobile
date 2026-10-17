import 'package:pishkhan_mobile/features/dashboard/presentation/home/widgets/dashboard_home_panel.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../support/auth_ui_finders.dart';

import 'package:pishkhan_mobile/core/di/injection_container.dart';

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
import 'package:pishkhan_mobile/features/cards/presentation/virtual_card_request/screens/virtual_card_request_screen.dart';
import 'package:pishkhan_mobile/features/launch/presentation/shared/widgets/route_unavailable_screen.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/features/launch/presentation/splash/screens/splash_screen.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/dashboard_screen.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_tab.dart';

Widget app(GoRouter router) => MaterialApp.router(
  routerConfig: router,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child!,
  ),
  theme: AppTheme.light(),
  locale: const Locale('fa'),
  supportedLocales: S.delegate.supportedLocales,
  localizationsDelegates: const [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
);

void main() {
  setUp(configureDependencies);
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
  test('all implemented paths are unique and module-prefixed', () {
    final session = RouterSession();
    final router = createAppRouter(session: session);
    addTearDown(() {
      router.dispose();
      session.dispose();
    });
    final routes = router.configuration.routes.cast<GoRoute>();
    final paths = routes.map((r) => r.path).toList();
    const modulePaths = {
      '/launch/': [AppRoutes.splash],
      '/dashboard/': [AppRoutes.home, AppRoutes.allServices],
      '/auth/': [AppRoutes.login],
      '/cards/': [
        AppRoutes.cardPasswords,
        AppRoutes.cardList,
        AppRoutes.cardIssuance,
        AppRoutes.virtualCardRequest,
        AppRoutes.changeCardDeposit,
        AppRoutes.expiredGiftBalance,
      ],
      '/profile/': [AppRoutes.messages, AppRoutes.messageDetail],
      '/deposits/': [
        AppRoutes.depositList,
        AppRoutes.averageBalance,
        AppRoutes.financialCertificate,
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
  });
  test(
    'return destination accepts implemented local routes and rejects tampering',
    () {
      for (final value in [
        AppRoutes.virtualCardRequest,
        AppRoutes.cardPasswords,
        AppRoutes.changeCardDeposit,
        AppRoutes.expiredGiftBalance,
        AppRoutes.depositList,
        '/cards/list?category=virtual',
        '/profile/messages/security-id',
        AppRoutes.allServices,
      ]) {
        expect(validatedReturnLocation(value), value);
      }
      for (final value in [
        null,
        '',
        'https://evil.example/cards/list',
        '//evil.example/cards/list',
        AppRoutes.login,
        '/unknown',
        '/cards/list?category=virtual&category=gift',
        '/cards/list?category=unsupported',
        '/dashboard/home?token=secret',
        '/cards/list#bad',
      ]) {
        expect(validatedReturnLocation(value), AppRoutes.home, reason: value);
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
          homeBuilder: (_) => const DashboardScreen(),
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
          authenticated ? AppRoutes.home : AppRoutes.login,
        );
        expect(
          find.byType(authenticated ? DashboardScreen : AuthScreen),
          findsOneWidget,
        );
        expect(session.isAuthenticated, authenticated);
        if (!authenticated) {
          expect(
            router.routeInformationProvider.value.uri.queryParameters['from'],
            AppRoutes.home,
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
        initialLocation: AppRoutes.virtualCardRequest,
        homeBuilder: (_) => const Scaffold(body: Text('Home')),
      );
      addTearDown(() {
        router.dispose();
        session.dispose();
      });
      await tester.pumpWidget(app(router));
      await tester.pumpAndSettle();
      router.go(
        AppRoutes.virtualCardRequest,
        extra: const CardRouteArguments(initialDepositNumber: '10.123.1'),
      );
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.login);
      expect(
        router.routeInformationProvider.value.uri.queryParameters['from'],
        AppRoutes.virtualCardRequest,
      );
      final cubit = tester
          .element(find.byType(BlocBuilder<AuthCubit, AuthState>).first)
          .read<AuthCubit>();
      cubit.updateNationalId('0081234562');
      cubit.updatePhoneNumber('09121234567');
      cubit.updateCaptcha('123456');
      expect(cubit.requestOtp(), isTrue);
      cubit.updateOtp('1234');
      await tester.pumpAndSettle();
      await tester.tap(authControl(tester, 'submit_otp_button'));
      await tester.pumpAndSettle();
      expect(session.isAuthenticated, isTrue);
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.virtualCardRequest,
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

  testWidgets(
    'Home route disposes its Provider-owned Cubit and creates fresh state on reentry',
    (tester) async {
      final session = RouterSession(true);
      final router = createAppRouter(
        session: session,
        initialLocation: AppRoutes.home,
      );
      addTearDown(() {
        router.dispose();
        session.dispose();
      });
      await tester.pumpWidget(app(router));
      await tester.pumpAndSettle();
      final first = tester
          .element(find.byType(DashboardHomePanel))
          .read<HomeCubit>();
      first.selectTab(AppPrimaryTab.cards);
      await tester.pumpAndSettle();
      session.signOut();
      await tester.pumpAndSettle();
      expect(first.isClosed, isTrue);
      session.signIn();
      router.go(AppRoutes.home);
      await tester.pumpAndSettle();
      final second = tester
          .element(find.byType(DashboardHomePanel))
          .read<HomeCubit>();
      expect(identical(first, second), isFalse);
      expect(second.state.selectedTab, AppPrimaryTab.dashboard);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(second.isClosed, isTrue);
    },
  );
}
