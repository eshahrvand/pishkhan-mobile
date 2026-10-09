import 'package:pishkhan_mobile/core/result/result.dart';

import '../../domain/entities/bank_card.dart';
import '../../domain/entities/bank_deposit.dart';
import '../../domain/entities/bank_loan.dart';
import '../../domain/entities/dashboard_home_data.dart';
import '../../domain/repositories/dashboard_repositories.dart';
import 'dashboard_mock_data.dart';

class MockDashboardCardsRepository implements DashboardCardsRepository {
  const MockDashboardCardsRepository({this.cards = DashboardMockData.cards});
  final List<BankCard> cards;
  @override
  Future<Result<List<BankCard>>> getCards() async => Success(cards);
}

class MockDashboardDepositsRepository implements DashboardDepositsRepository {
  const MockDashboardDepositsRepository({
    this.deposits = DashboardMockData.deposits,
  });
  final List<BankDeposit> deposits;
  @override
  Future<Result<List<BankDeposit>>> getDeposits() async => Success(deposits);
}

class MockDashboardLoansRepository implements DashboardLoansRepository {
  const MockDashboardLoansRepository({this.loans = DashboardMockData.loans});
  final List<BankLoan> loans;
  @override
  Future<Result<List<BankLoan>>> getLoans() async => Success(loans);
}

class MockDashboardHomeRepository implements DashboardHomeRepository {
  const MockDashboardHomeRepository({this.favorites = const []});
  final List<String> favorites;
  @override
  Future<Result<DashboardHomeData?>> getHome() async => Success(
    DashboardHomeData(
      walletBalance: '۱٬۲۰۰٬۰۰۰',
      favorites: favorites,
      fixedServiceIds: const [
        'assistant',
        'card-password',
        'loan-estimate',
        'deposit-sms',
        'card-block',
        'deposit-statement',
        'deposit-certificate',
        'deposit-representative',
      ],
      suggestedServiceIds: const [
        'card-issue',
        'loan-consolidate',
        'card-deposit',
      ],
    ),
  );
}
