import 'dart:async';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/dashboard/dashboard.dart';
import 'package:pishkhan_mobile/features/dashboard/data/mock/dashboard_mock_data.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/cards/cards_tab.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/deposits/deposits_tab.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/loans/loans_tab.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

import 'support/dashboard_test_repositories.dart';

Widget subject(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  locale: const Locale('fa'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: child,
);
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
  for (final kind in ['cards', 'deposits', 'loans']) {
    testWidgets(
      '$kind renders error, retries, then renders empty with navigation',
      (tester) async {
        final repository = TestRepositories()
          ..cards = const Err(DataFailure('offline'))
          ..deposits = const Err(DataFailure('offline'))
          ..loans = const Err(DataFailure('offline'));
        final Widget tab = switch (kind) {
          'cards' => CardsTab(repository: repository),
          'deposits' => DepositsTab(repository: repository),
          _ => LoansTab(repository: repository),
        };
        await tester.pumpWidget(subject(tab));
        await tester.pumpAndSettle();
        expect(find.byKey(Key('${kind}_error')), findsOneWidget);
        expect(find.byKey(Key('${kind}_navigation')), findsOneWidget);
        repository.cards = const Success([]);
        repository.deposits = const Success([]);
        repository.loans = const Success([]);
        await tester.tap(find.byKey(const Key('dashboard_retry')));
        await tester.pumpAndSettle();
        expect(find.byKey(Key('${kind}_error')), findsNothing);
        expect(find.byKey(Key('${kind}_navigation')), findsOneWidget);
        expect(find.byKey(Key('${kind}_carousel')), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'loan loading waits for service; disposing pending view is safe',
    (tester) async {
      final request = Completer<Result<List<BankLoan>>>();
      final repository = TestRepositories()..loanQueue.add(request);
      await tester.pumpWidget(subject(LoansTab(repository: repository)));
      await tester.pump();
      expect(find.byKey(const Key('loans_loading')), findsOneWidget);
      expect(find.byKey(const Key('loans_navigation')), findsOneWidget);
      request.complete(const Success([DashboardMockData.singleLoan]));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('loan_card_loan-single')), findsOneWidget);
      final pending = Completer<Result<List<BankLoan>>>();
      final replacement = TestRepositories()..loanQueue.add(pending);
      await tester.pumpWidget(subject(LoansTab(repository: replacement)));
      await tester.pump();
      expect(find.byKey(const Key('loans_loading')), findsOneWidget);
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
        DashboardScreen(
          enableAnimations: false,
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
    expect(find.byKey(const Key('dashboard_retry')), findsOneWidget);
    await tester.tap(find.byKey(const Key('primary_tab_loans')).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('loans_operations')), findsOneWidget);
    await tester.tap(find.byKey(const Key('primary_tab_dashboard')).last);
    await tester.pumpAndSettle();
    repository.home = Success(DashboardHomeData(walletBalance: '123'));
    await tester.tap(find.byKey(const Key('dashboard_retry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard_bank_services')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_retry')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
