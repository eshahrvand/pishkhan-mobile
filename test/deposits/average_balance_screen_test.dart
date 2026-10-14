import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/flow/service_registry.dart';
import 'package:pishkhan_mobile/features/deposits/deposits.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/average_balance/cubit/average_balance_cubit.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

import 'certificate_test_support.dart';

void main() {
  setUpAll(loadCertificateFonts);
  final catalog = MockDepositCertificatesRepository.examples;
  final conditions = AverageBalanceState.initial(
    deposit: catalog.deposits.first,
    language: CertificateLanguage.english,
    turnover: StatementTurnover.depositsAndWithdrawals,
    fromDate: DateTime.utc(2025, 3, 21),
    toDate: DateTime.utc(2025, 12, 21),
  );
  final frames = <String, AverageBalanceState>{
    'average-selection': const AverageBalanceState.initial(),
    'average-conditions': AverageBalanceState.initial(
      deposit: catalog.deposits.first,
    ),
    'average-filled': conditions,
    'average-address': conditions.copyWith(step: AverageBalanceStep.delivery),
    'average-delivery-filled': conditions.copyWith(
      step: AverageBalanceStep.delivery,
      address: catalog.addresses.first,
      otherRecipient: true,
      includeAgent: true,
    ),
    'average-confirmation': conditions.copyWith(
      step: AverageBalanceStep.confirmation,
      deposit: catalog.deposits[1],
      address: catalog.addresses.first,
    ),
  };
  for (final entry in frames.entries) {
    testWidgets('${entry.key} matches layout and reference fields', (
      tester,
    ) async {
      await mountCertificate(
        tester,
        AverageBalanceScreen(initialState: entry.value),
        size: entry.key == 'average-delivery-filled'
            ? const Size(375, 956)
            : const Size(375, 812),
      );
      expect(tester.getTopLeft(find.byType(AppStepper)).dy, 104);
      if (entry.value.step == AverageBalanceStep.conditions) {
        expect(tester.getTopLeft(find.byType(AppSelect<String>).first).dy, 172);
      }
      if (entry.value.step == AverageBalanceStep.confirmation) {
        expect(find.byType(AppInvoice), findsOneWidget);
      }
      if (entry.key == 'average-address') {
        expect(find.text('افزودن آدرس جدید'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await captureCertificate(tester, entry.key);
    });
  }
  testWidgets(
    'conditions, optional dates, delivery, invoice and mock submission form one flow',
    (tester) async {
      CertificateReceipt? receipt;
      await mountCertificate(
        tester,
        AverageBalanceScreen(onCompleted: (value) => receipt = value),
      );
      final context = tester.element(find.byType(AppStepper));
      final cubit = context.read<AverageBalanceCubit>();
      await tester.tap(find.byType(AppSelect<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('10.1234567.1').last);
      await tester.pumpAndSettle();
      expect(find.byType(AppSelect<CertificateLanguage>), findsOneWidget);
      cubit.selectLanguage(CertificateLanguage.english);
      cubit.selectTurnover(StatementTurnover.depositsAndWithdrawals);
      await tester.pumpAndSettle();
      final next = find.byWidgetPredicate(
        (w) => w is AppButton && w.label == 'مرحله بعد',
      );
      await tester.tap(next);
      await tester.pumpAndSettle();
      cubit.selectAddress('home');
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(find.byType(AppInvoice), findsOneWidget);
      cubit.expandInvoice(false);
      await tester.pumpAndSettle();
      expect(
        tester.widget<AppInvoice>(find.byType(AppInvoice)).isExpanded,
        isFalse,
      );
      await tester.tap(find.text('تایید و ثبت درخواست'));
      await tester.pumpAndSettle();
      expect(receipt!.isMock, isTrue);
      expect(find.textContaining('گواهی صادر نشده'), findsOneWidget);
    },
  );
  for (final locale in ['fa', 'en', 'ar']) {
    testWidgets('$locale delivery on a compact phone supports larger text', (
      tester,
    ) async {
      await mountCertificate(
        tester,
        AverageBalanceScreen(initialState: frames['average-delivery-filled']!),
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
    });
  }
  testWidgets(
    'statement service and deposit action preserve selected account',
    (tester) async {
      await mountCertificate(
        tester,
        Builder(
          builder: (context) => AppButton(
            label: 'Statement',
            onPressed: () => ServiceRegistry.openCardService(
              context,
              'deposit-statement',
              initialDepositNumber: '۱۰.۱۲۳۴۵۶۷.۱',
            ),
          ),
        ),
      );
      await tester.tap(find.text('Statement'));
      await tester.pumpAndSettle();
      expect(find.byType(AverageBalanceScreen), findsOneWidget);
      final context = tester.element(find.byType(AppStepper));
      expect(
        context.read<AverageBalanceCubit>().state.deposit!.number,
        '10.1234567.1',
      );
    },
  );
}
