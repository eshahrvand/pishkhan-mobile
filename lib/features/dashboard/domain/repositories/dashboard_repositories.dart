import 'package:pishkhan_mobile/core/result/result.dart';

import '../entities/bank_card.dart';
import '../entities/bank_deposit.dart';
import '../entities/bank_loan.dart';
import '../entities/dashboard_home_data.dart';

abstract interface class DashboardCardsRepository {
  Future<Result<List<BankCard>>> getCards();
}

abstract interface class DashboardDepositsRepository {
  Future<Result<List<BankDeposit>>> getDeposits();
}

abstract interface class DashboardLoansRepository {
  Future<Result<List<BankLoan>>> getLoans();
}

abstract interface class DashboardHomeRepository {
  Future<Result<DashboardHomeData?>> getHome();
}

class DashboardRepositories {
  const DashboardRepositories({
    required this.home,
    required this.cards,
    required this.deposits,
    required this.loans,
  });
  final DashboardHomeRepository home;
  final DashboardCardsRepository cards;
  final DashboardDepositsRepository deposits;
  final DashboardLoansRepository loans;
}
