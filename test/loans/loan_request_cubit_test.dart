import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/loans/data/repositories/mock_loan_application_repository.dart';
import 'package:pishkhan_mobile/features/loans/domain/entities/loan_application.dart';
import 'package:pishkhan_mobile/features/loans/presentation/request/cubit/loan_request_cubit.dart';

import 'loan_test_dependencies.dart';

Future<void> assess(LoanRequestCubit cubit, {int amount = 500000000}) async {
  await cubit.fetchCatalog();
  await cubit.continueFlow();
  await cubit.selectDeposit(cubit.state.catalog!.deposits.first);
  if (amount != 500000000) {
    await cubit.updateAmount((amount - 1000000) / 4999000000);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() async {
    await getIt.reset();
  });

  test('slider feedback changes before an outstanding quote finishes and stale responses cannot undo it', () async {
    final repository = DelayedQuoteRepository();
    await installLoanDependencies(repository);
    final cubit = LoanRequestCubit();
    await cubit.fetchCatalog();
    await cubit.continueFlow();
    final selected = cubit.selectDeposit(cubit.state.catalog!.deposits.first);
    repository.results[0].complete(
      await repository.resolve(repository.inputs[0]),
    );
    await selected;
    final previous = cubit.state.quote;
    final red = cubit.updateAmount(.9);
    expect(cubit.state.assessment!.range, LoanCreditRange.unsuitable);
    expect(cubit.state.quoteStatus, RequestStatus.loading);
    expect(cubit.state.quote, same(previous));
    expect(cubit.state.canContinue, false);
    final green = cubit.updateAmount(.1);
    expect(cubit.state.assessment!.range, LoanCreditRange.excellent);
    repository.results[1].complete(
      await repository.resolve(repository.inputs[1]),
    );
    await red;
    expect(cubit.state.assessment!.range, LoanCreditRange.excellent);
    expect(cubit.state.quote, same(previous));
    repository.results[2].complete(
      await repository.resolve(repository.inputs[2]),
    );
    await green;
    expect(cubit.state.quote!.range, cubit.state.assessment!.range);
    expect(cubit.state.canContinue, true);
    await cubit.close();
  });

  test('construction preserves the supplied initial snapshot', () async {
    await installLoanDependencies(
      MockLoanApplicationRepository(delay: Duration.zero),
    );
    const initial = LoanRequestState.initial(
      amountRial: 123456789,
      isCreditExpanded: true,
    );
    final cubit = LoanRequestCubit(initialState: initial);
    expect(cubit.state, same(initial));
    await cubit.close();
  });

  for (final tier in [
    LoanCreditTier.unknown,
    LoanCreditTier.excellent,
    LoanCreditTier.fullySuitable,
    LoanCreditTier.suitable,
  ]) {
    test(
      '$tier computes appropriate range and collateral requirements',
      () async {
        await installLoanDependencies(
          MockLoanApplicationRepository(tier: tier, delay: Duration.zero),
        );
        final cubit = LoanRequestCubit();
        await assess(cubit);
        expect(cubit.state.quote!.range, switch (tier) {
          LoanCreditTier.unknown => LoanCreditRange.unknown,
          LoanCreditTier.excellent => LoanCreditRange.excellent,
          LoanCreditTier.fullySuitable => LoanCreditRange.fullySuitable,
          _ => LoanCreditRange.suitable,
        });
        expect(cubit.state.canContinue, tier != LoanCreditTier.unknown);
        expect(
          cubit.state.quote!.needsGuarantor,
          tier == LoanCreditTier.suitable,
        );
        await cubit.close();
      },
    );
  }

  test('amounts cross all ranges, unsuitable cannot continue; lump sum clamps months', () async {
    await installLoanDependencies(
      MockLoanApplicationRepository(delay: Duration.zero),
    );
    final cubit = LoanRequestCubit();
    await assess(cubit, amount: 1500000000);
    expect(cubit.state.quote!.range, LoanCreditRange.fullySuitable);
    await cubit.updateAmount((2500000000 - 1000000) / 4999000000);
    expect(cubit.state.quote!.range, LoanCreditRange.suitable);
    await cubit.updateAmount((3500000000 - 1000000) / 4999000000);
    expect(cubit.state.quote!.range, LoanCreditRange.unsuitable);
    expect(cubit.state.canContinue, false);
    await cubit.updateMonths(1);
    expect(cubit.state.months, 60);
    await cubit.selectRepayment(LoanRepayment.lumpSum);
    expect(cubit.state.months, 10);
    expect(cubit.state.quote!.installments.map((item) => item.amountRial), [
      3500000000,
    ]);
    expect(cubit.state.quote!.monthlyPaymentRial, 0);
    await cubit.close();
  });

  test('only the latest overlapping quote can update assessment', () async {
    final repository = DelayedQuoteRepository();
    await installLoanDependencies(repository);
    final cubit = LoanRequestCubit();
    await cubit.fetchCatalog();
    await cubit.continueFlow();
    final first = cubit.selectDeposit(cubit.state.catalog!.deposits.first);
    final second = cubit.updateAmount(.5);
    repository.results[1].complete(
      await repository.resolve(repository.inputs[1]),
    );
    await second;
    final latest = cubit.state.quote;
    repository.results[0].complete(
      await repository.resolve(repository.inputs[0]),
    );
    await first;
    expect(cubit.state.quote, same(latest));
    await cubit.close();
  });

  test('rejected inquiry disables next and is retryable', () async {
    await installLoanDependencies(
      MockLoanApplicationRepository(
        delay: Duration.zero,
        rejectedInquiry: LoanInquiryKind.bankDebt,
      ),
    );
    final cubit = LoanRequestCubit();
    await assess(cubit);
    await cubit.continueFlow();
    expect(cubit.state.canContinue, false);
    expect(cubit.state.canRetryInquiries, true);
    expect(
      cubit.state.inquiries
          .singleWhere((row) => row.kind == LoanInquiryKind.bankDebt)
          .outcome,
      LoanInquiryOutcome.rejected,
    );
    await cubit.close();
  });

  test('excellent flow signs, retries same OTP failure, retains error and completes to introduction', () async {
    final repo = RetryingSigningRepository();
    await installLoanDependencies(repo);
    final cubit = LoanRequestCubit();
    final failures = <LoanRequestState>[];
    var previousStatus = RequestStatus.initial;
    final subscription = cubit.stream.listen((state) {
      if (previousStatus != state.submissionStatus &&
          state.submissionStatus == RequestStatus.failure) {
        failures.add(state);
      }
      previousStatus = state.submissionStatus;
    });
    await assess(cubit);
    await cubit.continueFlow();
    await cubit.continueFlow();
    expect(cubit.state.step, LoanApplicationStep.contract);
    cubit.updateTermsAccepted(true);
    await cubit.applyContractResult(true);
    expect(cubit.state.effect, LoanRequestEffect.otp);
    cubit.consumeInteraction();
    cubit.updateOtp('99999');
    await cubit.submitLoan();
    final error = cubit.state.message;
    cubit.updateOtp('99999');
    await cubit.submitLoan();
    await Future<void>.delayed(Duration.zero);
    expect(failures.length, 2);
    cubit.updateOtp('54321');
    await cubit.submitLoan();
    expect(cubit.state.submissionStatus, RequestStatus.success);
    expect(cubit.state.message, error);
    cubit.applyOtpResult();
    expect(cubit.state.effect, LoanRequestEffect.receipt);
    await cubit.completeReceipt();
    expect(cubit.state.step, LoanApplicationStep.introduction);
    expect(cubit.state.catalog!.currentDraft, null);
    expect(
      cubit.state.catalog!.latestRecord!.status,
      LoanRecordStatus.readyForPayment,
    );
    await subscription.cancel();
    await cubit.close();
  });

  test('collateral is checked, draft resumes across fresh Cubits, and can be cancelled', () async {
    final repo = MockLoanApplicationRepository(
      delay: Duration.zero,
      tier: LoanCreditTier.fullySuitable,
    );
    await installLoanDependencies(repo);
    final cubit = LoanRequestCubit();
    await assess(cubit);
    await cubit.continueFlow();
    await cubit.continueFlow();
    expect(cubit.state.step, LoanApplicationStep.collateral);
    cubit.updateOwnNumber('1111111111');
    await cubit.continueFlow();
    expect(cubit.state.isCollateralError, true);
    cubit.updateOwnNumber('123456789');
    await cubit.continueFlow();
    expect(cubit.state.step, LoanApplicationStep.contract);
    await cubit.close();
    final resumed = LoanRequestCubit();
    await resumed.fetchCatalog();
    expect(resumed.state.canContinue, false);
    resumed.resumeRequest(resumed.state.catalog!.currentDraft!);
    expect(resumed.state.step, LoanApplicationStep.contract);
    expect(resumed.state.ownNumber, '123456789');
    resumed.requestBack();
    expect(resumed.state.step, LoanApplicationStep.collateral);
    expect(resumed.state.canContinue, true);
    await resumed.close();
    final cancel = LoanRequestCubit();
    await cancel.fetchCatalog();
    await cancel.applyCancelResult(false);
    expect(cancel.state.catalog!.currentDraft, isNotNull);
    await cancel.applyCancelResult(true);
    expect(cancel.state.catalog!.currentDraft, isNull);
    await cancel.close();
  });

  test('changing assessment invalidates checked guarantee and installments sum exactly', () async {
    await installLoanDependencies(
      MockLoanApplicationRepository(
        delay: Duration.zero,
        tier: LoanCreditTier.fullySuitable,
      ),
    );
    final cubit = LoanRequestCubit();
    await assess(cubit);
    await cubit.continueFlow();
    await cubit.continueFlow();
    cubit.updateOwnNumber('123456789');
    await cubit.continueFlow();
    cubit.requestBack();
    cubit.requestBack();
    cubit.requestBack();
    await cubit.updateAmount(.37);
    expect(cubit.state.collateral, null);
    expect(cubit.state.ownNumber, '');
    expect(
      cubit.state.quote!.installments
          .map((item) => item.amountRial)
          .reduce((a, b) => a + b),
      cubit.state.amountRial,
    );
    await cubit.close();
  });

  test(
    'guarantor rejection cases and approved guarantor bind both instruments',
    () async {
      await installLoanDependencies(
        MockLoanApplicationRepository(
          delay: Duration.zero,
          tier: LoanCreditTier.suitable,
        ),
      );
      final cubit = LoanRequestCubit();
      await assess(cubit);
      await cubit.continueFlow();
      await cubit.continueFlow();
      cubit.updateGuarantorNationalId('0081234562');
      expect(cubit.state.canCheckGuarantor, true);
      await cubit.checkGuarantor();
      expect(cubit.state.guarantor!.outcome, LoanGuarantorOutcome.notCustomer);
      cubit.updateGuarantorNationalId('0499370899');
      expect(cubit.state.canCheckGuarantor, true);
      await cubit.checkGuarantor();
      expect(
        cubit.state.guarantor!.outcome,
        LoanGuarantorOutcome.capacityExceeded,
      );
      cubit.updateGuarantorNationalId('0013543921');
      await cubit.checkGuarantor();
      cubit.updateOwnNumber('123456789');
      expect(cubit.state.canContinue, false);
      cubit.updateGuarantorNumber('987654321');
      expect(cubit.state.canContinue, true);
      await cubit.continueFlow();
      expect(cubit.state.step, LoanApplicationStep.contract);
      await cubit.updateInsuranceSelection(true);
      expect(cubit.state.draft!.insuranceSelected, true);
      cubit.requestBack();
      cubit.updateGuarantorNationalId('0499370899');
      expect(cubit.state.guarantorNumber, '');
      expect(cubit.state.canContinue, false);
      await cubit.close();
    },
  );

  test('cancelled contract creates no challenge; retry of final request is idempotent', () async {
    final repo = MockLoanApplicationRepository(delay: Duration.zero);
    await installLoanDependencies(repo);
    final cubit = LoanRequestCubit();
    await assess(cubit);
    await cubit.continueFlow();
    await cubit.continueFlow();
    await cubit.applyContractResult(null);
    expect(cubit.state.challenge, null);
    await cubit.applyContractResult(true);
    final draft = cubit.state.draft!;
    final challenge = cubit.state.challenge!;
    cubit.updateOtp('12345');
    await cubit.submitLoan();
    final repeated = await repo.submit(draft, challenge, '12345');
    expect((repeated as Success<LoanRecord>).data, cubit.state.receipt);
    await cubit.close();
  });

  test(
    'lump-sum examples preserve the inspected ten-month amount bands',
    () async {
      await installLoanDependencies(
        MockLoanApplicationRepository(delay: Duration.zero),
      );
      final cubit = LoanRequestCubit();
      await assess(cubit, amount: 1500000000);
      await cubit.selectRepayment(LoanRepayment.lumpSum);
      await cubit.updateMonths(1 / 3);
      expect(cubit.state.months, 6);
      expect(cubit.state.quote!.range, LoanCreditRange.fullySuitable);
      expect(cubit.state.quote!.needsGuarantor, false);
      await cubit.close();
    },
  );

  test('unexpected signing error leaves loading without marking valid OTP as invalid', () async {
    await installLoanDependencies(ThrowingSigningRepository());
    final cubit = LoanRequestCubit();
    await assess(cubit);
    await cubit.continueFlow();
    await cubit.continueFlow();
    await cubit.applyContractResult(true);
    cubit.updateOtp('12345');
    await cubit.submitLoan();
    expect(cubit.state.submissionStatus, RequestStatus.failure);
    expect(cubit.state.isOtpError, false);
    expect(cubit.state.failure!.code, 'unexpected');
    expect(cubit.state.message, isNotEmpty);
    await cubit.close();
  });

  test(
    'resuming lump-sum preserves its 4–10 month slider limits after Back',
    () async {
      final repo = MockLoanApplicationRepository(delay: Duration.zero);
      await installLoanDependencies(repo);
      final first = LoanRequestCubit();
      await assess(first);
      await first.selectRepayment(LoanRepayment.lumpSum);
      await first.updateMonths(1 / 3);
      await first.continueFlow();
      await first.continueFlow();
      await first.close();
      final resumed = LoanRequestCubit();
      await resumed.fetchCatalog();
      resumed.resumeRequest(resumed.state.catalog!.currentDraft!);
      resumed.requestBack();
      resumed.requestBack();
      expect(resumed.state.minimumMonths, 4);
      expect(resumed.state.maximumMonths, 10);
      await resumed.updateMonths(1);
      expect(resumed.state.months, 10);
      expect(resumed.state.quoteStatus, RequestStatus.success);
      await resumed.close();
    },
  );

  test('loan field errors appear on blur and clear on editing without revalidating other fields', () async {
    await installLoanDependencies(
      MockLoanApplicationRepository(
        delay: Duration.zero,
        tier: LoanCreditTier.suitable,
      ),
    );
    final cubit = LoanRequestCubit();
    await assess(cubit);
    await cubit.continueFlow();
    await cubit.continueFlow();
    cubit.updateGuarantorNationalId('0');
    expect(cubit.state.isGuarantorIdError, false);
    cubit.validateGuarantorNationalId();
    expect(cubit.state.isGuarantorIdError, true);
    cubit.updateGuarantorNationalId('0013543921');
    expect(cubit.state.isGuarantorIdError, false);
    await cubit.checkGuarantor();
    cubit.updateOwnNumber('12');
    expect(cubit.state.isOwnNumberError, false);
    cubit.validateOwnNumber();
    expect(cubit.state.isOwnNumberError, true);
    cubit.updateOwnNumber('123456789');
    expect(cubit.state.isOwnNumberError, false);
    cubit.updateGuarantorNumber('1');
    cubit.validateGuarantorNumber();
    expect(cubit.state.isGuarantorNumberError, true);
    cubit.updateGuarantorNumber('987654321');
    expect(cubit.state.isGuarantorNumberError, false);
    expect(cubit.state.canContinue, true);
    await cubit.close();
  });

  test('inquiries publish partial results and enable next only after all approvals', () async {
    await installLoanDependencies(
      MockLoanApplicationRepository(delay: Duration.zero),
    );
    final cubit = LoanRequestCubit();
    await assess(cubit);
    final snapshots = <LoanRequestState>[];
    final subscription = cubit.stream.listen(snapshots.add);
    await cubit.continueFlow();
    await Future<void>.delayed(Duration.zero);
    expect(
      snapshots.any(
        (state) =>
            state.inquiries.any(
              (row) => row.outcome == LoanInquiryOutcome.approved,
            ) &&
            state.inquiries.any(
              (row) => row.outcome == LoanInquiryOutcome.processing,
            ),
      ),
      true,
    );
    expect(
      snapshots
          .where(
            (state) => state.inquiries.any(
              (row) => row.outcome == LoanInquiryOutcome.processing,
            ),
          )
          .every((state) => !state.canContinue),
      true,
    );
    expect(cubit.state.canContinue, true);
    await subscription.cancel();
    await cubit.close();
  });

  test('fee row is an explicit schedule fixture independent of principal repayments', () async {
    await installLoanDependencies(
      MockLoanApplicationRepository(delay: Duration.zero),
    );
    final cubit = LoanRequestCubit();
    await assess(cubit);
    expect(cubit.state.quote!.schedule.first.kind, LoanInstallmentKind.fee);
    expect(cubit.state.quote!.schedule.length, cubit.state.months + 1);
    expect(
      cubit.state.quote!.installments.fold<int>(
        0,
        (sum, row) => sum + row.amountRial,
      ),
      cubit.state.amountRial,
    );
    await cubit.close();
  });

  test('social-core follows its inspected no-collateral path and blocks unsuitable amounts', () async {
    await installLoanDependencies(
      MockLoanApplicationRepository(
        delay: Duration.zero,
        tier: LoanCreditTier.socialCore,
      ),
    );
    final cubit = LoanRequestCubit();
    await assess(cubit);
    expect(cubit.state.canContinue, true);
    expect(cubit.state.quote!.creditBands, [LoanCreditRange.excellent]);
    await cubit.continueFlow();
    await cubit.continueFlow();
    expect(cubit.state.step, LoanApplicationStep.contract);
    await cubit.close();
    final unsuitable = LoanRequestCubit();
    await assess(unsuitable, amount: 3500000000);
    expect(unsuitable.state.canContinue, false);
    expect(unsuitable.state.quote!.range, LoanCreditRange.unsuitable);
    await unsuitable.close();
  });
}

