import 'package:pishkhan_mobile/core/di/injection_container.dart';

import '../../../../support/home_tab_test_scope.dart';
import '../../../../support/dashboard_ui_finders.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../../../support/router_test_app.dart';

import 'dart:async';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/dashboard_home_data.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/data/datasources/dashboard_mock_data.dart';

import '../../../../support/dashboard_test_repositories.dart';

Widget subject(Widget child) => TestRouterApp(
  theme: AppTheme.light(),
  locale: const Locale('fa'),
  supportedLocales: S.delegate.supportedLocales,
  localizationsDelegates: const [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  home: child,
);
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
  for (final kind in ['cards', 'deposits', 'loans']) {
    testWidgets(
      '$kind renders error, retries, then renders empty with navigation',
      (tester) async {
        final repository = TestRepositories()
          ..cards = const Err(DataFailure('offline'))
          ..deposits = const Err(DataFailure('offline'))
          ..loans = const Err(DataFailure('offline'));
        final Widget tab = switch (kind) {
          'cards' => cardsScope(repository: repository),
          'deposits' => depositScope(repository: repository),
          _ => loanScope(repository: repository),
        };
        await tester.pumpWidget(subject(tab));
        await tester.pumpAndSettle();
        expect(find.text(S.current.dashboardLoadError), findsOneWidget);
        expect(find.byType(AppPrimaryNavigation), findsOneWidget);
        repository.cards = const Success([]);
        repository.deposits = const Success([]);
        repository.loans = const Success([]);
        await tester.tap(dashboardButton(S.current.dashboardRetry));
        await tester.pumpAndSettle();
        expect(find.text(S.current.dashboardLoadError), findsNothing);
        expect(find.byType(AppPrimaryNavigation), findsOneWidget);
        expect(find.byType(PageView), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'loan loading waits for service; disposing pending view is safe',
    (tester) async {
      final request = Completer<Result<List<BankLoan>>>();
      final repository = TestRepositories()..loanQueue.add(request);
      await tester.pumpWidget(subject(loanScope(repository: repository)));
      await tester.pump();
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppButton &&
              widget.isLoading &&
              widget.label == S.current.dashboardLoading,
        ),
        findsOneWidget,
      );
      expect(find.byType(AppPrimaryNavigation), findsOneWidget);
      request.complete(const Success([DashboardMockData.singleLoan]));
      await tester.pumpAndSettle();
      expect(dashboardLoan('loan-single'), findsOneWidget);
      final pending = Completer<Result<List<BankLoan>>>();
      final replacement = TestRepositories()..loanQueue.add(pending);
      await tester.pumpWidget(subject(loanScope(repository: replacement)));
      await tester.pump();
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppButton &&
              widget.isLoading &&
              widget.label == S.current.dashboardLoading,
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      pending.complete(const Success([]));
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('home repository error retries without blocking other tabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 878);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = TestRepositories()
      ..home = const Err(DataFailure('offline'));
    await tester.pumpWidget(
      subject(
        dashboardScope(
          repositories: DashboardRepositories(
            home: repository,
            cards: repository,
            deposits: repository,
            loans: repository,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(dashboardButton(S.current.dashboardRetry), findsOneWidget);
    await tester.tap(
      find
          .descendant(
            of: find.byType(AppPrimaryNavigation),
            matching: find.text(S.current.dashboardLoansTab),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(dashboardGroup(S.current.loansOperations), findsOneWidget);
    await tester.tap(
      find
          .descendant(
            of: find.byType(AppPrimaryNavigation),
            matching: find.text(S.current.dashboardTab),
          )
          .last,
    );
    await tester.pumpAndSettle();
    repository.home = Success(DashboardHomeData(walletBalance: '123'));
    await tester.tap(dashboardButton(S.current.dashboardRetry));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardBankServices), findsOneWidget);
    expect(dashboardButton(S.current.dashboardRetry), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
