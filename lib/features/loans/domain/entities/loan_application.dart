import 'package:equatable/equatable.dart';

enum LoanCreditTier { unknown, excellent, fullySuitable, suitable, socialCore }

enum LoanCreditRange { unknown, excellent, fullySuitable, suitable, unsuitable }

enum LoanRepayment { installments, lumpSum }

enum LoanApplicationStep {
  introduction,
  assessment,
  inquiries,
  collateral,
  contract,
}

enum LoanInstrument { promissoryNote, electronicCheque }

enum LoanInquiryKind {
  returnedCheque,
  bankDebt,
  outstandingDebt,
  militaryService,
}

enum LoanInquiryOutcome { processing, approved, rejected }

enum LoanGuarantorOutcome { approved, notCustomer, capacityExceeded }

enum LoanRecordStatus { awaitingCollateral, awaitingSignature, readyForPayment }

class LoanDeposit extends Equatable {
  const LoanDeposit(this.id, this.number, this.creditTier);
  final String id;
  final String number;
  final LoanCreditTier creditTier;
  @override
  List<Object?> get props => [id, number, creditTier];
}

class LoanQuoteInput extends Equatable {
  const LoanQuoteInput({
    required this.deposit,
    required this.amountRial,
    required this.months,
    required this.repayment,
  });
  final LoanDeposit deposit;
  final int amountRial;
  final int months;
  final LoanRepayment repayment;
  @override
  List<Object?> get props => [deposit, amountRial, months, repayment];
}

enum LoanInstallmentKind { fee, repayment }

class LoanInstallment extends Equatable {
  const LoanInstallment(
    this.amountRial,
    this.dueAt, {
    this.kind = LoanInstallmentKind.repayment,
  });
  final LoanInstallmentKind kind;
  final int amountRial;
  final DateTime dueAt;
  @override
  List<Object?> get props => [amountRial, dueAt, kind];
}

class LoanQuote extends Equatable {
  LoanQuote({
    required this.id,
    required this.input,
    required this.range,
    required this.monthlyPaymentRial,
    required this.collateralRial,
    required this.needsGuarantor,
    required this.needsCollateral,
    required this.canProceed,
    required List<LoanInstallment> installments,
    List<LoanInstallment>? schedule,
    List<LoanCreditRange> creditBands = const [
      LoanCreditRange.excellent,
      LoanCreditRange.fullySuitable,
      LoanCreditRange.suitable,
    ],
    this.requiredCapacityRial = 0,
    this.availableCapacityRial = 300000000,
    this.capacityDeficitRial = 0,
    required this.currentLoansRial,
    required this.scoreRial,
    this.insuranceRial = 2700000,
    this.insuranceOptional = false,
    this.creditPosition = 0,
    List<int> creditBoundaries = const [
      1000000,
      100000000,
      200000000,
      300000000,
    ],
  }) : installments = List.unmodifiable(installments),
       schedule = List.unmodifiable(schedule ?? installments),
       creditBands = List.unmodifiable(creditBands),
       creditBoundaries = List.unmodifiable(creditBoundaries);
  final String id;
  final LoanQuoteInput input;
  final LoanCreditRange range;
  final int monthlyPaymentRial;
  final int collateralRial;
  final int currentLoansRial;
  final int scoreRial;
  final int insuranceRial;
  final bool insuranceOptional;
  final double creditPosition;
  final List<int> creditBoundaries;
  final bool needsGuarantor;
  final bool needsCollateral;
  final bool canProceed;
  final List<LoanInstallment> installments;
  final List<LoanInstallment> schedule;
  final List<LoanCreditRange> creditBands;
  final int requiredCapacityRial;
  final int availableCapacityRial;
  final int capacityDeficitRial;
  @override
  List<Object?> get props => [
    id,
    input,
    range,
    monthlyPaymentRial,
    collateralRial,
    needsGuarantor,
    needsCollateral,
    canProceed,
    installments,
    schedule,
    creditBands,
    requiredCapacityRial,
    availableCapacityRial,
    capacityDeficitRial,
    currentLoansRial,
    scoreRial,
    insuranceRial,
    insuranceOptional,
    creditPosition,
    creditBoundaries,
  ];
}

