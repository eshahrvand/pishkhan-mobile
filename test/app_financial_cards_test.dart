import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/shared/widgets/app_arrow_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_deposit_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_loan_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_resalat_card.dart';

void main() {
  Widget subject(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('renders exact single and multi Resalat card sizes', (
    tester,
  ) async {
    await tester.pumpWidget(subject(const AppResalatCard()));
    expect(
      tester.getSize(find.byKey(const Key('app_resalat_card'))),
      const Size(335, 202),
    );

    await tester.pumpWidget(
      subject(const AppResalatCard(size: AppResalatCardSize.multi)),
    );
    expect(
      tester.getSize(find.byKey(const Key('app_resalat_card'))),
      const Size(316, 191),
    );
  });

  testWidgets('reports Resalat visibility and renders disabled overlay', (
    tester,
  ) async {
    bool? visible;
    await tester.pumpWidget(
      subject(AppResalatCard(onVisibilityChanged: (value) => visible = value)),
    );

    await tester.tap(find.byKey(const Key('app_resalat_card_visibility')));
    expect(visible, isFalse);

    await tester.pumpWidget(subject(const AppResalatCard(isSelected: false)));
    expect(
      find.byKey(const Key('app_resalat_card_disabled_overlay')),
      findsOneWidget,
    );
  });

  testWidgets('renders exact deposit variants and copy action', (tester) async {
    var copied = false;
    await tester.pumpWidget(
      subject(AppDepositCard(onCopyIban: () => copied = true)),
    );
    expect(
      tester.getSize(find.byKey(const Key('app_deposit_card'))),
      const Size(335, 202),
    );
    await tester.tap(find.byKey(const Key('app_deposit_card_copy_iban')));
    expect(copied, isTrue);

    await tester.pumpWidget(
      subject(const AppDepositCard(size: AppDepositCardSize.multi)),
    );
    expect(
      tester.getSize(find.byKey(const Key('app_deposit_card'))),
      const Size(316, 191),
    );
  });

  testWidgets('renders loan geometry and reports arrow action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      subject(AppLoanCard(onArrowPressed: () => tapped = true)),
    );
    expect(
      tester.getSize(find.byKey(const Key('app_loan_card'))),
      const Size(335, 236),
    );
    await tester.tap(find.byKey(const Key('app_arrow_button')));
    expect(tapped, isTrue);

    await tester.pumpWidget(
      subject(const AppLoanCard(size: AppLoanCardSize.multi)),
    );
    expect(
      tester.getSize(find.byKey(const Key('app_loan_card'))),
      const Size(316, 236),
    );
  });

  testWidgets('renders the standalone arrow at 48 pixels', (tester) async {
    await tester.pumpWidget(subject(AppArrowButton(onPressed: () {})));
    expect(
      tester.getSize(find.byKey(const Key('app_arrow_button'))),
      const Size.square(48),
    );
  });
}
