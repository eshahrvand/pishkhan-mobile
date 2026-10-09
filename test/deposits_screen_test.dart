import 'package:pishkhan_mobile/features/dashboard/data/mock/mock_dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/data/mock/dashboard_mock_data.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/deposits/deposits_tab.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/deposits/deposit_actions.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
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
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    locale: const Locale('fa'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
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

Future<void> tap(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
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
              DepositsTab(
                repository: MockDashboardDepositsRepository(
                  deposits: single
                      ? const [DashboardMockData.singleDeposit]
                      : DashboardMockData.deposits,
                ),
              ),
            ),
            size: Size(375, single ? 1264 : 1089),
          );
          if (!single) await tap(tester, 'deposits_indicator_1');
          expect(tester.takeException(), isNull);
          expect(
            tester.getTopLeft(find.byKey(const Key('deposits_operations'))).dy,
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
            find.byKey(const Key('deposits_cheque_operations')),
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
              final file = File('doc/deposits-review/$name.png');
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
          DepositsTab(
            repository: MockDashboardDepositsRepository(deposits: mixed),
            onActionRequested: (value) => request = value,
            onSelectedDepositChanged: (value) => selected = value,
          ),
        ),
      );
      expect(find.byKey(const Key('deposits_cheque_operations')), findsNothing);
      await tap(tester, 'deposits_indicator_1');
      expect(selected?.id, 'with');
      expect(
        find.byKey(const Key('deposits_cheque_operations')),
        findsOneWidget,
      );
      await tap(tester, 'app_service_grid_icon_deposits-deposit-statement');
      expect(request?.action, DepositAction.statement);
      expect(request?.deposit.id, 'with');
      await tap(tester, 'deposits_indicator_0');
      expect(find.byKey(const Key('deposits_cheque_operations')), findsNothing);
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
        DepositsTab(
          repository: MockDashboardDepositsRepository(deposits: [mixed[1]]),
          onCopyNumber: (value) => copiedNumber = value,
          onCopyIban: (value) => copiedIban = value,
        ),
      ),
    );
    await tap(tester, 'app_deposit_card_copy_number');
    await tap(tester, 'app_deposit_card_copy_iban');
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
        DepositsTab(
          repository: MockDashboardDepositsRepository(deposits: [mixed[1]]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tap(tester, 'app_deposit_card_copy_iban');
    expect(clipboard, 'IR456');
  });

  testWidgets(
    'reordering retains selected ID and removing it selects the first deposit',
    (tester) async {
      await mount(
        tester,
        subject(
          const DepositsTab(
            repository: MockDashboardDepositsRepository(deposits: mixed),
          ),
        ),
      );
      await tap(tester, 'deposits_indicator_1');
      await tester.pumpWidget(
        subject(
          DepositsTab(
            repository: MockDashboardDepositsRepository(
              deposits: [mixed[1], mixed[0]],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('deposits_cheque_operations')),
        findsOneWidget,
      );
      await tester.pumpWidget(
        subject(
          DepositsTab(
            repository: MockDashboardDepositsRepository(deposits: [mixed[0]]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('deposits_cheque_operations')), findsNothing);
      await tester.pumpWidget(
        subject(
          const DepositsTab(
            repository: MockDashboardDepositsRepository(deposits: []),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppDepositCard), findsNothing);
      expect(find.byKey(const Key('deposits_operations')), findsNothing);
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
        DepositsTab(
          repository: MockDashboardDepositsRepository(deposits: mixed),
          onSelectedDepositChanged: (value) => selected = value,
        ),
      ),
    );
    await tester.drag(
      find.byKey(const Key('deposits_carousel')),
      const Offset(300, 0),
    );
    await tester.pumpAndSettle();
    expect(selected?.id, 'with');
    expect(find.byKey(const Key('deposits_cheque_operations')), findsOneWidget);
  });

  testWidgets(
    'tab switching retains selection; back returns to dashboard; callbacks survive',
    (tester) async {
      DepositActionRequest? request;
      await mount(
        tester,
        subject(
          DashboardScreen(
            enableAnimations: false,
            deposits: mixed,
            onDepositActionRequested: (value) => request = value,
          ),
        ),
      );
      await tap(tester, 'primary_tab_deposits');
      await tap(tester, 'deposits_indicator_1');
      await tap(tester, 'primary_tab_cards');
      await tap(tester, 'primary_tab_deposits');
      expect(
        find.byKey(const Key('deposits_cheque_operations')),
        findsOneWidget,
      );
      await tap(tester, 'app_service_grid_icon_deposits-deposit-statement');
      expect(request?.deposit.id, 'with');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('dashboard_bank_services')), findsOneWidget);
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
          enableAnimations: false,
          onServiceRequested: ids.add,
          onMenuPressed: () => menu++,
        ),
      ),
    );
    await tap(tester, 'primary_tab_deposits');
    await tap(tester, 'app_service_grid_icon_deposits-deposit-statement');
    expect(ids.last, 'deposit-statement');
    await tap(tester, 'dashboard_menu_button');
    expect(menu, 1);
    await tap(tester, 'deposits_assistant_button');
    expect(ids.last, 'assistant');
    expect(find.byKey(const Key('dashboard_bank_services')), findsOneWidget);
    await tap(tester, 'primary_tab_loans');
    expect(find.byKey(const Key('loans_screen')), findsOneWidget);
  });

  testWidgets(
    'narrow screen, larger text, quick actions and empty state remain usable',
    (tester) async {
      DepositActionRequest? request;
      await mount(
        tester,
        subject(
          DepositsTab(
            repository: MockDashboardDepositsRepository(
              deposits: const [DashboardMockData.singleDeposit],
            ),
            onActionRequested: (value) => request = value,
          ),
          scale: 1.4,
        ),
        size: const Size(320, 700),
      );
      await tap(tester, 'app_service_grid_icon_deposits-modern-phone');
      expect(request?.action, DepositAction.phoneBank);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        subject(
          const DepositsTab(
            repository: MockDashboardDepositsRepository(deposits: []),
          ),
          scale: 1.4,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('deposits_navigation')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
