import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_agent_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/agent_request.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/certificate_data.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/financial_certificate_data.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/agent_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/agent_settings_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposit_certificates_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/financial_certificate_repository.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/average_balance/cubit/average_balance_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/average_balance/screens/average_balance_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/financial_certificate/cubit/financial_certificate_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/financial_certificate/screens/financial_certificate_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/shared/certificate_receipt_dialog.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/introduce_agent/cubit/agent_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/introduce_agent/screens/introduce_agent_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/introduce_agent/widgets/agent_sheet.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/introduce_agent/widgets/agent_receipt_dialog.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/agent_settings/cubit/agent_settings_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/agent_settings/screens/agent_settings_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/agent_settings/widgets/agent_kind_filter.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import 'average_balance_cubit_test.dart' show CertificateTestRepository;
import 'financial_certificate_cubit_test.dart' show FinancialTestRepository;
import 'agent_cubit_test.dart' show fillAgent;
import 'agent_settings_cubit_test.dart' show ControlledAgentRepository;
import 'certificate_test_support.dart';

class RetryingAgentRepository extends MockAgentRepository {
  bool fail = true;
  final requests = <AgentRequest>[];
  @override
  Future<Result<AgentReceipt>> submit(AgentRequest request) {
    requests.add(request);
    return fail
        ? Future.value(const Err(DataFailure('timeout')))
        : super.submit(request);
  }
}

Future<void> dismissFeedback(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
  expect(find.byType(SnackBar), findsNothing);
}

