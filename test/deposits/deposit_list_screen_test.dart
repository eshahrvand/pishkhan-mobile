import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/core/router/app_router.dart';
import 'package:pishkhan_mobile/core/router/router_session.dart';
import 'package:pishkhan_mobile/features/deposits/deposits.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_deposit_list.dart';

import '../support/router_test_app.dart';

// Required only to capture the entire app including modal overlays.
final _captureKey = GlobalKey();
Widget _app(Widget home, {String locale = 'fa', double scale = 1}) =>
    RepaintBoundary(
      key: _captureKey,
      child: TestRouterApp(
        home: home,
        theme: AppTheme.light(),
        locale: Locale(locale),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: const EdgeInsets.only(top: 24, bottom: 40),
            viewPadding: const EdgeInsets.only(top: 24, bottom: 40),
            textScaler: TextScaler.linear(scale),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        ),
      ),
    );

Future<void> _capture(WidgetTester tester, String name) async {
  if (Platform.environment['CAPTURE_DEPOSIT_LIST_PREVIEWS'] != '1') return;
  await tester.pump();
  final boundary =
      _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/previews/deposits');
    await directory.create(recursive: true);
    await File('${directory.path}/$name.png')
        .writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  setUpAll(() async {
    final loader = FontLoader(AppTypography.defaultFontFamily);
    for (final weight in ['Regular', 'Medium', 'DemiBold', 'Bold']) {
      loader.addFont(
        rootBundle.load(
          'packages/avp_ui/assets/fonts/IRANYekanXFaNum-$weight.ttf',
        ),
      );
    }
    await loader.load();
  });
  Future<void> size(WidgetTester tester, Size value) async {
    tester.view.physicalSize = value;
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 40);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 40);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
  }

  testWidgets(
    'three deposits and both differently named sheets match frame geometry',
    (tester) async {
      await size(tester, const Size(375, 812));
      await tester.pumpWidget(_app(const DepositListScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AppDepositList), findsNWidgets(3));
      expect(
        tester.getTopLeft(find.byType(AppDepositList).first),
        const Offset(16, 176),
      );
      expect(
        tester.getSize(find.byType(AppDepositList).first),
        const Size(343, 112),
      );
      await _capture(tester, 'phase1-list');
      (tester.widget<AppDepositList>(find.byType(AppDepositList).first))
          .onMoreTap!();
      await tester.pumpAndSettle();
      expect(find.byType(DepositActionsSheet), findsOneWidget);
      expect(tester.getTopLeft(find.byType(DepositActionsSheet)).dy, 240);
      await _capture(tester, 'phase2-actions');
      await tester.tap(find.text('جزئیات حساب'));
      await tester.pumpAndSettle();
      expect(find.byType(DepositActionsSheet), findsNothing);
      expect(find.byType(DepositAccountDetailsSheet), findsOneWidget);
      expect(find.text('بهار مبارک'), findsOneWidget);
      expect(find.text('الهام غریبی'), findsOneWidget);
      expect(tester.getTopLeft(find.text('بهار مبارک')).dx, 20);
      expect(tester.getTopLeft(find.text('0081234567').first).dx, 20);
      expect(
        tester.getTopLeft(find.byType(DepositAccountDetailsSheet)).dy,
        308,
      );
      await _capture(tester, 'phase3-account-details');
      await tester.tap(find.text('بازگشت'));
      await tester.pumpAndSettle();
      expect(find.byType(DepositAccountDetailsSheet), findsNothing);
      expect(find.byType(AppDepositList), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'filter selection is interactive and action retains selected deposit',
    (tester) async {
      await size(tester, const Size(375, 812));
      DepositListActionRequest? request;
      await tester.pumpWidget(
        _app(DepositListScreen(onActionRequested: (r) => request = r)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('نوع حساب'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('جاری حقیقی').last);
      await tester.pumpAndSettle();
      expect(find.byType(AppDepositList), findsOneWidget);
      (tester.widget<AppDepositList>(find.byType(AppDepositList))).onMoreTap!();
      await tester.pumpAndSettle();
      await tester.tap(find.text('کارت‌های متصل به حساب'));
      await tester.pumpAndSettle();
      expect(request!.deposit.id, 'current-1');
      expect(request!.action, DepositListAction.linkedCards);
      await tester.tap(find.text('نوع حساب'));
      await tester.pumpAndSettle();
      expect(find.byType(AppDepositList), findsNWidgets(3));
    },
  );
  for (final locale in ['fa', 'en', 'ar']) {
    testWidgets('$locale compact large-text layout scrolls both sheets', (
      tester,
    ) async {
      await size(tester, const Size(320, 640));
      await tester.pumpWidget(
        _app(const DepositListScreen(), locale: locale, scale: 1.3),
      );
      await tester.pumpAndSettle();
      (tester.widget<AppDepositList>(find.byType(AppDepositList).first))
          .onMoreTap!();
      await tester.pumpAndSettle();
      expect(find.byType(DepositActionsSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
      final detailsLabel = S.current.depositListAccountDetails;
      await tester.tap(find.text(detailsLabel));
      await tester.pumpAndSettle();
      expect(find.byType(DepositAccountDetailsSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('service opens deposit route and protected link survives login', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => AppButton(
            label: 'Open deposits',
            onPressed: () =>
                ServiceRegistry.openCardService(context, 'deposit-list'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open deposits'));
    await tester.pumpAndSettle();
    expect(find.byType(DepositListScreen), findsOneWidget);
    final session = RouterSession();
    final router = createAppRouter(
      session: session,
      initialLocation: AppRoutes.depositList,
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light(),
        locale: const Locale('fa'),
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, AppRoutes.login);
    expect(
      router.routeInformationProvider.value.uri.queryParameters['from'],
      AppRoutes.depositList,
    );
    session.signIn();
    await tester.pumpAndSettle();
    expect(find.byType(DepositListScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
    session.dispose();
  });
}
