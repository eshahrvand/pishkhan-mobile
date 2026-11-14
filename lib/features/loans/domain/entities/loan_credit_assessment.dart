import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import 'loan_application.dart';

/// Immediate form feedback. This is separate from a confirmed server quote.
class LoanCreditAssessment extends Equatable {
  LoanCreditAssessment({
    required this.range,
    required this.collateralRial,
    required this.scoreRial,
    required this.currentLoansRial,
    required this.monthlyPaymentRial,
    required this.requiredCapacityRial,
    required this.availableCapacityRial,
    required this.capacityDeficitRial,
    required this.creditPosition,
    required this.amountGreenEnd,
    required this.amountRedStart,
    required this.canProceed,
    required List<LoanCreditRange> creditBands,
    required List<int> creditBoundaries,
  }) : creditBands = List.unmodifiable(creditBands),
       creditBoundaries = List.unmodifiable(creditBoundaries);
  final LoanCreditRange range;
  final int collateralRial;
  final int scoreRial;
  final int currentLoansRial;
  final int monthlyPaymentRial;
  final int requiredCapacityRial;
  final int availableCapacityRial;
  final int capacityDeficitRial;
  final double creditPosition;
  final double amountGreenEnd;
  final double amountRedStart;
  final bool canProceed;
  final List<LoanCreditRange> creditBands;
  final List<int> creditBoundaries;
  @override
  List<Object?> get props => [
    range,
    collateralRial,
    scoreRial,
    currentLoansRial,
    monthlyPaymentRial,
    requiredCapacityRial,
    availableCapacityRial,
    capacityDeficitRial,
    creditPosition,
    amountGreenEnd,
    amountRedStart,
    canProceed,
    creditBands,
    creditBoundaries,
  ];
}

/// Shared mock policy for both slider feedback and the simulated quote.
/// Thresholds must be replaced by bank-supplied configuration for real APIs.
LoanCreditAssessment assessMockLoanInput(
  LoanQuoteInput input, {
  int minimumRial = 1000000,
  int maximumRial = 5000000000,
}) {
  const capacity = 300000000;
  const score = 3000000000;
  final duration = input.repayment == LoanRepayment.lumpSum ? 10 : input.months;
  final monthly = (input.amountRial / duration).ceil();
  final bands = switch (input.deposit.creditTier) {
    LoanCreditTier.excellent => const [
      LoanCreditRange.excellent,
      LoanCreditRange.fullySuitable,
      LoanCreditRange.suitable,
    ],
    LoanCreditTier.fullySuitable => const [
      LoanCreditRange.fullySuitable,
      LoanCreditRange.suitable,
    ],
    LoanCreditTier.suitable => const [LoanCreditRange.suitable],
    LoanCreditTier.socialCore => const [LoanCreditRange.excellent],
    LoanCreditTier.unknown => const <LoanCreditRange>[],
  };
  final boundaries = switch (input.deposit.creditTier) {
    LoanCreditTier.excellent => const [1000000, 100000000, 200000000, capacity],
    LoanCreditTier.fullySuitable => const [1000000, 200000000, capacity],
    _ => const [1000000, capacity],
  };
  final range = input.deposit.creditTier == LoanCreditTier.unknown
      ? LoanCreditRange.unknown
      : monthly > capacity
      ? LoanCreditRange.unsuitable
      : bands[_bandIndex(monthly, boundaries)];
  final compatibleAmount = capacity * duration;
  return LoanCreditAssessment(
    range: range,
    collateralRial: (input.amountRial * 120 + 99) ~/ 100,
    scoreRial: score,
    currentLoansRial: 1000000000,
    monthlyPaymentRial: input.repayment == LoanRepayment.lumpSum ? 0 : monthly,
    requiredCapacityRial: monthly,
    availableCapacityRial: capacity,
    capacityDeficitRial: math.max(0, monthly - capacity),
    creditPosition: _creditPosition(monthly, boundaries),
    creditBands: bands,
    creditBoundaries: boundaries,
    amountGreenEnd: bands.isEmpty
        ? 0
        : _amountPosition(
            math.min(score, compatibleAmount),
            minimumRial,
            maximumRial,
          ),
    amountRedStart: bands.isEmpty
        ? 1
        : _amountPosition(compatibleAmount + 1, minimumRial, maximumRial),
    canProceed:
        range != LoanCreditRange.unknown && range != LoanCreditRange.unsuitable,
  );
}

int _bandIndex(int monthly, List<int> boundaries) {
  for (var i = 0; i < boundaries.length - 1; i++) {
    if (monthly <= boundaries[i + 1]) return i;
  }
  return boundaries.length - 2;
}

double _creditPosition(int monthly, List<int> boundaries) {
  final index = _bandIndex(monthly, boundaries);
  final lower = index == 0 ? 0 : boundaries[index];
  return ((index + (monthly - lower) / (boundaries[index + 1] - lower)) /
          (boundaries.length - 1))
      .clamp(0, 1);
}

double _amountPosition(int amount, int minimum, int maximum) =>
    ((amount - minimum) / (maximum - minimum)).clamp(0, 1);
