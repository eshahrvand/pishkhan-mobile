import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

void main() {
  const lines = [
    AppInvoiceLine(
      id: 'print',
      label: 'هزینه چاپ گزارش',
      amount: '۳۰۰٬۰۰۰',
      icon: Icon(Icons.print_outlined),
    ),
  ];

  Widget buildSubject({
    required bool isExpanded,
    required bool isSufficient,
    ValueChanged<bool>? onExpandedChanged,
  }) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: AppInvoice(
          totalAmount: '۱٬۳۰۰٬۰۰۰',
          walletBalance: '۲٬۰۰۰٬۰۰۰',
          lines: lines,
          isExpanded: isExpanded,
          isWalletBalanceSufficient: isSufficient,
          onExpandedChanged: onExpandedChanged ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('shows only the summary while closed and reports toggle intent', (
    tester,
  ) async {
    bool? requestedExpanded;
    await tester.pumpWidget(
      buildSubject(
        isExpanded: false,
        isSufficient: true,
        onExpandedChanged: (value) => requestedExpanded = value,
      ),
    );

    expect(find.text('هزینه چاپ گزارش'), findsNothing);
    expect(find.text('موجودی کیف پول کافی است'), findsOneWidget);

    await tester.tap(find.text('هزینه قابل پرداخت'));
    expect(requestedExpanded, isTrue);
  });

  testWidgets('renders line details and the insufficient wallet variant', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(isExpanded: true, isSufficient: false),
    );

    expect(find.text('هزینه چاپ گزارش'), findsOneWidget);
    expect(find.text('موجودی کیف پول کافی نیست'), findsOneWidget);
  });
}
