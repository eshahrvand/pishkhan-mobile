import 'package:equatable/equatable.dart';

import '../../../domain/entities/bank_card.dart';
import '../../../domain/entities/bank_deposit.dart';
import '../../../domain/entities/bank_loan.dart';
import '../../shared/deposit_actions.dart';
import '../../shared/loan_actions.dart';
import '../../shared/dashboard_services.dart';
import '../../shared/card_actions.dart';
import '../../shared/dashboard_tab.dart';

sealed class HomeEffect extends Equatable {
  const HomeEffect();

  @override
  List<Object?> get props => const [];
}

final class HomeCardActionRequested extends HomeEffect {
  const HomeCardActionRequested(this.request);
  final CardActionRequest request;

  @override
  List<Object?> get props => [request.action, request.card];
}

final class HomeCardMoreRequested extends HomeEffect {
  const HomeCardMoreRequested(this.card);
  final BankCard card;

  @override
  List<Object?> get props => [card];
}

final class HomeCardSelectionChanged extends HomeEffect {
  const HomeCardSelectionChanged(this.card);
  final BankCard card;

  @override
  List<Object?> get props => [card];
}

final class HomeCardNumberCopyRequested extends HomeEffect {
  const HomeCardNumberCopyRequested(this.number);
  final String number;

  @override
  List<Object?> get props => [number];
}

final class HomeCardIbanCopyRequested extends HomeEffect {
  const HomeCardIbanCopyRequested(this.iban);
  final String iban;

  @override
  List<Object?> get props => [iban];
}

final class HomeTabRequested extends HomeEffect {
  const HomeTabRequested(this.tab);
  final AppPrimaryTab tab;

  @override
  List<Object?> get props => [tab];
}

final class HomeMenuRequested extends HomeEffect {
  const HomeMenuRequested({this.category});
  final List<DashboardService>? category;
  @override
  List<Object?> get props => [category];
}

final class HomeAssistantRequested extends HomeEffect {
  const HomeAssistantRequested();
}

final class HomeDepositActionRequested extends HomeEffect {
  const HomeDepositActionRequested(this.request);
  final DepositActionRequest request;
  @override
  List<Object?> get props => [request.action, request.deposit];
}

final class HomeLoanActionRequested extends HomeEffect {
  const HomeLoanActionRequested(this.request);
  final LoanActionRequest request;
  @override
  List<Object?> get props => [request.action, request.loan];
}

final class HomeDepositSelectionChanged extends HomeEffect {
  const HomeDepositSelectionChanged(this.deposit);
  final BankDeposit deposit;
  @override
  List<Object?> get props => [deposit];
}

final class HomeLoanSelectionChanged extends HomeEffect {
  const HomeLoanSelectionChanged(this.loan);
  final BankLoan loan;
  @override
  List<Object?> get props => [loan];
}

final class HomeLoanDetailsRequested extends HomeEffect {
  const HomeLoanDetailsRequested(this.loan);
  final BankLoan loan;
  @override
  List<Object?> get props => [loan];
}

final class HomeDepositNumberCopyRequested extends HomeEffect {
  const HomeDepositNumberCopyRequested(this.number);
  final String number;
  @override
  List<Object?> get props => [number];
}

final class HomeDepositIbanCopyRequested extends HomeEffect {
  const HomeDepositIbanCopyRequested(this.iban);
  final String iban;
  @override
  List<Object?> get props => [iban];
}

final class HomeLoanNumberCopyRequested extends HomeEffect {
  const HomeLoanNumberCopyRequested(this.number);
  final String number;
  @override
  List<Object?> get props => [number];
}