void main() {
  setUpAll(loadCertificateFonts);
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  for (final financial in [false, true]) {
    testWidgets(
      '${financial ? 'financial' : 'average'} repeated failures, effects and success retain canonical retry identity',
      (tester) async {
        var fail = true;
        final average = CertificateTestRepository()
          ..submit = (_) async => fail
              ? const Err(UnexpectedFailure())
              : const Success(
                  CertificateReceipt(reference: 'phase7-success', isMock: true),
                );
        final solvency = FinancialTestRepository()
          ..submit = (_) async => fail
              ? const Err(UnexpectedFailure())
              : const Success(
                  CertificateReceipt(reference: 'phase7-success', isMock: true),
                );
        await getIt.unregister<DepositCertificatesRepository>();
        getIt.registerSingleton<DepositCertificatesRepository>(average);
        await getIt.unregister<FinancialCertificateRepository>();
        getIt.registerSingleton<FinancialCertificateRepository>(solvency);
        var completions = 0;
        final catalog = average.catalog;
        await mountCertificate(
          tester,
          financial
              ? FinancialCertificateScreen(
                  onCompleted: (_) => completions++,
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
                  onCompleted: (_) => completions++,
                  initialState: AverageBalanceState.initial(
                    step: AverageBalanceStep.confirmation,
                    deposit: catalog.deposits.first,
                    language: CertificateLanguage.english,
                    turnover: StatementTurnover.averageBalance,
                    address: catalog.addresses.first,
                  ),
                ),
        );
        for (var attempt = 0; attempt < 2; attempt++) {
          await tester.tap(
            find.widgetWithText(AppButton, S.current.issuanceSubmit),
          );
          await tester.pumpAndSettle();
          expect(find.byType(SnackBar), findsOneWidget);
          expect(completions, 0);
          await dismissFeedback(tester);
        }
        final context = tester.element(find.byType(AppTopBar));
        if (financial) {
          context.read<FinancialCertificateCubit>().requestBack();
          context.read<FinancialCertificateCubit>().updateIncludeAgent(true);
          context.read<FinancialCertificateCubit>().updateAgentIdentifier(
            '123',
          );
          context.read<FinancialCertificateCubit>().requestAgentLookup();
        } else {
          context.read<AverageBalanceCubit>().requestBack();
          context.read<AverageBalanceCubit>().updateIncludeAgent(true);
          context.read<AverageBalanceCubit>().updateAgentIdentifier('123');
          context.read<AverageBalanceCubit>().requestAgentLookup();
        }
        await tester.pumpAndSettle();
        expect(
          find.text(S.current.certificateAgentUnavailable),
          findsOneWidget,
        );
        await dismissFeedback(tester);
        // Hidden optional form edits do not change the serialized request.
        if (financial) {
          context.read<FinancialCertificateCubit>().updateIncludeAgent(false);
          await context.read<FinancialCertificateCubit>().continueFlow();
        } else {
          context.read<AverageBalanceCubit>().updateIncludeAgent(false);
          await context.read<AverageBalanceCubit>().continueFlow();
        }
        await tester.pumpAndSettle();
        fail = false;
        await tester.tap(
          find.widgetWithText(AppButton, S.current.issuanceSubmit),
        );
        await tester.pumpAndSettle();
        expect(completions, 1);
        expect(find.byType(CertificateReceiptDialog), findsOneWidget);
        expect(find.textContaining('phase7-success'), findsOneWidget);
        expect(find.byType(SnackBar), findsNothing);
        if (financial) {
          expect(
            solvency.requests.map((r) => r.idempotencyKey).toSet(),
            hasLength(1),
          );
          expect(
            context.read<FinancialCertificateCubit>().state.failure,
            isNotNull,
          );
        } else {
          expect(
            average.requests.map((r) => r.idempotencyKey).toSet(),
            hasLength(1),
          );
          expect(context.read<AverageBalanceCubit>().state.failure, isNotNull);
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'agent repeat failures allow another draft sheet and successful receipt without replay',
    (tester) async {
      final repository = RetryingAgentRepository();
      await getIt.unregister<AgentRepository>();
      getIt.registerSingleton<AgentRepository>(repository);
      await mountCertificate(tester, const IntroduceAgentScreen());
      final cubit = tester.element(find.byType(AppTopBar)).read<AgentCubit>();
      fillAgent(cubit);
      cubit.saveDraft();
      cubit.updateTermsAcceptance(true);
      await tester.pumpAndSettle();
      for (var attempt = 0; attempt < 2; attempt++) {
        await tester.tap(
          find.widgetWithText(AppButton, S.current.issuanceSubmit),
        );
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsOneWidget);
        await dismissFeedback(tester);
      }
      await tester.tap(find.text(S.current.agentAddNext));
      await tester.pumpAndSettle();
      expect(find.byType(AgentSheet), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      fillAgent(cubit, date: '۱۴۱۱/۰۱/۰۱');
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.agentCancel));
      await tester.pumpAndSettle();
      expect(cubit.state.agents, hasLength(1));
      repository.fail = false;
      await tester.tap(
        find.widgetWithText(AppButton, S.current.issuanceSubmit),
      );
      await tester.pumpAndSettle();
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(repository.requests.toSet(), hasLength(1));
      expect(cubit.state.failure, isNotNull);
      expect(find.byType(AgentReceiptDialog), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'agent-settings retry errors repeat; successful list and cancelled filter do not replay them',
    (tester) async {
      final repository = ControlledAgentRepository();
      await getIt.unregister<AgentSettingsRepository>();
      getIt.registerSingleton<AgentSettingsRepository>(repository);
      await mountCertificate(tester, const AgentSettingsScreen());
      final cubit = tester
          .element(find.byType(AppTopBar))
          .read<AgentSettingsCubit>();
      expect(find.byType(SnackBar), findsOneWidget);
      await dismissFeedback(tester);
      await tester.tap(find.text(S.current.dashboardRetry));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      await dismissFeedback(tester);
      repository.fails = false;
      final retry = cubit.fetchAgents();
      await tester.pumpAndSettle();
      await retry;
      final visible = cubit.state.visibleAgents;
      expect(cubit.state.failure, isNotNull);
      expect(find.byType(SnackBar), findsNothing);
      cubit.requestKindFilter();
      await tester.pumpAndSettle();
      expect(find.byType(AgentKindFilter), findsOneWidget);
      cubit.toggleAllDraftKinds();
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(AgentKindFilter))).pop();
      await tester.pumpAndSettle();
      expect(cubit.state.kindFilter, isNull);
      expect(cubit.state.visibleAgents, visible);
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
