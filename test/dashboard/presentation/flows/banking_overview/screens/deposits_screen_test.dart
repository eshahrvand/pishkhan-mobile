import '../../../../support/home_tab_test_scope.dart';
import '../../../../support/dashboard_ui_finders.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../../support/dashboard_test_repositories.dart';
import '../../../../../support/router_test_app.dart';

import 'package:pishkhan_mobile/features/dashboard/data/repositories/mock_dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/data/datasources/dashboard_mock_data.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/dashboard_screen.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/deposit_actions.dart';
import 'package:pishkhan_mobile/shared/widgets/app_deposit_card.dart';

const preview = Key('deposits_preview');
const mixed = [
  BankDeposit(
    id: 'without',
    number: '10.123.1',
    iban: 'IR123',
    hasChequeOperations: false,
  ),
  BankDeposit(
    id: 'with',
    number: '10.456.1',
    iban: 'IR456',
    hasChequeOperations: true,
  ),
];

Widget subject(Widget child, {double scale = 1}) => RepaintBoundary(
  key: preview,
  child: TestRouterApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    locale: const Locale('fa'),
    supportedLocales: S.delegate.supportedLocales,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: Directionality(textDirection: TextDirection.rtl, child: child!),
    ),
    home: child,
  ),
);

Future<void> mount(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(375, 1264),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 40);
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 40);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(child);
  await tester.pumpAndSettle();
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
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

  for (final single in [true, false]) {
    testWidgets(
      '${single ? "single" : "multiple"} deposit state reuses existing components',
      (tester) async {
        final old = debugDisableShadows;
        debugDisableShadows = false;
        try {
          await mount(
            tester,
            subject(
              depositScope(
                repository: MockDashboardDepositsRepository(
                  deposits: single
                      ? const [DashboardMockData.singleDeposit]
                      : DashboardMockData.deposits,
                ),
              ),
            ),
            size: Size(375, single ? 1264 : 1089),
          );
          if (!single) {
            await tap(tester, dashboardIndicator(DashboardDepositsCarousel, 1));
          }
          expect(tester.takeException(), isNull);
          expect(
            tester.getTopLeft(dashboardGroup(S.current.depositsOperations)).dy,
            341,
          );
          final card = tester.widget<AppDepositCard>(
            find.byType(AppDepositCard).first,
          );
          expect(
            card.size,
            single ? AppDepositCardSize.single : AppDepositCardSize.multi,
          );
          expect(
            dashboardGroup(S.current.depositsChequeOperations),
            single ? findsOneWidget : findsNothing,
          );
          final statement = tester
              .getCenter(
                find.byKey(
                  const Key('app_service_grid_icon_deposits-deposit-statement'),
                ),
              )
              .dx;
          final block = tester
              .getCenter(
                find.byKey(
                  const Key('app_service_grid_icon_deposits-deposit-block'),
                ),
              )
              .dx;
          expect(statement, greaterThan(block));
          if (Platform.environment['UPDATE_DEPOSITS_PREVIEWS'] == '1') {
            await tester.runAsync(() async {
              final boundary = tester.renderObject<RenderRepaintBoundary>(
                find.byKey(preview),
              );
              final rendered = await boundary.toImage();
              final bytes = await rendered.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final name = single ? 'phase1-single' : 'phase2-multi';
              final file = File('build/previews/deposits/$name.png');
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
              rendered.dispose();
            });
          }
        } finally {
          debugDisableShadows = old;
        }
      },
    );
  }

  testWidgets(
    'selection drives cheque visibility and action context, independently of count',
    (tester) async {
      DepositActionRequest? request;
      BankDeposit? selected;
      await mount(
        tester,
        subject(
          depositScope(
            repository: MockDashboardDepositsRepository(deposits: mixed),
            onActionRequested: (value) => request = value,
            onSelectedDepositChanged: (value) => selected = value,
          ),
        ),
      );
      expect(dashboardGroup(S.current.depositsChequeOperations), findsNothing);
      await tap(tester, dashboardIndicator(DashboardDepositsCarousel, 1));
      expect(selected?.id, 'with');
      expect(
        dashboardGroup(S.current.depositsChequeOperations),
        findsOneWidget,
      );
      await tap(
        tester,
        find.byKey(Key('app_service_grid_icon_deposits-deposit-statement')),
      );
      expect(request?.action, DepositAction.statement);
      expect(request?.deposit.id, 'with');
      await tap(tester, dashboardIndicator(DashboardDepositsCarousel, 0));
      expect(dashboardGroup(S.current.depositsChequeOperations), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('copy callbacks and system clipboard preserve original values', (
    tester,
  ) async {
    String? copiedNumber, copiedIban;
    await mount(
      tester,
      subject(
        depositScope(
          repository: MockDashboardDepositsRepository(deposits: [mixed[1]]),
          onCopyNumber: (value) => copiedNumber = value,
          onCopyIban: (value) => copiedIban = value,
        ),
      ),
    );
    await tap(tester, find.byKey(Key('app_deposit_card_copy_number')));
    await tap(tester, find.byKey(Key('app_deposit_card_copy_iban')));
    expect(copiedNumber, '10.456.1');
    expect(copiedIban, 'IR456');
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      subject(
        depositScope(
          repository: MockDashboardDepositsRepository(deposits: [mixed[1]]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tap(tester, find.byKey(Key('app_deposit_card_copy_iban')));
    expect(clipboard, 'IR456');
  });

  testWidgets(
    'reordering retains selected ID and removing it selects the first deposit',
    (tester) async {
      await mount(
        tester,
        subject(
          depositScope(
            repository: MockDashboardDepositsRepository(deposits: mixed),
          ),
        ),
      );
      await tap(tester, dashboardIndicator(DashboardDepositsCarousel, 1));
      await tester.pumpWidget(
        subject(
          depositScope(
            repository: MockDashboardDepositsRepository(
              deposits: [mixed[1], mixed[0]],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        dashboardGroup(S.current.depositsChequeOperations),
        findsOneWidget,
      );
      await tester.pumpWidget(
        subject(
          depositScope(
            repository: MockDashboardDepositsRepository(deposits: [mixed[0]]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(dashboardGroup(S.current.depositsChequeOperations), findsNothing);
      await tester.pumpWidget(
        subject(
          depositScope(
            repository: MockDashboardDepositsRepository(deposits: []),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppDepositCard), findsNothing);
      expect(dashboardGroup(S.current.depositsOperations), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('swiping the RTL carousel changes selected deposit', (
    tester,
  ) async {
    BankDeposit? selected;
    await mount(
      tester,
      subject(
        depositScope(
          repository: MockDashboardDepositsRepository(deposits: mixed),
          onSelectedDepositChanged: (value) => selected = value,
        ),
      ),
    );
    await tester.drag(
      dashboardCarousel(DashboardDepositsCarousel),
      const Offset(300, 0),
    );
    await tester.pumpAndSettle();
    expect(selected?.id, 'with');
    expect(dashboardGroup(S.current.depositsChequeOperations), findsOneWidget);
  });

  testWidgets(
    'tab switching retains selection; back returns to dashboard; callbacks survive',
    (tester) async {
      DepositActionRequest? request;
      await mount(
        tester,
        subject(
          DashboardScreen(
            repositories: dashboardTestRepositories(deposits: mixed),
            enableAnimations: false,
            onDepositActionRequested: (value) => request = value,
          ),
        ),
      );
      await tap(
        tester,
        find.descendant(
          of: find.byType(AppPrimaryNavigation),
          matching: find.text(S.current.dashboardDepositsTab),
        ),
      );
      await tap(tester, dashboardIndicator(DashboardDepositsCarousel, 1));
      await tap(
        tester,
        find.descendant(
          of: find.byType(AppPrimaryNavigation),
          matching: find.text(S.current.dashboardCardsTab),
        ),
      );
      await tap(
        tester,
        find.descendant(
          of: find.byType(AppPrimaryNavigation),
          matching: find.text(S.current.dashboardDepositsTab),
        ),
      );
      expect(
        dashboardGroup(S.current.depositsChequeOperations),
        findsOneWidget,
      );
      await tap(
        tester,
        find.byKey(Key('app_service_grid_icon_deposits-deposit-statement')),
      );
      expect(request?.deposit.id, 'with');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(DashboardBankServices), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('service fallback, assistant, menu and loans remain integrated', (
    tester,
  ) async {
    final ids = <String>[];
    var menu = 0;
    await mount(
      tester,
      subject(
        DashboardScreen(
          repositories: defaultDashboardTestRepositories,
          enableAnimations: false,
          onServiceRequested: ids.add,
          onMenuPressed: () => menu++,
        ),
      ),
    );
    await tap(
      tester,
      find.descendant(
        of: find.byType(AppPrimaryNavigation),
        matching: find.text(S.current.dashboardDepositsTab),
      ),
    );
    await tap(
      tester,
      find.byKey(Key('app_service_grid_icon_deposits-deposit-statement')),
    );
    expect(ids.last, 'deposit-statement');
    await tap(tester, find.byKey(Key('dashboard_menu_button')));
    expect(menu, 1);
    await tap(tester, find.byType(AppAssistantButton));
    expect(ids.last, 'assistant');
    expect(find.byType(DashboardBankServices), findsOneWidget);
    await tap(
      tester,
      find.descendant(
        of: find.byType(AppPrimaryNavigation),
        matching: find.text(S.current.dashboardLoansTab),
      ),
    );
    expect(find.byType(LoansTab), findsOneWidget);
  });

  testWidgets(
    'narrow screen, larger text, quick actions and empty state remain usable',
    (tester) async {
      DepositActionRequest? request;
      await mount(
        tester,
        subject(
          depositScope(
            repository: MockDashboardDepositsRepository(
              deposits: const [DashboardMockData.singleDeposit],
            ),
            onActionRequested: (value) => request = value,
          ),
          scale: 1.4,
        ),
        size: const Size(320, 700),
      );
      await tap(
        tester,
        find.byKey(Key('app_service_grid_icon_deposits-modern-phone')),
      );
      expect(request?.action, DepositAction.phoneBank);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        subject(
          depositScope(
            repository: MockDashboardDepositsRepository(deposits: []),
          ),
          scale: 1.4,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppPrimaryNavigation), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
