import 'dart:async';

import 'package:pishkhan_mobile/core/result/result.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_card.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/dashboard_home_data.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/data/datasources/dashboard_mock_data.dart';
import 'package:pishkhan_mobile/features/dashboard/data/repositories/mock_dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';

const defaultDashboardTestRepositories = DashboardRepositories(
  home: MockDashboardHomeRepository(),
  cards: MockDashboardCardsRepository(),
  deposits: MockDashboardDepositsRepository(),
  loans: MockDashboardLoansRepository(),
);

DashboardRepositories homeRepositories({
  DashboardHomeRepository? home,
  DashboardCardsRepository? cards,
  DashboardDepositsRepository? deposits,
  DashboardLoansRepository? loans,
}) => DashboardRepositories(
  home: home ?? defaultDashboardTestRepositories.home,
  cards: cards ?? defaultDashboardTestRepositories.cards,
  deposits: deposits ?? defaultDashboardTestRepositories.deposits,
  loans: loans ?? defaultDashboardTestRepositories.loans,
);

DashboardRepositories dashboardTestRepositories({
  List<String> favorites = const [],
  List<BankCard> cards = DashboardMockData.cards,
  List<BankDeposit> deposits = DashboardMockData.deposits,
  List<BankLoan> loans = DashboardMockData.loans,
}) => DashboardRepositories(
  home: favorites.isEmpty
      ? defaultDashboardTestRepositories.home
      : MockDashboardHomeRepository(
          favorites: favorites
              .where(
                (id) =>
                    DashboardService.values.any((service) => service.id == id),
              )
              .toList(),
        ),
  cards: identical(cards, DashboardMockData.cards)
      ? defaultDashboardTestRepositories.cards
      : MockDashboardCardsRepository(cards: cards),
  deposits: identical(deposits, DashboardMockData.deposits)
      ? defaultDashboardTestRepositories.deposits
      : MockDashboardDepositsRepository(deposits: deposits),
  loans: identical(loans, DashboardMockData.loans)
      ? defaultDashboardTestRepositories.loans
      : MockDashboardLoansRepository(loans: loans),
);

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
  final cardQueue = <Completer<Result<List<BankCard>>>>[];
  final depositQueue = <Completer<Result<List<BankDeposit>>>>[];
  final homeQueue = <Completer<Result<DashboardHomeData?>>>[];
  bool throwOnCards = false;
  @override
  Future<Result<List<BankCard>>> getCards() async {
    if (throwOnCards) throw StateError('transport implementation failed');
    return cardQueue.isEmpty ? cards : await cardQueue.removeAt(0).future;
  }

  @override
  Future<Result<List<BankDeposit>>> getDeposits() async =>
      depositQueue.isEmpty ? deposits : await depositQueue.removeAt(0).future;
  @override
  Future<Result<List<BankLoan>>> getLoans() async =>
      loanQueue.isEmpty ? loans : await loanQueue.removeAt(0).future;
  @override
  Future<Result<DashboardHomeData?>> getHome() async =>
      homeQueue.isEmpty ? home : await homeQueue.removeAt(0).future;
}
