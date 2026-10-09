import 'dart:async';

import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/dashboard/dashboard.dart';
import 'package:pishkhan_mobile/features/dashboard/data/mock/dashboard_mock_data.dart';

class TestRepositories
    implements
        DashboardCardsRepository,
        DashboardDepositsRepository,
        DashboardLoansRepository,
        DashboardHomeRepository {
  Result<List<BankCard>> cards = const Success(DashboardMockData.cards);
  Result<List<BankDeposit>> deposits = const Success(
    DashboardMockData.deposits,
  );
  Result<List<BankLoan>> loans = const Success(DashboardMockData.loans);
  Result<DashboardHomeData?> home = const Success(null);
  final loanQueue = <Completer<Result<List<BankLoan>>>>[];
  bool throwOnCards = false;
  @override
  Future<Result<List<BankCard>>> getCards() async {
    if (throwOnCards) throw StateError('transport implementation failed');
    return cards;
  }

  @override
  Future<Result<List<BankDeposit>>> getDeposits() async => deposits;
  @override
  Future<Result<List<BankLoan>>> getLoans() async =>
      loanQueue.isEmpty ? loans : await loanQueue.removeAt(0).future;
  @override
  Future<Result<DashboardHomeData?>> getHome() async => home;
}