class DelayedQuoteRepository extends MockLoanApplicationRepository {
  DelayedQuoteRepository() : super(delay: Duration.zero);
  final inputs = <LoanQuoteInput>[];
  final results = <Completer<Result<LoanQuote>>>[];
  @override
  Future<Result<LoanQuote>> quote(LoanQuoteInput input) {
    inputs.add(input);
    final result = Completer<Result<LoanQuote>>();
    results.add(result);
    return result.future;
  }

  Future<Result<LoanQuote>> resolve(LoanQuoteInput input) => super.quote(input);
}

class RetryingSigningRepository extends MockLoanApplicationRepository {
  RetryingSigningRepository() : super(delay: Duration.zero);
  int attempts = 0;

  @override
  Future<Result<LoanRecord>> submit(
    LoanDraft draft,
    LoanSigningChallenge challenge,
    String otp,
  ) async {
    if (++attempts <= 2) {
      return const Err(DataFailure('loan.otp.invalid'));
    }
    return super.submit(draft, challenge, otp);
  }
}

class ThrowingSigningRepository extends MockLoanApplicationRepository {
  ThrowingSigningRepository() : super(delay: Duration.zero);
  @override
  Future<Result<LoanRecord>> submit(
    LoanDraft draft,
    LoanSigningChallenge challenge,
    String otp,
  ) async {
    throw StateError('simulated transport/parse error');
  }
}
