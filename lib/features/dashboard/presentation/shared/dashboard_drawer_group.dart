import 'package:equatable/equatable.dart';

import 'dashboard_services.dart';

enum DashboardDrawerSection {
  home,
  modern,
  cards,
  cheques,
  transfers,
  loans,
  deposits,
  wallet,
  identity,
  requests,
}

class DashboardDrawerGroup extends Equatable {
  const DashboardDrawerGroup(this.section, [this.services = const []]);

  final DashboardDrawerSection section;
  final List<DashboardService> services;

  @override
  List<Object?> get props => [section, services];
}

const dashboardDrawerGroups = [
  DashboardDrawerGroup(DashboardDrawerSection.home),
  DashboardDrawerGroup(DashboardDrawerSection.modern, DashboardService.modern),
  DashboardDrawerGroup(DashboardDrawerSection.cards, [
    DashboardService.cardsList,
    DashboardService.issue,
    DashboardService.password,
    DashboardService.virtualCard,
    DashboardService.cardDeposit,
    DashboardService.expiredGift,
    DashboardService.block,
    DashboardService.unblockCard,
  ]),
  DashboardDrawerGroup(
    DashboardDrawerSection.cheques,
    DashboardService.cheques,
  ),
  DashboardDrawerGroup(
    DashboardDrawerSection.transfers,
    DashboardService.transfers,
  ),
  DashboardDrawerGroup(DashboardDrawerSection.loans, DashboardService.loans),
  DashboardDrawerGroup(
    DashboardDrawerSection.deposits,
    DashboardService.deposits,
  ),
  DashboardDrawerGroup(DashboardDrawerSection.wallet, DashboardService.wallets),
  DashboardDrawerGroup(
    DashboardDrawerSection.identity,
    DashboardService.identities,
  ),
  DashboardDrawerGroup(DashboardDrawerSection.requests),
];

sealed class DashboardDrawerSelection extends Equatable {
  const DashboardDrawerSelection();
}

final class DashboardDrawerHomeSelected extends DashboardDrawerSelection {
  const DashboardDrawerHomeSelected();

  @override
  List<Object?> get props => const [];
}

final class DashboardDrawerServiceSelected extends DashboardDrawerSelection {
  const DashboardDrawerServiceSelected(this.service);

  final DashboardService service;

  @override
  List<Object?> get props => [service];
}
