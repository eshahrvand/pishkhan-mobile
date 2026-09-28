import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/shared/widgets/app_address_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_cards_list.dart';
import 'package:pishkhan_mobile/shared/widgets/app_credit_card_mockup.dart';
import 'package:pishkhan_mobile/shared/widgets/app_file_upload_base.dart';
import 'package:pishkhan_mobile/shared/widgets/app_transfer_destination_card.dart';

void main() {
  Widget subject(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('banking mockup renders variants and actions', (tester) async {
    var activated = false;
    await tester.pumpWidget(
      subject(
        AppCreditCardMockup(
          channel: AppBankingChannel.web,
          onActivate: () => activated = true,
        ),
      ),
    );

    expect(find.text('اینترنت بانک'), findsOneWidget);
    expect(find.text('نیاز به فعالسازی'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('app_credit_card_mockup'))),
      const Size(343, 136),
    );
    await tester.tap(find.byKey(const Key('app_credit_card_mockup_activate')));
    expect(activated, isTrue);

    await tester.pumpWidget(
      subject(
        const AppCreditCardMockup(state: AppCreditCardMockupState.wallet),
      ),
    );
    expect(find.text('موجودی'), findsOneWidget);
    expect(find.text('سپرده متصل'), findsOneWidget);
  });

  testWidgets('file upload renders all states and delete action', (
    tester,
  ) async {
    await tester.pumpWidget(subject(const AppFileUploadBase()));
    expect(find.text('بارگذاری فایل اینجا'), findsOneWidget);
    expect(find.textContaining('فرمت فایل'), findsOneWidget);

    var deleted = false;
    await tester.pumpWidget(
      subject(
        AppFileUploadBase(
          state: AppFileUploadState.uploading,
          onDelete: () => deleted = true,
        ),
      ),
    );
    expect(find.text('40%'), findsOneWidget);
    await tester.tap(find.byKey(const Key('app_file_upload_delete')));
    expect(deleted, isTrue);

    await tester.pumpWidget(
      subject(const AppFileUploadBase(state: AppFileUploadState.uploaded)),
    );
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('transfer card follows internal and Paya rows', (tester) async {
    await tester.pumpWidget(subject(const AppTransferDestinationCard()));
    expect(find.text('داخلی'), findsOneWidget);
    expect(find.text('بابت'), findsNothing);

    await tester.pumpWidget(
      subject(const AppTransferDestinationCard(method: AppTransferMethod.paya)),
    );
    expect(find.text('پایا'), findsOneWidget);
    expect(find.text('بابت'), findsOneWidget);
    expect(find.text('شناسه واریز'), findsOneWidget);
  });

  testWidgets('address card exposes Home-only review action', (tester) async {
    var reviewed = false;
    await tester.pumpWidget(
      subject(AppAddressCard(onReviewTap: () => reviewed = true)),
    );
    expect(find.text('خانه'), findsOneWidget);
    expect(find.text('بررسی'), findsOneWidget);
    await tester.tap(find.byKey(const Key('app_address_review')));
    expect(reviewed, isTrue);

    await tester.pumpWidget(
      subject(const AppAddressCard(type: AppAddressType.work)),
    );
    expect(find.text('محل کار'), findsOneWidget);
    expect(find.text('بررسی'), findsNothing);
  });

  testWidgets('cards list still renders every requested type', (tester) async {
    for (final type in AppCardsListType.values) {
      await tester.pumpWidget(
        subject(
          AppCardsList(
            type: type,
            cardNumber: '۵۰۴۱۷۲۱۴۵۶۷۸۳۴۰۷',
            linkedDeposit: '۱۰-۱۲۲-۱۲۳۴۵۶۷-۱',
          ),
        ),
      );
      expect(find.byType(AppCardsList), findsOneWidget);
    }
  });
}
