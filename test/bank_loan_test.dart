import 'package:pishkhan_mobile/features/dashboard/data/mock/dashboard_mock_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';

void main() {
  test('progress and displayed counts use the same installment data', () {
    expect(DashboardMockData.singleLoan.progress, .4);
    expect(DashboardMockData.singleLoan.installmentsPaid, '4/10');
    expect(DashboardMockData.loans.map((loan) => loan.progress).toList(), [
      .3,
      .7,
      .9,
    ]);
    expect(
      const BankLoan(
        id: 'different-total',
        paidInstallments: 3,
        totalInstallments: 12,
      ).progress,
      .25,
    );
  });
  test(
    'zero, unknown total, completion and inconsistent counts are bounded',
    () {
      expect(const BankLoan(id: 'none-paid', paidInstallments: 0).progress, 0);
      expect(
        const BankLoan(
          id: 'unknown',
          paidInstallments: 0,
          totalInstallments: 0,
        ).progress,
        0,
      );
      expect(
        const BankLoan(
          id: 'unknown-with-count',
          paidInstallments: 4,
          totalInstallments: 0,
        ).progress,
        0,
      );
      expect(const BankLoan(id: 'complete', paidInstallments: 10).progress, 1);
      expect(
        const BankLoan(id: 'over-count', paidInstallments: 12).progress,
        1,
      );
    },
  );
}
