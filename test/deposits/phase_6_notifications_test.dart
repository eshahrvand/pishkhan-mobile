import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_deposit_restrictions_repository.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_surplus_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/data/repositories/mock_deposit_mandate_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/listed_deposit.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/deposit_restriction.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/deposit_mandate.dart';
import 'package:pishkhan_mobile/features/deposits/domain/entities/surplus_deposit_closure.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposit_restrictions_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/surplus_deposits_repository.dart';
import 'package:pishkhan_mobile/features/deposits/domain/repositories/deposit_mandate_repository.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_list/cubit/deposit_list_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_list/screens/deposit_list_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_restriction/cubit/deposit_restriction_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_restriction/screens/deposit_restriction_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_restriction/widgets/deposit_restriction_receipt_dialog.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/close_surplus_deposits/cubit/close_surplus_deposits_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/close_surplus_deposits/screens/close_surplus_deposits_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/close_surplus_deposits/widgets/surplus_deposit_receipt_dialog.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_mandate/cubit/deposit_mandate_cubit.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_mandate/screens/deposit_mandate_screen.dart';
import 'package:pishkhan_mobile/features/deposits/presentation/deposit_mandate/widgets/deposit_mandate_receipt_dialog.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import 'certificate_test_support.dart';

class RetryingListRepository extends MockDepositsRepository {
  bool fail = true;
  @override
  Future<Result<List<ListedDeposit>>> getDeposits() => fail
      ? Future.value(const Err(DataFailure('timeout')))
      : super.getDeposits();
}

class RetryingRestrictionRepository extends MockDepositRestrictionsRepository {
  bool fail = true;
  @override
  Future<Result<DepositRestrictionReceipt>> submitRestriction(
    DepositRestrictionRequest request,
  ) => fail
      ? Future.value(const Err(DataFailure('timeout')))
      : super.submitRestriction(request);
}

class RetryingClosureRepository extends MockSurplusDepositsRepository {
  bool fail = true;
  @override
  Future<Result<SurplusDepositClosureReceipt>> closeSurplusDeposits(
    CloseSurplusDepositsRequest request,
  ) => fail
      ? Future.value(const Err(DataFailure('timeout')))
      : super.closeSurplusDeposits(request);
}

class RetryingDepositMandateRepository extends MockDepositMandateRepository {
  bool fail = true;
  @override
  Future<Result<DepositMandateReceipt>> submitDepositMandate(
    DepositMandateRequest request,
  ) => fail
      ? Future.value(const Err(DataFailure('timeout')))
      : super.submitDepositMandate(request);
}

Future<void> dismissFeedback(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
  expect(find.byType(AvpSnackBar), findsNothing);
}

