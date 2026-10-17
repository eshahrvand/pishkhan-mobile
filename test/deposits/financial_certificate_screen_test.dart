import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/shared/widgets/app_address_card.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/features/deposits/deposits.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/financial_certificate/cubit/financial_certificate_cubit.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

import 'certificate_test_support.dart';

void main() {
  setUp(configureDependencies);
  tearDown(() => getIt.reset());
  setUpAll(loadCertificateFonts);
  final catalog = MockDepositCertificatesRepository.examples;
  final conditions = FinancialCertificateState.initial(
    deposit: catalog.deposits.first,
    conditions: {
      FinancialCertificateCondition.homeAddress,
      FinancialCertificateCondition.passportNumber,
      FinancialCertificateCondition.exchangeRate,
    },
  );
  final latin = conditions.copyWith(
    step: FinancialCertificateStep.latinIdentity,
    recipient: FinancialCertificateRecipient.embassy,
    embassyId: 'demo-embassy',
    currency: CertificateCurrency.usd,
  );
  final filled = latin.copyWith(
    name: 'Ali',
    surname: 'Raad',
    fatherName: 'Arash',
    passportNumber: '1234567890',
    passportExpiryText: '2026/08/12',
    latinAddress: 'Unit 1, No 12, Shahid Beheshti St, Abbas Abad, Tehran, Iran, 1234567890',
  );
  final frames = <String, FinancialCertificateState>{
    'financial-selection': const FinancialCertificateState.initial(),
    'financial-conditions': FinancialCertificateState.initial(
      deposit: catalog.deposits.first,
    ),
    'financial-conditions-filled': conditions,
    'financial-recipient': conditions.copyWith(
      step: FinancialCertificateStep.recipient,
    ),
    'financial-embassy': conditions.copyWith(
      step: FinancialCertificateStep.recipient,
      recipient: FinancialCertificateRecipient.embassy,
    ),
    'financial-authority': conditions.copyWith(
      step: FinancialCertificateStep.recipient,
      recipient: FinancialCertificateRecipient.otherAuthority,
    ),
    'financial-latin': latin,
    'financial-latin-filled': filled,
    'financial-delivery': filled.copyWith(
      step: FinancialCertificateStep.delivery,
    ),
    'financial-delivery-filled': filled.copyWith(
      step: FinancialCertificateStep.delivery,
      address: catalog.addresses.first,
    ),
    'financial-confirmation': filled.copyWith(
      step: FinancialCertificateStep.confirmation,
      deposit: catalog.deposits[1],
      address: catalog.addresses.first,
    ),
  };
  for (final entry in frames.entries) {
    testWidgets('${entry.key} renders the reference fields and layout', (
      tester,
    ) async {
      await mountCertificate(
        tester,
        FinancialCertificateScreen(initialState: entry.value),
        size: entry.key.startsWith('financial-conditions')
            ? const Size(375, 894)
            : entry.key.startsWith('financial-latin')
            ? const Size(375, 984)
            : const Size(375, 812),
      );
      expect(tester.getTopLeft(find.byType(AppStepper)).dy, 104);
      if (entry.value.step == FinancialCertificateStep.conditions) {
        expect(tester.getTopLeft(find.byType(AppSelect<String>).first).dy, 172);
        expect(
          find.byType(AppCheckbox),
          entry.value.deposit == null ? findsNothing : findsNWidgets(8),
        );
      }
      if (entry.value.step == FinancialCertificateStep.latinIdentity) {
        expect(find.byType(AppTextField), findsNWidgets(6));
        final address = find.byWidgetPredicate(
          (widget) =>
              widget is AppTextField &&
              widget.hintText == S.current.financialLatinAddressHint,
        );
        expect(tester.getSize(address).height, 90);
        expect(find.byType(TextField), findsNWidgets(6));
        expect(tester.getTopLeft(find.byType(AppTextField).first).dy, 238);
        expect(
          tester
              .widget<AppTextField>(find.byType(AppTextField).first)
              .textDirection,
          TextDirection.ltr,
        );
      }
      if (entry.key == 'financial-authority') {
        expect(find.text('مرجع'), findsOneWidget);
        expect(find.text('نام دقیق مرجع را بنویسید'), findsOneWidget);
      }
      if (entry.value.step == FinancialCertificateStep.confirmation) {
        expect(find.byType(AppInvoice), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await captureCertificate(tester, entry.key);
    });
  }
  testWidgets('the five steps submit a mock request with edited Latin fields', (
    tester,
  ) async {
    CertificateReceipt? receipt;
    await mountCertificate(
      tester,
      FinancialCertificateScreen(onCompleted: (value) => receipt = value),
    );
    final cubit = tester
        .element(find.byType(AppStepper))
        .read<FinancialCertificateCubit>();
    await tester.tap(find.byType(AppSelect<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10.1234567.1').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppCheckbox).first);
    await tester.pumpAndSettle();
    final next = find.byWidgetPredicate(
      (w) => w is AppButton && w.label == 'مرحله بعد',
    );
    await tester.tap(next);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppSelect<FinancialCertificateRecipient>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('سفارت').last);
    await tester.pumpAndSettle();
    cubit.selectEmbassy('demo-embassy');
    cubit.selectCurrency(CertificateCurrency.usd);
    await tester.pumpAndSettle();
    await tester.tap(next);
    await tester.pumpAndSettle();
    final values = [
      'Ali',
      'Raad',
      'Arash',
      '1234567890',
      '2026/08/12',
      'Unit 1, Tehran, Iran',
    ];
    for (var i = 0; i < values.length; i++) {
      final input = find.byType(TextField).at(i);
      await tester.ensureVisible(input);
      await tester.enterText(input, values[i]);
      await tester.pumpAndSettle();
    }
    expect(cubit.state.canContinue, isTrue);
    await tester.tap(next);
    await tester.pumpAndSettle();
    cubit.selectAddress('home');
    await tester.pumpAndSettle();
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.byType(AppInvoice), findsOneWidget);
    await tester.tap(find.text('تایید و ثبت درخواست'));
    await tester.pumpAndSettle();
    expect(receipt!.isMock, isTrue);
    expect(find.textContaining('گواهی صادر نشده'), findsOneWidget);
  });
  testWidgets(
    'changing recipient replaces the embassy selector with authority input',
    (tester) async {
      await mountCertificate(
        tester,
        FinancialCertificateScreen(initialState: frames['financial-embassy']!),
      );
      final cubit = tester
          .element(find.byType(AppStepper))
          .read<FinancialCertificateCubit>();
      expect(find.byType(AppSelect<String>), findsOneWidget);
      cubit.selectRecipient(FinancialCertificateRecipient.otherAuthority);
      await tester.pumpAndSettle();
      expect(find.byType(AppSelect<String>), findsNothing);
      await tester.enterText(find.byType(TextField), 'University');
      cubit.selectCurrency(CertificateCurrency.eur);
      await tester.pumpAndSettle();
      expect(cubit.state.canContinue, isTrue);
    },
  );
  testWidgets(
    'delivery adds a validated local address and confirms its deletion',
    (tester) async {
      await mountCertificate(
        tester,
        FinancialCertificateScreen(initialState: frames['financial-delivery']!),
      );
      final cubit = tester
          .element(find.byType(AppStepper))
          .read<FinancialCertificateCubit>();
      await tester.tap(find.text('افزودن آدرس جدید'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ثبت آدرس'));
      await tester.pumpAndSettle();
      expect(
        find.text('عنوان، نشانی کامل و کد پستی ۱۰ رقمی را وارد کنید.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField).at(0), 'دفتر');
      await tester.enterText(
        find.byType(TextField).at(1),
        'تهران، خیابان نمونه، پلاک ۱۲',
      );
      await tester.enterText(find.byType(TextField).at(2), '۱۲۳۴۵۶۷۸۹۰');
      await tester.tap(find.text('ثبت آدرس'));
      await tester.pumpAndSettle();
      expect(cubit.state.address!.title, 'دفتر');
      expect(cubit.state.canContinue, isTrue);
      tester.widget<AppAddressCard>(find.byType(AppAddressCard)).onDeleteTap!();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('app_delete_address_cancel')));
      await tester.pumpAndSettle();
      expect(cubit.state.address, isNotNull);
      tester.widget<AppAddressCard>(find.byType(AppAddressCard)).onDeleteTap!();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('app_delete_address_confirm')));
      await tester.pumpAndSettle();
      expect(cubit.state.address, isNull);
      expect(cubit.state.canContinue, isFalse);
      expect(cubit.state.addresses.any((a) => a.title == 'دفتر'), isFalse);
      expect(tester.takeException(), isNull);
    },
  );
  for (final locale in ['fa', 'en', 'ar']) {
    testWidgets(
      '$locale Latin form fits a compact phone with larger text and keyboard',
      (tester) async {
        await mountCertificate(
          tester,
          FinancialCertificateScreen(initialState: filled),
          size: const Size(320, 640),
          locale: locale,
          scale: 1.3,
        );
        expect(tester.takeException(), isNull);
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -650),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        tester.view.viewInsets = const FakeViewPadding(bottom: 240);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('financial service preserves the originating deposit', (
    tester,
  ) async {
    await mountCertificate(
      tester,
      Builder(
        builder: (context) => AppButton(
          label: 'Financial',
          onPressed: () => ServiceRegistry.openCardService(
            context,
            'deposit-certificate',
            initialDepositNumber: '۱۰.۱۲۳۴۵۶۷.۱',
          ),
        ),
      ),
    );
    await tester.tap(find.text('Financial'));
    await tester.pumpAndSettle();
    expect(find.byType(FinancialCertificateScreen), findsOneWidget);
    expect(
      tester
          .element(find.byType(AppStepper))
          .read<FinancialCertificateCubit>()
          .state
          .deposit!
          .number,
      '10.1234567.1',
    );
  });
}
