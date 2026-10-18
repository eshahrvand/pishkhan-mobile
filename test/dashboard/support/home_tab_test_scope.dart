import 'package:pishkhan_mobile/core/enums/request_status.dart';

import 'dart:async';

import '../../support/registered_dependency.dart';

import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/dashboard_screen.dart';
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

class HomeTabTestScope extends StatefulWidget {
  const HomeTabTestScope({
    super.key,
    required this.repositories,
    required this.child,
    this.onServiceRequested,
    this.onPromptSubmitted,
    this.onFavoritesChanged,
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
  final ValueChanged<String>? onServiceRequested, onPromptSubmitted;
  final ValueChanged<List<String>>? onFavoritesChanged;
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
  late HomeCubit _cubit;
  BlocObserver? _previousObserver;
  final _subscriptions = <StreamSubscription<HomeState>>[];

  void _notifySelection(HomeState previous, HomeState current) {
    if (previous.cardsStatus == RequestStatus.success &&
        current.cardsStatus == RequestStatus.success &&
        previous.selectedCard != current.selectedCard &&
        current.selectedCard != null) {
      widget.onCardSelected?.call(current.selectedCard!);
    }
    if (previous.depositsStatus == RequestStatus.success &&
        current.depositsStatus == RequestStatus.success &&
        previous.selectedDeposit != current.selectedDeposit &&
        current.selectedDeposit != null) {
      widget.onDepositSelected?.call(current.selectedDeposit!);
    }
    if (previous.loansStatus == RequestStatus.success &&
        current.loansStatus == RequestStatus.success &&
        previous.selectedLoan != current.selectedLoan &&
        current.selectedLoan != null) {
      widget.onLoanSelected?.call(current.selectedLoan!);
    }
  }

  void _observe(HomeCubit cubit) {
    _cubit = cubit;
    var effectId = cubit.state.effectId;
    _subscriptions.add(
      cubit.stream.listen((state) {
        if (effectId == state.effectId) return;
        effectId = state.effectId;
        _handleEffect(context, state);
      }),
    );
    HomeState previous = cubit.state;
    _subscriptions.add(
      cubit.stream.listen((state) {
        _notifySelection(previous, state);
        if (previous.homeData != null &&
            state.homeData != null &&
            previous.homeData!.favorites != state.homeData!.favorites) {
          widget.onFavoritesChanged?.call(state.homeData!.favorites);
        }
        previous = state;
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.child is DashboardScreen) {
      withRegisteredDependency<DashboardRepositories, void>(
        widget.repositories,
        () {},
      );
      _previousObserver = Bloc.observer;
      Bloc.observer = DashboardTestObserver(_previousObserver!, _observe);
      return;
    }
    _cubit = withRegisteredDependency<DashboardRepositories, HomeCubit>(
      widget.repositories,
      () => HomeCubit(
        initialState: const HomeState.initial(enableAnimations: false),
      ),
    )..fetchDashboard();
    var previous = _cubit.state;
    _subscriptions.add(
      _cubit.stream.listen((state) {
        _notifySelection(previous, state);
        previous = state;
      }),
    );
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    if (_previousObserver != null) {
      Bloc.observer = _previousObserver!;
    } else {
      _cubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child is DashboardScreen) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: widget.child,
      );
    }
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) =>
            previous.effectId != current.effectId,
        listener: _handleEffect,
        child: BlocListener<HomeCubit, HomeState>(
          listenWhen: (previous, current) =>
              previous.homeData != null &&
              current.homeData != null &&
              previous.homeData!.favorites != current.homeData!.favorites,
          listener: (context, state) =>
              widget.onFavoritesChanged?.call(state.homeData!.favorites),
          child: widget.child,
        ),
      ),
    );
  }

  void _handleEffect(BuildContext context, HomeState state) {
    switch (state.effect) {
      case HomeCardActionRequested(:final request):
        widget.onCardAction?.call(request);
        if (widget.onCardAction == null) {
          widget.onServiceRequested?.call(request.action.id);
        }
      case HomeDepositActionRequested(:final request):
        widget.onDepositAction?.call(request);
        if (widget.onDepositAction == null) {
          widget.onServiceRequested?.call(request.action.id);
        }
      case HomeLoanActionRequested(:final request):
        widget.onLoanAction?.call(request);
        if (widget.onLoanAction == null) {
          widget.onServiceRequested?.call(request.action.id);
        }
      case HomeCardMoreRequested(:final card):
        widget.onMore?.call(card);
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
        widget.onServiceRequested?.call('assistant');
      case HomeServiceRequested(:final serviceId):
        widget.onServiceRequested?.call(serviceId);
      case HomePromptSubmitted(:final prompt):
        widget.onPromptSubmitted?.call(prompt);
      case HomeAllServicesRequested():
      case HomeProfileRequested():
      case HomeNotificationsRequested():
      case HomeFavoritePickerRequested():
      case HomeFavoritesResetRequested():
      case null:
        break;
    }
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

Widget dashboardScope({
  DashboardRepositories repositories = defaultDashboardTestRepositories,
  ValueChanged<String>? onServiceRequested,
  ValueChanged<String>? onPromptSubmitted,
  ValueChanged<List<String>>? onFavoritesChanged,
  ValueChanged<CardActionRequest>? onCardActionRequested,
  ValueChanged<BankCard>? onCardMorePressed,
  ValueChanged<DepositActionRequest>? onDepositActionRequested,
  ValueChanged<BankDeposit>? onSelectedDepositChanged,
  ValueChanged<LoanActionRequest>? onLoanActionRequested,
  ValueChanged<BankLoan>? onSelectedLoanChanged,
  ValueChanged<BankLoan>? onLoanDetailsRequested,
  VoidCallback? onMenuPressed,
}) => HomeTabTestScope(
  repositories: repositories,
  onServiceRequested: onServiceRequested,
  onPromptSubmitted: onPromptSubmitted,
  onFavoritesChanged: onFavoritesChanged,
  onCardAction: onCardActionRequested,
  onMore: onCardMorePressed,
  onDepositAction: onDepositActionRequested,
  onDepositSelected: onSelectedDepositChanged,
  onLoanAction: onLoanActionRequested,
  onLoanSelected: onSelectedLoanChanged,
  onDetails: onLoanDetailsRequested,
  onMenuPressed: onMenuPressed,
  onCopyNumber: (_) {},
  onCopyIban: (_) {},
  child: const DashboardScreen(),
);

class DashboardTestObserver extends BlocObserver {
  DashboardTestObserver(this.previous, this.onHomeCreated);
  final BlocObserver previous;
  final void Function(HomeCubit) onHomeCreated;
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    previous.onCreate(bloc);
    if (bloc is HomeCubit) onHomeCreated(bloc);
  }
}
