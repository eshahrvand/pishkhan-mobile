import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/loan_application.dart';
import '../../domain/entities/loan_credit_assessment.dart';
import '../../domain/repositories/loan_application_repository.dart';

/// Deterministic simulation only. Thresholds and checks are not bank policy.
class MockLoanApplicationRepository implements LoanApplicationRepository {
  MockLoanApplicationRepository({
    this.tier = LoanCreditTier.excellent,
    this.rejectedInquiry,
    this.delay = const Duration(milliseconds: 300),
    LoanDraft? currentDraft,
  }) : _draft = currentDraft {
    if (currentDraft != null) {
      _quotes[currentDraft.quote.id] = currentDraft.quote;
      _approvedInquiries.add(currentDraft.quote.id);
      if (currentDraft.collateral != null) {
        _approvedCollateral[currentDraft.quote.id] = currentDraft.collateral!;
      }
    }
  }
  final LoanCreditTier tier;
  final LoanInquiryKind? rejectedInquiry;
  final Duration delay;
  LoanDraft? _draft;
  LoanRecord? _record;
  int _serial = 0;
  final Map<String, LoanQuote> _quotes = {};
  final Map<String, LoanSigningChallenge> _challenges = {};
  final Map<String, LoanRecord> _receipts = {};
  final Set<String> _approvedInquiries = {};
  final Map<String, LoanCollateral> _approvedCollateral = {};

