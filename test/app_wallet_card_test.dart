import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/shared/widgets/app_wallet_card.dart';

void main() {
  Widget buildSubject({required AppWalletCardType type, VoidCallback? onTap}) =>
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 343,
              child: AppWalletCard(
                balance: '۱٬۲۰۰٬۰۰۰',
                type: type,
                onTap: onTap,
              ),
            ),
          ),
        ),
      );

  testWidgets('renders the mobile wallet balance in one row', (tester) async {
    await tester.pumpWidget(buildSubject(type: AppWalletCardType.mobile));

    expect(find.text('موجودی کیف پول'), findsOneWidget);
    expect(find.text('۱٬۲۰۰٬۰۰۰'), findsOneWidget);
    expect(find.text('ریال'), findsOneWidget);
  });

  testWidgets('renders the desktop layout and reports a tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      buildSubject(type: AppWalletCardType.desktop, onTap: () => tapped = true),
    );

    await tester.tap(find.text('موجودی کیف پول'));
    expect(tapped, isTrue);
  });
}
