import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/loans/domain/entities/loan_application.dart';
import 'package:pishkhan_mobile/features/loans/domain/entities/loan_credit_assessment.dart';

LoanQuoteInput input(
  int amount, {
  int months = 10,
  LoanCreditTier tier = LoanCreditTier.excellent,
  LoanRepayment repayment = LoanRepayment.installments,
}) => LoanQuoteInput(
  deposit: LoanDeposit('test', '10.10009753.1', tier),
  amountRial: amount,
  months: months,
  repayment: repayment,
);

void main() {
  for (final sample in [
    (500000000, LoanCreditRange.excellent),
    (1500000000, LoanCreditRange.fullySuitable),
    (2500000000, LoanCreditRange.suitable),
    (3500000000, LoanCreditRange.unsuitable),
  ]) {
    test('the design sample ${sample.$1} selects ${sample.$2}', () {
      final result = assessMockLoanInput(input(sample.$1));
      expect(result.range, sample.$2);
      final amountPosition = (sample.$1 - 1000000) / 4999000000;
      expect(
        amountPosition >= result.amountRedStart,
        sample.$2 == LoanCreditRange.unsuitable,
      );
    });
  }
  test('the first red amount is the first unsuitable integer amount', () {
    final boundary = assessMockLoanInput(input(3000000000));
    final red = assessMockLoanInput(input(3000000001));
    expect(boundary.range, LoanCreditRange.suitable);
    expect(boundary.canProceed, true);
    expect(red.range, LoanCreditRange.unsuitable);
    expect(red.canProceed, false);
    expect(
      (3000000000 - 1000000) / 4999000000,
      lessThan(boundary.amountRedStart),
    );
    expect((3000000001 - 1000000) / 4999000000, red.amountRedStart);
  });
  test(
    'duration moves the red boundary using the same capacity calculation',
    () {
      final short = assessMockLoanInput(input(2000000000, months: 5));
      final long = assessMockLoanInput(input(2000000000, months: 20));
      expect(short.range, LoanCreditRange.unsuitable);
      expect(long.range, LoanCreditRange.excellent);
      expect(short.amountRedStart, lessThan(long.amountRedStart));
      expect(
        long.amountRedStart,
        1,
      ); // No red region exists within the allowed amount range.
    },
  );
  test(
    'known tiers always agree with their red zone across amounts and durations',
    () {
      for (final tier in [
        LoanCreditTier.excellent,
        LoanCreditTier.fullySuitable,
        LoanCreditTier.suitable,
        LoanCreditTier.socialCore,
      ]) {
        for (final months in [1, 5, 10, 20, 60]) {
          for (final amount in [
            1000000,
            500000000,
            1500000000,
            2500000000,
            3000000000,
            3000000001,
            4000000000,
            5000000000,
          ]) {
            final result = assessMockLoanInput(
              input(amount, months: months, tier: tier),
            );
            final inRed =
                result.amountRedStart < 1 &&
                (amount - 1000000) / 4999000000 >= result.amountRedStart;
            expect(
              result.range == LoanCreditRange.unsuitable,
              inRed,
              reason: '$tier / $months / $amount',
            );
            expect(
              result.amountGreenEnd,
              lessThanOrEqualTo(result.amountRedStart),
            );
          }
        }
      }
    },
  );
  test('unknown tier does not advertise a green approval region', () {
    final result = assessMockLoanInput(
      input(500000000, tier: LoanCreditTier.unknown),
    );
    expect(result.range, LoanCreditRange.unknown);
    expect(result.amountGreenEnd, 0);
    expect(result.amountRedStart, 1);
    expect(result.canProceed, false);
  });
  test('lump sum preserves the explicitly approved mock sample bands', () {
    for (final months in [4, 6, 10]) {
      final result = assessMockLoanInput(
        input(1500000000, months: months, repayment: LoanRepayment.lumpSum),
      );
      expect(result.range, LoanCreditRange.fullySuitable);
      expect(result.monthlyPaymentRial, 0);
    }
  });
}
