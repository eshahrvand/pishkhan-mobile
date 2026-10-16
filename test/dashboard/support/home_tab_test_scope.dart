import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_card.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_effect.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/cards_tab.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/deposits_tab.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/loans_tab.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/deposit_actions.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/loan_actions.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_tab.dart';

import 'dashboard_test_repositories.dart';

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

class HomeTabTestScope extends StatefulWidget {
  const HomeTabTestScope({
    super.key,
    required this.repositories,
    required this.child,
    this.onCardAction,
    this.onDepositAction,
    this.onLoanAction,
    this.onMore,
    this.onCardSelected,
    this.onDepositSelected,
    this.onLoanSelected,
    this.onDetails,
    this.onCopyNumber,
    this.onCopyIban,
    this.onTabSelected,
    this.onMenuPressed,
    this.onAssistantPressed,
  });
  final DashboardRepositories repositories;
  final Widget child;
  final ValueChanged<CardActionRequest>? onCardAction;
  final ValueChanged<DepositActionRequest>? onDepositAction;
  final ValueChanged<LoanActionRequest>? onLoanAction;
  final ValueChanged<BankCard>? onMore, onCardSelected;
  final ValueChanged<BankDeposit>? onDepositSelected;
  final ValueChanged<BankLoan>? onLoanSelected, onDetails;
  final ValueChanged<String>? onCopyNumber, onCopyIban;
  final ValueChanged<AppPrimaryTab>? onTabSelected;
  final VoidCallback? onMenuPressed, onAssistantPressed;

  @override
  State<HomeTabTestScope> createState() => _HomeTabTestScopeState();
}

class _HomeTabTestScopeState extends State<HomeTabTestScope> {
  late final HomeCubit _cubit;
  @override
  void initState() {
    super.initState();
    _cubit = HomeCubit(repositories: widget.repositories)..load();
  }

  @override
  void didUpdateWidget(covariant HomeTabTestScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cubit.changeRepositories(widget.repositories);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) =>
            previous.effectId != current.effectId,
        listener: (context, state) {
          switch (state.effect) {
            case HomeCardActionRequested(:final request):
              widget.onCardAction?.call(request);
            case HomeDepositActionRequested(:final request):
              widget.onDepositAction?.call(request);
            case HomeLoanActionRequested(:final request):
              widget.onLoanAction?.call(request);
            case HomeCardMoreRequested(:final card):
              widget.onMore?.call(card);
            case HomeCardSelectionChanged(:final card):
              widget.onCardSelected?.call(card);
            case HomeDepositSelectionChanged(:final deposit):
              widget.onDepositSelected?.call(deposit);
            case HomeLoanSelectionChanged(:final loan):
              widget.onLoanSelected?.call(loan);
            case HomeLoanDetailsRequested(:final loan):
              widget.onDetails?.call(loan);
            case HomeCardNumberCopyRequested(:final number):
              _copyNumber(number);
            case HomeDepositNumberCopyRequested(:final number):
              _copyNumber(number);
            case HomeLoanNumberCopyRequested(:final number):
              _copyNumber(number);
            case HomeCardIbanCopyRequested(:final iban):
              _copyIban(iban);
            case HomeDepositIbanCopyRequested(:final iban):
              _copyIban(iban);
            case HomeTabRequested(:final tab):
              widget.onTabSelected?.call(tab);
            case HomeMenuRequested():
              widget.onMenuPressed?.call();
            case HomeAssistantRequested():
              widget.onAssistantPressed?.call();
            case null:
              break;
          }
        },
        child: widget.child,
      ),
    );
  }

  void _copyNumber(String value) {
    if (widget.onCopyNumber != null) {
      widget.onCopyNumber!(value);
    } else {
      Clipboard.setData(ClipboardData(text: value));
    }
  }

  void _copyIban(String value) {
    if (widget.onCopyIban != null) {
      widget.onCopyIban!(value);
    } else {
      Clipboard.setData(ClipboardData(text: value));
    }
  }
}

Widget cardsScope({
  required DashboardCardsRepository repository,
  ValueChanged<CardActionRequest>? onActionRequested,
  ValueChanged<BankCard>? onMorePressed,
  ValueChanged<BankCard>? onSelectedCardChanged,
  ValueChanged<String>? onCopyNumber,
  ValueChanged<String>? onCopyIban,
}) => HomeTabTestScope(
  repositories: homeRepositories(cards: repository),
  onCardAction: onActionRequested,
  onMore: onMorePressed,
  onCardSelected: onSelectedCardChanged,
  onCopyNumber: onCopyNumber,
  onCopyIban: onCopyIban,
  child: const CardsTab(),
);

Widget depositScope({
  required DashboardDepositsRepository repository,
  ValueChanged<DepositActionRequest>? onActionRequested,
  ValueChanged<BankDeposit>? onSelectedDepositChanged,
  ValueChanged<String>? onCopyNumber,
  ValueChanged<String>? onCopyIban,
  ValueChanged<AppPrimaryTab>? onTabSelected,
  VoidCallback? onMenuPressed,
  VoidCallback? onAssistantPressed,
}) => HomeTabTestScope(
  repositories: homeRepositories(deposits: repository),
  onDepositAction: onActionRequested,
  onDepositSelected: onSelectedDepositChanged,
  onCopyNumber: onCopyNumber,
  onCopyIban: onCopyIban,
  onTabSelected: onTabSelected,
  onMenuPressed: onMenuPressed,
  onAssistantPressed: onAssistantPressed,
  child: const DepositsTab(),
);

Widget loanScope({
  required DashboardLoansRepository repository,
  ValueChanged<LoanActionRequest>? onActionRequested,
  ValueChanged<BankLoan>? onSelectedLoanChanged,
  ValueChanged<String>? onCopyNumber,
  ValueChanged<BankLoan>? onDetailsRequested,
  ValueChanged<AppPrimaryTab>? onTabSelected,
  VoidCallback? onMenuPressed,
  VoidCallback? onAssistantPressed,
}) => HomeTabTestScope(
  repositories: homeRepositories(loans: repository),
  onLoanAction: onActionRequested,
  onLoanSelected: onSelectedLoanChanged,
  onCopyNumber: onCopyNumber,
  onDetails: onDetailsRequested,
  onTabSelected: onTabSelected,
  onMenuPressed: onMenuPressed,
  onAssistantPressed: onAssistantPressed,
  child: const LoansTab(),
);
