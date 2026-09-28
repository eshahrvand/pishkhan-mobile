import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_confirmer_details_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_representative_cards.dart';
import 'package:pishkhan_mobile/shared/widgets/app_welcome_card.dart';

void main() {
  Widget subject(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('welcome card matches the Figma dimensions and timer values', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(const AppWelcomeCard(minutes: '11', seconds: '00')),
    );

    expect(
      tester.getSize(find.byKey(const Key('app_welcome_card'))),
      const Size(343, 88),
    );
    expect(find.text('11'), findsOneWidget);
    expect(find.text('00'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('app_welcome_timer'))),
      const Size(66, 28),
    );
  });

  testWidgets('bottom sheet header renders both exact variants', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(const SizedBox(width: 375, child: AppBottomSheetHeader())),
    );
    expect(
      tester.getSize(find.byKey(const Key('app_bottom_sheet_header'))),
      const Size(375, 56),
    );
    expect(find.text('انتخاب کیف پول'), findsOneWidget);

    await tester.pumpWidget(
      subject(
        const SizedBox(
          width: 375,
          child: AppBottomSheetHeader(
            type: AppBottomSheetHeaderType.handleOnly,
          ),
        ),
      ),
    );
    expect(
      tester.getSize(find.byKey(const Key('app_bottom_sheet_header'))),
      const Size(375, 32),
    );
    expect(find.text('انتخاب کیف پول'), findsNothing);
  });

  testWidgets('delete address sheet reports confirm and cancel actions', (
    tester,
  ) async {
    var confirmed = false;
    var cancelled = false;
    await tester.pumpWidget(
      subject(
        AppDeleteAddressSheet(
          address: 'تهران - خیابان شریعتی - پلاک ۴',
          postalCode: '۱۹۴۴۶۲۹۱۲۳',
          onConfirm: () => confirmed = true,
          onCancel: () => cancelled = true,
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('app_delete_address_sheet'))).width,
      375,
    );
    await tester.tap(find.text('حذف و ادامه فرآیند'));
    await tester.tap(find.text('انصراف'));
    expect(confirmed, isTrue);
    expect(cancelled, isTrue);
  });

  testWidgets('confirmer card renders approved and waiting styles', (
    tester,
  ) async {
    await tester.pumpWidget(subject(const AppConfirmerDetailsCard()));
    expect(
      tester.getSize(find.byKey(const Key('app_confirmer_details_card'))),
      const Size(343, 194),
    );
    expect(find.text('بهار مبارک'), findsOneWidget);

    await tester.pumpWidget(
      subject(
        const AppConfirmerDetailsCard(status: AppConfirmerStatus.waiting),
      ),
    );
    expect(find.text('در انتظار تایید'), findsOneWidget);
  });

  testWidgets('representative cards render statuses and more action', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      subject(
        AppMeAsRepresentativeCard(
          status: AppRepresentativeStatus.expired,
          onMorePressed: () => tapped = true,
        ),
      ),
    );
    expect(
      tester.getSize(find.byKey(const Key('app_me_as_representative_card'))),
      const Size(343, 194),
    );
    expect(find.text('منقضی شده'), findsOneWidget);
    await tester.tap(find.byKey(const Key('app_representative_more')));
    expect(tapped, isTrue);

    await tester.pumpWidget(
      subject(
        const AppMyRepresentativeCard(status: AppRepresentativeStatus.waiting),
      ),
    );
    expect(
      tester.getSize(find.byKey(const Key('app_my_representative_card'))),
      const Size(343, 194),
    );
    expect(find.text('در انتظار تایید'), findsOneWidget);
  });
}
