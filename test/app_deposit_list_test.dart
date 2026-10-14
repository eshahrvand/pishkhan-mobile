import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/shared/widgets/app_deposit_list.dart';

void main() {
  Widget buildSubject({VoidCallback? onMoreTap}) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(
          width: 343,
          child: AppDepositList(
            title: 'پس انداز حقیقی',
            accountNumber: '۱۰-۱۲۲-۱۲۳۴۵۶۷-۱',
            onMoreTap: onMoreTap,
          ),
        ),
      ),
    ),
  );

  testWidgets('renders deposit details and open status', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('پس انداز حقیقی'), findsOneWidget);
    expect(find.text('۱۰-۱۲۲-۱۲۳۴۵۶۷-۱'), findsOneWidget);
    expect(find.text('باز'), findsOneWidget);
  });

  testWidgets('reports a tap on the more action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(buildSubject(onMoreTap: () => tapped = true));

    await tester.tap(find.byType(InkWell).first);
    expect(tapped, isTrue);
  });
}
