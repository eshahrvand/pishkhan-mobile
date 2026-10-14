import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/shared/widgets/app_cards_list.dart';

void main() {
  Widget buildSubject({
    required AppCardsListType type,
    VoidCallback? onMoreTap,
  }) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(
          width: 343,
          child: AppCardsList(
            type: type,
            cardNumber: '۵۰۴۱۷۲۱۴۵۶۷۸۳۴۰۷',
            linkedDeposit: '۱۰-۱۲۲-۱۲۳۴۵۶۷-۱',
            onMoreTap: onMoreTap,
          ),
        ),
      ),
    ),
  );

  testWidgets('renders the Resalat card details', (tester) async {
    await tester.pumpWidget(buildSubject(type: AppCardsListType.resalat));

    expect(find.text('رسالت کارت'), findsOneWidget);
    expect(find.text('۵۰۴۱۷۲۱۴۵۶۷۸۳۴۰۷'), findsOneWidget);
    expect(find.text('سپرده متصل'), findsOneWidget);
  });

  testWidgets('uses the selected Figma type and reports the more action', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      buildSubject(
        type: AppCardsListType.virtual,
        onMoreTap: () => tapped = true,
      ),
    );

    expect(find.text('کارت مجازی'), findsOneWidget);
    await tester.tap(find.byType(InkWell).first);
    expect(tapped, isTrue);
  });
}