void main() {
  setUpAll(loadCertificateFonts);
  setUp(configureDependencies);
  tearDown(() => getIt.reset());

  testWidgets(
    'list retry errors repeat and retained text does not intercept filter effects',
    (tester) async {
      final repository = RetryingListRepository();
      await getIt.unregister<DepositsRepository>();
      getIt.registerSingleton<DepositsRepository>(repository);
      await mountCertificate(tester, const DepositListScreen());
      final cubit = tester
          .element(find.byType(AppTopBar))
          .read<DepositListCubit>();
      expect(find.byType(AvpSnackBar), findsOneWidget);
      await dismissFeedback(tester);
      await tester.tap(find.text(S.current.dashboardRetry));
      await tester.pumpAndSettle();
      expect(find.byType(AvpSnackBar), findsOneWidget);
      await dismissFeedback(tester);
      cubit.requestKindFilter();
      await tester.pumpAndSettle();
      expect(find.byType(AppSelectSheet<DepositKind>), findsOneWidget);
      expect(find.byType(AvpSnackBar), findsNothing);
      Navigator.of(tester.element(find.byType(AppSelectSheet<DepositKind>)))
          .pop();
      await tester.pumpAndSettle();
      repository.fail = false;
      final retry = cubit.fetchDeposits();
      await tester.pumpAndSettle();
      await retry;
      expect(cubit.state.depositsStatus, RequestStatus.success);
      expect(cubit.state.failure, isNotNull);
      expect(cubit.state.visibleDeposits, isNotEmpty);
      expect(find.byType(AvpSnackBar), findsNothing);
    },
  );

  testWidgets(
    'restriction repeated failures allow terms and then the success receipt',
    (tester) async {
      final repository = RetryingRestrictionRepository();
      await getIt.unregister<DepositRestrictionsRepository>();
      getIt.registerSingleton<DepositRestrictionsRepository>(repository);
      await mountCertificate(
        tester,
        const DepositRestrictionScreen(
          operation: DepositRestrictionOperation.block,
        ),
      );
      final cubit = tester
          .element(find.byType(AppTopBar))
          .read<DepositRestrictionCubit>();
      cubit.selectDeposit(cubit.state.catalog!.deposits.first);
      cubit.selectReason(cubit.state.catalog!.reasons.first);
      cubit.updateTermsAcceptance(true);
      final key = cubit.state.idempotencyKey;
      for (var i = 0; i < 2; i++) {
        final submission = cubit.submitRestriction();
        await tester.pumpAndSettle();
        await submission;
        expect(find.byType(AvpSnackBar), findsOneWidget);
        await dismissFeedback(tester);
      }
      cubit.requestTerms();
      await tester.pumpAndSettle();
      expect(find.text(S.current.issuanceTermsUnavailable), findsOneWidget);
      await dismissFeedback(tester);
      repository.fail = false;
      final submission = cubit.submitRestriction();
      await tester.pumpAndSettle();
      await submission;
      expect(cubit.state.idempotencyKey, key);
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(cubit.state.failure, isNotNull);
      expect(find.byType(DepositRestrictionReceiptDialog), findsOneWidget);
      expect(find.byType(AvpSnackBar), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'closure repeated failures retain the reviewed payload and allow receipt effects',
    (tester) async {
      final repository = RetryingClosureRepository();
      await getIt.unregister<SurplusDepositsRepository>();
      getIt.registerSingleton<SurplusDepositsRepository>(repository);
      await mountCertificate(tester, const CloseSurplusDepositsScreen());
      final cubit = tester
          .element(find.byType(AppTopBar))
          .read<CloseSurplusDepositsCubit>();
      cubit.selectPrimaryDeposit(cubit.state.deposits.first);
      cubit.updateTermsAcceptance(true);
      final key = cubit.state.idempotencyKey;
      for (var i = 0; i < 2; i++) {
        final submission = cubit.continueFlow();
        await tester.pumpAndSettle();
        await submission;
        expect(find.byType(AvpSnackBar), findsOneWidget);
        await dismissFeedback(tester);
      }
      cubit.requestTerms();
      await tester.pumpAndSettle();
      expect(find.text(S.current.issuanceTermsUnavailable), findsOneWidget);
      await dismissFeedback(tester);
      repository.fail = false;
      final submission = cubit.continueFlow();
      await tester.pumpAndSettle();
      await submission;
      expect(cubit.state.idempotencyKey, key);
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(cubit.state.failure, isNotNull);
      expect(find.byType(SurplusDepositReceiptDialog), findsOneWidget);
      expect(find.byType(AvpSnackBar), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'deposit mandate repeated failures keep selections and terms/receipt execute independently',
    (tester) async {
      final repository = RetryingDepositMandateRepository();
      await getIt.unregister<DepositMandateRepository>();
      getIt.registerSingleton<DepositMandateRepository>(repository);
      await mountCertificate(
        tester,
        const DepositMandateScreen(initialDepositNumber: '10.1234567.2'),
      );
      final cubit = tester
          .element(find.byType(AppTopBar))
          .read<DepositMandateCubit>();
      cubit.selectSubject(cubit.state.subjects.first);
      cubit.updateTermsAcceptance(true);
      final key = cubit.state.idempotencyKey;
      final subject = cubit.state.subject;
      for (var i = 0; i < 2; i++) {
        final submission = cubit.submitDepositMandate();
        await tester.pumpAndSettle();
        await submission;
        expect(find.byType(AvpSnackBar), findsOneWidget);
        await dismissFeedback(tester);
      }
      cubit.requestTerms();
      await tester.pumpAndSettle();
      expect(find.text(S.current.issuanceTermsUnavailable), findsOneWidget);
      await dismissFeedback(tester);
      repository.fail = false;
      final submission = cubit.submitDepositMandate();
      await tester.pumpAndSettle();
      await submission;
      expect(cubit.state.idempotencyKey, key);
      expect(cubit.state.subject, subject);
      expect(cubit.state.submissionStatus, RequestStatus.success);
      expect(cubit.state.failure, isNotNull);
      expect(find.byType(DepositMandateReceiptDialog), findsOneWidget);
      expect(find.byType(AvpSnackBar), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
