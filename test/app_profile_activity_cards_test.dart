import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/shared/widgets/app_occupation_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_request_report_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_transaction_card.dart';

void main() {
  Widget subject(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('occupation card matches content and more action', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      subject(AppOccupationCard(onMoreTap: () => tapped = true)),
    );

    expect(find.text('طراح'), findsOneWidget);
    expect(find.text('UI / UX Designer'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('app_occupation_card'))).width,
      343,
    );
    await tester.tap(find.byKey(const Key('app_occupation_more')));
    expect(tapped, isTrue);
  });

  testWidgets('request report supports details and compact mode', (
    tester,
  ) async {
    await tester.pumpWidget(subject(const AppRequestReportCard()));
    expect(find.text('جزئیات:'), findsOneWidget);
    expect(find.text('لیبل'), findsOneWidget);

    await tester.pumpWidget(
      subject(const AppRequestReportCard(showDetails: false)),
    );
    expect(find.text('جزئیات:'), findsNothing);
    expect(find.text('شناسه:'), findsOneWidget);
  });

  testWidgets('transaction card renders every variant and action', (
    tester,
  ) async {
    const labels = {
      AppTransactionType.discharge: 'دشارژ',
      AppTransactionType.charge: 'شارژ',
      AppTransactionType.transfer: 'انتقال کیف به کیف',
      AppTransactionType.shopping: 'خرید',
    };

    for (final entry in labels.entries) {
      await tester.pumpWidget(
        subject(AppTransactionCard(type: entry.key, onTap: () {})),
      );
      expect(find.text(entry.value), findsOneWidget);
      expect(find.text('20,000,000'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('app_transaction_card'))),
        const Size(361, 72),
      );
    }

    var tapped = false;
    await tester.pumpWidget(
      subject(AppTransactionCard(onTap: () => tapped = true)),
    );
    await tester.tap(find.byKey(const Key('app_transaction_card_action')));
    expect(tapped, isTrue);
  });
}