  @override
  Future<Result<LoanCatalog>> fetchCatalog() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return Success(
      LoanCatalog(
        deposits: [LoanDeposit('deposit-1', '10.10009753.1', tier)],
        currentDraft: _draft,
        latestRecord: _record,
        maximumMonths: tier == LoanCreditTier.unknown ? 24 : 60,
      ),
    );
  }

  @override
  Future<Result<LoanQuote>> quote(LoanQuoteInput input) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (input.amountRial < 1000000 ||
        input.amountRial > 5000000000 ||
        input.months < (input.repayment == LoanRepayment.lumpSum ? 4 : 1) ||
        input.months > (input.repayment == LoanRepayment.lumpSum ? 10 : 60)) {
      return const Err(DataFailure('loan.quote.invalid'));
    }
    final assessment = assessMockLoanInput(input);
    final now = DateTime.now().toUtc();
    final installments = input.repayment == LoanRepayment.lumpSum
        ? [
            LoanInstallment(
              input.amountRial,
              DateTime.utc(now.year, now.month + input.months, 17),
            ),
          ]
        : List.generate(
            input.months,
            (index) => LoanInstallment(
              input.amountRial ~/ input.months +
                  (index < input.amountRial % input.months ? 1 : 0),
              DateTime.utc(now.year, now.month + index + 1, 17),
            ),
          );
    final result = LoanQuote(
      id: 'mock-quote-${++_serial}',
      input: input,
      range: assessment.range,
      scoreRial: assessment.scoreRial,
      currentLoansRial: assessment.currentLoansRial,
      monthlyPaymentRial: assessment.monthlyPaymentRial,
      collateralRial: assessment.collateralRial,
      needsGuarantor: assessment.range == LoanCreditRange.suitable,
      insuranceOptional: assessment.range == LoanCreditRange.suitable,
      creditPosition: assessment.creditPosition,
      creditBands: assessment.creditBands,
      creditBoundaries: assessment.creditBoundaries,
      requiredCapacityRial: assessment.requiredCapacityRial,
      availableCapacityRial: assessment.availableCapacityRial,
      capacityDeficitRial: assessment.capacityDeficitRial,
      needsCollateral:
          assessment.range == LoanCreditRange.fullySuitable ||
          assessment.range == LoanCreditRange.suitable,
      // TODO(owner/designer): confirm unsuitable progression. Blocked for now.
      canProceed: assessment.canProceed,
      installments: installments,
      // Explicit visual fixture from the schedule design, not a fee formula.
      schedule: [
        LoanInstallment(
          5000000,
          installments.first.dueAt,
          kind: LoanInstallmentKind.fee,
        ),
        ...installments,
      ],
    );
    _quotes[result.id] = result;
    return Success(result);
  }

  @override
  Stream<Result<List<LoanInquiry>>> inquire(LoanQuote quote) async* {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (_quotes[quote.id] != quote || !quote.canProceed) {
      yield const Err(DataFailure('loan.quote.invalid'));
      return;
    }
    final rows = LoanInquiryKind.values
        .map(
          (kind) => LoanInquiry(
            kind,
            kind == rejectedInquiry
                ? LoanInquiryOutcome.rejected
                : LoanInquiryOutcome.approved,
            rejectionCode: kind == rejectedInquiry
                ? 'mock.inquiry.rejected'
                : null,
          ),
        )
        .toList();
    if (rejectedInquiry == null) _approvedInquiries.add(quote.id);
    for (var completed = 1; completed <= rows.length; completed++) {
      if (delay > Duration.zero) await Future<void>.delayed(delay);
      yield Success(
        List.unmodifiable([
          for (var index = 0; index < rows.length; index++)
            index < completed
                ? rows[index]
                : LoanInquiry(rows[index].kind, LoanInquiryOutcome.processing),
        ]),
      );
    }
  }

  @override
  Future<Result<LoanGuarantor>> checkGuarantor(
    String nationalId,
    LoanQuote quote,
  ) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return Success(
      LoanGuarantor(
        nationalId,
        nationalId == '0081234562'
            ? LoanGuarantorOutcome.notCustomer
            : nationalId == '0499370899'
            ? LoanGuarantorOutcome.capacityExceeded
            : LoanGuarantorOutcome.approved,
        name: nationalId == '0081234562' ? null : 'مهسا جوانمرد',
      ),
    );
  }

  @override
  Future<Result<LoanCollateral>> checkCollateral(
    LoanQuote quote,
    LoanCollateral collateral,
  ) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (!_approvedInquiries.contains(quote.id) ||
        collateral.ownNumber == '1111111111' ||
        (quote.needsGuarantor &&
            (collateral.guarantor?.outcome != LoanGuarantorOutcome.approved ||
                collateral.guarantorNumber == '1111111111'))) {
      return const Err(DataFailure('loan.collateral.invalid'));
    }
    _approvedCollateral[quote.id] = collateral;
    return Success(collateral);
  }

  @override
  Future<Result<LoanDraft>> saveDraft(LoanDraft draft) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (!_approvedInquiries.contains(draft.quote.id) ||
        (draft.step == LoanApplicationStep.contract &&
            draft.quote.needsCollateral &&
            _approvedCollateral[draft.quote.id] != draft.collateral)) {
      return const Err(DataFailure('loan.draft.invalid'));
    }
    // Explicit demo validity; production expiry is supplied by the service.
    _draft = LoanDraft(
      id: draft.id,
      quote: draft.quote,
      step: draft.step,
      collateral: draft.collateral,
      insuranceSelected: draft.insuranceSelected,
      expiresAt:
          draft.expiresAt ??
          DateTime.now().toUtc().add(const Duration(minutes: 1)),
    );
    return Success(_draft!);
  }

  @override
  Future<Result<LoanSigningChallenge>> requestSigningOtp(
    LoanDraft draft,
  ) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (_draft != draft || draft.step != LoanApplicationStep.contract) {
      return const Err(DataFailure('loan.draft.invalid'));
    }
    final challenge = LoanSigningChallenge(
      id: 'mock-challenge-${++_serial}',
      draftId: draft.id,
      expiresAt: DateTime.now().toUtc().add(const Duration(seconds: 60)),
    );
    _challenges.clear();
    _challenges[challenge.id] = challenge;
    return Success(challenge);
  }

  @override
  Future<Result<LoanRecord>> submit(
    LoanDraft draft,
    LoanSigningChallenge challenge,
    String otp,
  ) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    final existing = _receipts[draft.id];
    if (existing != null) return Success(existing);
    if (_draft != draft ||
        challenge.draftId != draft.id ||
        _challenges[challenge.id] != challenge ||
        !challenge.expiresAt.isAfter(DateTime.now().toUtc())) {
      return const Err(DataFailure('loan.otp.invalid'));
    }
    // Test mode accepts any entered OTP; challenge safeguards still apply.
    final record = LoanRecord(
      id: 'MOCK-${++_serial}',
      depositNumber: draft.quote.input.deposit.number,
      amountRial: draft.quote.input.amountRial,
      createdAt: DateTime.now().toUtc(),
      status: LoanRecordStatus.readyForPayment,
    );
    _receipts[draft.id] = record;
    _record = record;
    _draft = null;
    return Success(record);
  }

  @override
  Future<Result<void>> cancel(String draftId) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (_draft?.id != draftId) {
      return const Err(DataFailure('loan.draft.invalid'));
    }
    _draft = null;
    _challenges.clear();
    return const Success(null);
  }
}