class LoanInquiry extends Equatable {
  const LoanInquiry(this.kind, this.outcome, {this.rejectionCode});
  final LoanInquiryKind kind;
  final LoanInquiryOutcome outcome;
  final String? rejectionCode;
  @override
  List<Object?> get props => [kind, outcome, rejectionCode];
}

class LoanGuarantor extends Equatable {
  const LoanGuarantor(this.nationalId, this.outcome, {this.name});
  final String nationalId;
  final LoanGuarantorOutcome outcome;
  final String? name;
  @override
  List<Object?> get props => [nationalId, outcome, name];
}

class LoanCollateral extends Equatable {
  const LoanCollateral({
    required this.ownInstrument,
    required this.ownNumber,
    required this.guarantorInstrument,
    required this.guarantorNumber,
    this.guarantor,
  });
  final LoanInstrument ownInstrument;
  final String ownNumber;
  final LoanInstrument guarantorInstrument;
  final String guarantorNumber;
  final LoanGuarantor? guarantor;
  @override
  List<Object?> get props => [
    ownInstrument,
    ownNumber,
    guarantorInstrument,
    guarantorNumber,
    guarantor,
  ];
}

class LoanDraft extends Equatable {
  const LoanDraft({
    required this.id,
    required this.quote,
    required this.step,
    this.collateral,
    this.insuranceSelected = false,
    this.expiresAt,
  });
  final String id;
  final LoanQuote quote;
  final LoanApplicationStep step;
  final LoanCollateral? collateral;
  final bool insuranceSelected;
  final DateTime? expiresAt;
  @override
  List<Object?> get props => [
    id,
    quote,
    step,
    collateral,
    insuranceSelected,
    expiresAt,
  ];
}

class LoanSigningChallenge extends Equatable {
  const LoanSigningChallenge({
    required this.id,
    required this.draftId,
    required this.expiresAt,
    this.codeLength = 5,
    this.maskedPhone = '0912***4197',
  });
  final String id;
  final String draftId;
  final DateTime expiresAt;
  final int codeLength;
  final String maskedPhone;
  @override
  List<Object?> get props => [id, draftId, expiresAt, codeLength, maskedPhone];
}

class LoanRecord extends Equatable {
  const LoanRecord({
    required this.id,
    required this.depositNumber,
    required this.amountRial,
    required this.createdAt,
    required this.status,
  });
  final String id;
  final String depositNumber;
  final int amountRial;
  final DateTime createdAt;
  final LoanRecordStatus status;
  @override
  List<Object?> get props => [id, depositNumber, amountRial, createdAt, status];
}

class LoanCatalog extends Equatable {
  LoanCatalog({
    required List<LoanDeposit> deposits,
    this.currentDraft,
    this.latestRecord,
    this.tutorialUrl,
    this.contractText,
    this.contractDownloadUrl,
    this.insuranceText,
    this.minimumRial = 1000000,
    this.maximumRial = 5000000000,
    this.minimumMonths = 1,
    this.maximumMonths = 60,
  }) : deposits = List.unmodifiable(deposits);
  final List<LoanDeposit> deposits;
  final LoanDraft? currentDraft;
  final LoanRecord? latestRecord;
  final String? tutorialUrl;
  final String? contractText;
  final String? contractDownloadUrl;
  final String? insuranceText;
  final int minimumRial;
  final int maximumRial;
  final int minimumMonths;
  final int maximumMonths;
  @override
  List<Object?> get props => [
    deposits,
    currentDraft,
    latestRecord,
    tutorialUrl,
    contractText,
    contractDownloadUrl,
    insuranceText,
    minimumRial,
    maximumRial,
    minimumMonths,
    maximumMonths,
  ];
}

/// Mock instrument syntax only; authoritative ownership/value checks are repository-owned.
abstract final class LoanInstrumentValidator {
  static bool isValid(String value) => RegExp(r'^[0-9]{8,20}$').hasMatch(value);
}
