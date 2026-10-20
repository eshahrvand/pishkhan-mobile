import 'package:pishkhan_mobile/shared/widgets/app_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';

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
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/loan_actions.dart';
import 'package:pishkhan_mobile/shared/widgets/app_loan_card.dart';

const preview = Key('loans_preview');
const first = BankLoan(
  id: 'a',
  number: '001-123',
  title: 'وام اول',
  total: '100,000',
  installmentAmount: '10,000',
  paidInstallments: 2,
  nextInstallment: '۱۴۰۴/۰۸/۰۱',
);
const second = BankLoan(
  id: 'b',
  number: '002-456',
  title: 'وام دوم',
  total: '200,000',
  installmentAmount: '20,000',
  paidInstallments: 7,
  nextInstallment: '۱۴۰۴/۰۸/۰۲',
);
const sample = [first, second];

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
  Size size = const Size(375, 878),
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

Finder inLoan(String id, String key) =>
    find.descendant(of: dashboardLoan(id), matching: find.byKey(Key(key)));

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

  for (final single in [true, false]) {
    testWidgets(
      '${single ? "single" : "multiple"} loan frame uses shared components and RTL geometry',
      (tester) async {
        final old = debugDisableShadows;
        debugDisableShadows = false;
        try {
          await mount(
            tester,
            subject(
              loanScope(
                repository: MockDashboardLoansRepository(
                  loans: single
                      ? const [DashboardMockData.singleLoan]
                      : DashboardMockData.loans,
                ),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(
            tester.getTopLeft(dashboardGroup(S.current.loansOperations)).dy,
            382,
          );
          expect(
            tester.getTopLeft(dashboardGroup(S.current.cardsQuickAccess)).dy,
            570,
          );
          final card = tester.widget<AppLoanCard>(
            find.byType(AppLoanCard).first,
          );
          expect(
            card.size,
            single ? AppLoanCardSize.single : AppLoanCardSize.multi,
          );
          expect(
            tester.getSize(find.byType(AppLoanCard).first),
            Size(single ? 335 : 316, 236),
          );
          expect(
            dashboardCarousel(DashboardLoansCarousel),
            single ? findsNothing : findsOneWidget,
          );
          final pay = tester
              .getCenter(
                find.byKey(
                  const Key(
                    'app_service_grid_icon_loans-loan-pay-installments',
                  ),
                ),
              )
              .dx;
          final change = tester
              .getCenter(
                find.byKey(
                  const Key('app_service_grid_icon_loans-loan-deposit'),
                ),
              )
              .dx;
          expect(pay, greaterThan(change));
          final relations = tester
              .getCenter(
                find.byKey(
                  const Key('app_service_grid_icon_loans-loan-relationships'),
                ),
              )
              .dx;
          final consolidate = tester
              .getCenter(
                find.byKey(
                  const Key('app_service_grid_icon_loans-loan-consolidate'),
                ),
              )
              .dx;
          expect(relations, greaterThan(consolidate));
          if (Platform.environment['UPDATE_LOANS_PREVIEWS'] == '1') {
            await tester.runAsync(() async {
              final boundary = tester.renderObject<RenderRepaintBoundary>(
                find.byKey(preview),
              );
              final rendered = await boundary.toImage();
              final bytes = await rendered.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final file = File(
                'build/previews/loans/${single ? "phase1-single" : "phase2-multi"}.png',
              );
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
              rendered.dispose();
            });
          }
        } finally {
          debugDisableShadows = old;
          await tester.pumpWidget(const SizedBox.shrink());
        }
      },
    );
  }

  testWidgets(
    'indicator selection updates summary, progress and action/detail context',
    (tester) async {
      LoanActionRequest? request;
      BankLoan? selected, details;
      await mount(
        tester,
        subject(
          loanScope(
            repository: MockDashboardLoansRepository(loans: sample),
            onActionRequested: (value) => request = value,
            onSelectedLoanChanged: (value) => selected = value,
            onDetailsRequested: (value) => details = value,
          ),
        ),
      );
      await tap(tester, dashboardIndicator(DashboardLoansCarousel, 1));
      expect(selected?.id, 'b');
      final card = tester.widget<AppLoanCard>(dashboardLoan('b'));
      expect(card.cardName, 'وام دوم');
      expect(card.loanTotal, '200,000');
      expect(card.installmentAmount, '20,000');
      expect(card.installmentsPaid, '7/10');
      expect(card.nextInstallment, '۱۴۰۴/۰۸/۰۲');
      expect(card.progress, .7);
      for (final action in LoanAction.values) {
        await tap(
          tester,
          find.byKey(Key('app_service_grid_icon_loans-${action.id}')),
        );
        expect(request?.action, action);
        expect(request?.loan.id, 'b');
      }
      await tester.tap(inLoan('b', 'app_arrow_button'));
      await tester.pumpAndSettle();
      expect(details?.id, 'b');
    },
  );

  testWidgets('RTL swipe selects the next loan', (tester) async {
    BankLoan? selected;
    await mount(
      tester,
      subject(
        loanScope(
          repository: MockDashboardLoansRepository(loans: sample),
          onSelectedLoanChanged: (value) => selected = value,
        ),
      ),
    );
    await tester.drag(
      dashboardCarousel(DashboardLoansCarousel),
      const Offset(300, 0),
    );
    await tester.pumpAndSettle();
    expect(selected?.id, 'b');
  });

  testWidgets(
    'copy overrides and platform clipboard preserve raw loan number',
    (tester) async {
      String? copied;
      await mount(
        tester,
        subject(
          loanScope(
            repository: MockDashboardLoansRepository(loans: const [first]),
            onCopyNumber: (value) => copied = value,
          ),
        ),
      );
      await tap(tester, find.byKey(Key('app_loan_card_copy')));
      expect(copied, '001-123');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
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
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        subject(
          loanScope(repository: MockDashboardLoansRepository(loans: [second])),
        ),
      );
      await tester.pumpAndSettle();
      await tap(tester, find.byKey(Key('app_loan_card_copy')));
      expect(copied, '002-456');
    },
  );

  testWidgets(
    'selected loan survives reorder and removal resets the carousel',
    (tester) async {
      final repository = TestRepositories()..loans = const Success(sample);
      await mount(tester, subject(loanScope(repository: repository)));
      await tap(tester, dashboardIndicator(DashboardLoansCarousel, 1));
      final cubit = tester
          .element(find.byType(DashboardLoansCarousel))
          .read<HomeCubit>();
      repository.loans = const Success([second, first]);
      await tester.runAsync(cubit.fetchLoans);
      await tester.pumpAndSettle();
      final controller = tester
          .widget<PageView>(dashboardCarousel(DashboardLoansCarousel))
          .controller!;
      expect(controller.page, 0);
      repository.loans = const Success([first]);
      await tester.runAsync(cubit.fetchLoans);
      await tester.pumpAndSettle();
      expect(
        tester.widget<AppLoanCard>(find.byType(AppLoanCard)).loanNumber,
        '001-123',
      );
      repository.loans = const Success([]);
      await tester.runAsync(cubit.fetchLoans);
      await tester.pumpAndSettle();
      expect(find.byType(AppLoanCard), findsNothing);
      expect(dashboardGroup(S.current.loansOperations), findsNothing);
      expect(find.byType(AppPrimaryNavigation), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'all four tabs retain selection; back returns to dashboard; details stay contextual',
    (tester) async {
      LoanActionRequest? request;
      BankLoan? details;
      await mount(
        tester,
        subject(
          dashboardScope(
            repositories: dashboardTestRepositories(loans: sample),
            onLoanActionRequested: (value) => request = value,
            onLoanDetailsRequested: (value) => details = value,
          ),
        ),
      );
      await tap(
        tester,
        find.descendant(
          of: find.byType(AppPrimaryNavigation),
          matching: find.text(S.current.dashboardLoansTab),
        ),
      );
      await tap(tester, dashboardIndicator(DashboardLoansCarousel, 1));
      await tap(
        tester,
        find.descendant(
          of: find.byType(AppPrimaryNavigation),
          matching: find.text(S.current.dashboardDepositsTab),
        ),
      );
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
          matching: find.text(S.current.dashboardLoansTab),
        ),
      );
      await tap(
        tester,
        find.byKey(Key('app_service_grid_icon_loans-loan-deposit')),
      );
      expect(request?.loan.id, 'b');
      await tester.tap(inLoan('b', 'app_arrow_button'));
      await tester.pumpAndSettle();
      expect(details?.id, 'b');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(DashboardBankServices), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'fallback IDs, assistant and default menu integrate with the dashboard',
    (tester) async {
      final ids = <String>[];
      await mount(
        tester,
        subject(
          dashboardScope(
            repositories: defaultDashboardTestRepositories,
            onServiceRequested: ids.add,
          ),
        ),
      );
      await tap(
        tester,
        find.descendant(
          of: find.byType(AppPrimaryNavigation),
          matching: find.text(S.current.dashboardLoansTab),
        ),
      );
      await tap(
        tester,
        find.byKey(Key('app_service_grid_icon_loans-loan-defer')),
      );
      expect(ids.last, 'loan-defer');
      await tap(tester, find.byKey(Key('dashboard_menu_button')));
      expect(find.byType(AppDrawer), findsOneWidget);
      expect(
        tester.widget<AppDrawer>(find.byType(AppDrawer)).expandedItemId,
        isNull,
      );
      await tap(tester, find.byKey(const Key('app_drawer_item_loans')));
      expect(find.text('وام‌های من'), findsWidgets);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tap(tester, find.byType(AppAssistantButton));
      expect(ids.last, 'assistant');
      expect(find.byType(DashboardBankServices), findsOneWidget);
    },
  );

  testWidgets('Home menu effect opens the loan catalog', (tester) async {
    var menus = 0;
    await mount(
      tester,
      subject(
        dashboardScope(
          repositories: defaultDashboardTestRepositories,
          onMenuPressed: () => menus++,
        ),
      ),
    );
    await tap(
      tester,
      find.descendant(
        of: find.byType(AppPrimaryNavigation),
        matching: find.text(S.current.dashboardLoansTab),
      ),
    );
    await tap(tester, find.byKey(Key('dashboard_menu_button')));
    expect(menus, 1);
    expect(find.byType(AppDrawer), findsOneWidget);
  });

  testWidgets(
    'narrow screen with larger text keeps actions and navigation reachable',
    (tester) async {
      LoanActionRequest? request;
      await mount(
        tester,
        subject(
          loanScope(
            repository: MockDashboardLoansRepository(loans: const [first]),
            onActionRequested: (value) => request = value,
          ),
          scale: 1.4,
        ),
        size: const Size(320, 700),
      );
      await tap(
        tester,
        find.byKey(Key('app_service_grid_icon_loans-loan-relationships')),
      );
      expect(request?.action, LoanAction.relationships);
      expect(find.byType(AppPrimaryNavigation), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'single and every carousel loan paint their paid installment ratio',
    (tester) async {
      void verify(BankLoan loan) {
        final card = dashboardLoan(loan.id);
        final indicator = find.descendant(
          of: card,
          matching: find.byType(AppProgressIndicator),
        );
        final track = find.descendant(
          of: indicator,
          matching: find.byType(ClipRRect),
        );
        final fill = find.descendant(
          of: indicator,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color ==
                    AppPalette.brand600,
          ),
        );
        expect(
          tester.widget<AppProgressIndicator>(indicator).value,
          loan.progress,
        );
        final trackRect = tester.getRect(track),
            fillRect = tester.getRect(fill);
        expect(fillRect.height, 8);
        expect(fillRect.width, closeTo(trackRect.width * loan.progress, .01));
        expect(fillRect.left, closeTo(trackRect.left, .01));
      }

      await mount(
        tester,
        subject(
          loanScope(
            repository: MockDashboardLoansRepository(
              loans: [DashboardMockData.singleLoan],
            ),
          ),
        ),
      );
      verify(DashboardMockData.singleLoan);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        subject(
          loanScope(
            repository: MockDashboardLoansRepository(
              loans: DashboardMockData.loans,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var index = 0; index < DashboardMockData.loans.length; index++) {
        await tap(tester, dashboardIndicator(DashboardLoansCarousel, index));
        verify(DashboardMockData.loans[index]);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
