import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:async';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/certificate_data.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/financial_certificate_data.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposit_certificates_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/financial_certificate_repository.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/average_balance/cubit/average_balance_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/average_balance/screens/average_balance_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/financial_certificate/cubit/financial_certificate_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/financial_certificate/screens/financial_certificate_screen.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../support/registered_dependency.dart';
import 'average_balance_cubit_test.dart' show CertificateTestRepository;
import 'certificate_test_support.dart';
import 'financial_certificate_cubit_test.dart' show FinancialTestRepository;

void main() {
  setUpAll(loadCertificateFonts);
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  for (final financial in [false, true]) {
    testWidgets(
      '${financial ? "financial" : "average"} pending submission gates repeated taps and permits Back',
      (tester) async {
        final pending = Completer<Result<CertificateReceipt>>();
        final averageRepository = CertificateTestRepository()
          ..submit = (_) => pending.future;
        final financialRepository = FinancialTestRepository()
          ..submit = (_) => pending.future;
        withRegisteredDependency<DepositCertificatesRepository, void>(
          averageRepository,
          () {},
        );
        withRegisteredDependency<FinancialCertificateRepository, void>(
          financialRepository,
          () {},
        );
        final catalog = averageRepository.catalog;
        await mountCertificate(
          tester,
          financial
              ? FinancialCertificateScreen(
                  initialState: FinancialCertificateState.initial(
                    step: FinancialCertificateStep.confirmation,
                    deposit: catalog.deposits.first,
                    conditions: {FinancialCertificateCondition.homeAddress},
                    recipient: FinancialCertificateRecipient.embassy,
                    embassy: catalog.embassies.first,
                    currency: CertificateCurrency.usd,
                    name: 'Ali',
                    surname: 'Raad',
                    fatherName: 'Arash',
                    passportNumber: '1234567890',
                    passportExpiryText: '2026/08/12',
                    latinAddress: 'Tehran, Iran',
                    address: catalog.addresses.first,
                  ),
                )
              : AverageBalanceScreen(
                  initialState: AverageBalanceState.initial(
                    step: AverageBalanceStep.confirmation,
                    deposit: catalog.deposits.first,
                    language: CertificateLanguage.english,
                    turnover: StatementTurnover.averageBalance,
                    address: catalog.addresses.first,
                  ),
                ),
        );
        final submit = find.byWidgetPredicate(
          (widget) =>
              widget is AppButton && widget.label == S.current.issuanceSubmit,
        );
        await tester.tap(submit);
        await tester.pump();
        await tester.tap(submit);
        await tester.pump();
        expect(
          financial
              ? financialRepository.requests.length
              : averageRepository.requests.length,
          1,
        );
        expect(tester.widget<AppButton>(submit).isLoading, isTrue);

        await tester.tap(find.byTooltip(S.current.backLabel));
        await tester.pump(const Duration(milliseconds: 300));
        final next = find.byWidgetPredicate(
          (widget) =>
              widget is AppButton && widget.label == S.current.issuanceNext,
        );
        expect(next, findsOneWidget);
        expect(tester.widget<AppButton>(next).isLoading, isTrue);
        await tester.tap(find.byType(AppToggle).first, warnIfMissed: false);
        await tester.pump();
        final context = tester.element(find.byType(AppStepper));
        expect(
          financial
              ? context.read<FinancialCertificateCubit>().state.isOtherRecipient
              : context.read<AverageBalanceCubit>().state.isOtherRecipient,
          isFalse,
        );

        pending.complete(const Err(UnexpectedFailure()));
        await tester.pumpAndSettle();
        expect(tester.widget<AppButton>(next).isLoading, isFalse);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
