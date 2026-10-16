import '../cubit/home_cubit.dart';
import '../cubit/home_effect.dart';
import '../widgets/dashboard_home_panel.dart';

import 'package:pishkhan_mobile/core/router/card_features_navigation.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/core/router/dashboard_notifications_navigation.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/loans_tab.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/loan_actions.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/deposits_tab.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/deposit_actions.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_card.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/screens/cards_tab.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/app_primary_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_services_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.onMenuPressed,
    this.onProfilePressed,
    this.enableAnimations = true,
    this.onServiceRequested,
    this.onPromptSubmitted,
    this.onFavoritesChanged,
    this.onCardActionRequested,
    this.onCardMorePressed,
    this.onDepositActionRequested,
    this.onSelectedDepositChanged,
    this.onLoanActionRequested,
    this.onSelectedLoanChanged,
    this.onLoanDetailsRequested,
    this.repositories,
  });

  final VoidCallback? onMenuPressed, onProfilePressed;
  final bool enableAnimations;
  final ValueChanged<String>? onServiceRequested;
  final ValueChanged<String>? onPromptSubmitted;
  final ValueChanged<List<String>>? onFavoritesChanged;
  final ValueChanged<CardActionRequest>? onCardActionRequested;
  final ValueChanged<BankCard>? onCardMorePressed;
  final ValueChanged<DepositActionRequest>? onDepositActionRequested;
  final ValueChanged<BankDeposit>? onSelectedDepositChanged;
  final DashboardRepositories? repositories;
  final ValueChanged<LoanActionRequest>? onLoanActionRequested;
  final ValueChanged<BankLoan>? onSelectedLoanChanged, onLoanDetailsRequested;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Retained only for the existing injected-repository update lifecycle.
  HomeCubit? _repositoryScope;
  final _promptFocus = FocusNode();
  late DashboardRepositories _repositories;
  final _notifications = DashboardNotificationsNavigation();

  void _openNotifications() => _notifications.open(context);

  @override
  void initState() {
    super.initState();
    _repositories =
        widget.repositories ?? context.read<DashboardRepositories>();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.repositories != oldWidget.repositories) {
      _repositories =
          widget.repositories ?? context.read<DashboardRepositories>();
      _repositoryScope?.changeRepositories(_repositories);
    }
  }

  @override
  void dispose() {
    _promptFocus.dispose();
    super.dispose();
  }

  void _openService(BuildContext context, DashboardService service) {
    if (service == DashboardService.assistant &&
        widget.onServiceRequested == null) {
      _promptFocus.requestFocus();
    } else {
      _serviceId(context, service.id);
    }
  }

  void _serviceId(
    BuildContext context,
    String id, {
    String? depositNumber,
    String? cardNumber,
  }) {
    if (widget.onServiceRequested != null) {
      widget.onServiceRequested!(id);
    } else {
      openCardFeaturesService(
        context,
        id,
        initialDepositNumber: depositNumber,
        initialCardNumber: cardNumber,
        onAssistantPressed: () {
          _selectTab(context, AppPrimaryTab.dashboard);
          _promptFocus.requestFocus();
        },
      );
    }
  }

  Future<void> _catalog(
    BuildContext context, {
    bool adding = false,
    List<DashboardService>? category,
  }) async {
    final selected = await showDashboardServicesSheet(
      context,
      excluded: adding
          ? context.read<HomeCubit>().state.activeFavorites
          : const [],
      category: category,
    );
    if (!context.mounted || selected == null) return;
    if (adding) {
      context.read<HomeCubit>().addFavorite(selected.id);
    } else {
      _openService(context, selected);
    }
  }

  Future<void> _reset(BuildContext context) async {
    if (await showDashboardResetSheet(context) != true || !context.mounted) {
      return;
    }
    context.read<HomeCubit>().resetFavorites();
    widget.onFavoritesChanged?.call(
      context.read<HomeCubit>().state.homeData?.favorites ?? const <String>[],
    );
  }

  void _selectTab(BuildContext context, AppPrimaryTab tab) {
    _promptFocus.unfocus();
    context.read<HomeCubit>().selectTab(tab);
  }

  void _handleHomeEffect(BuildContext context, HomeState state) {
    switch (state.effect) {
      case HomeCardActionRequested(:final request):
        if (widget.onCardActionRequested != null) {
          widget.onCardActionRequested!(request);
        } else {
          _serviceId(
            context,
            request.action.id,
            cardNumber: request.card.number,
          );
        }
      case HomeDepositActionRequested(:final request):
        if (widget.onDepositActionRequested != null) {
          widget.onDepositActionRequested!(request);
        } else {
          _serviceId(
            context,
            request.action.id,
            depositNumber: request.deposit.number,
          );
        }
      case HomeLoanActionRequested(:final request):
        if (widget.onLoanActionRequested != null) {
          widget.onLoanActionRequested!(request);
        } else {
          _serviceId(context, request.action.id);
        }
      case HomeCardMoreRequested(:final card):
        widget.onCardMorePressed?.call(card);
      case HomeDepositSelectionChanged(:final deposit):
        widget.onSelectedDepositChanged?.call(deposit);
      case HomeLoanSelectionChanged(:final loan):
        widget.onSelectedLoanChanged?.call(loan);
      case HomeLoanDetailsRequested(:final loan):
        widget.onLoanDetailsRequested?.call(loan);
      case HomeCardNumberCopyRequested(:final number):
        Clipboard.setData(ClipboardData(text: number));
      case HomeCardIbanCopyRequested(:final iban):
        Clipboard.setData(ClipboardData(text: iban));
      case HomeDepositNumberCopyRequested(:final number):
        Clipboard.setData(ClipboardData(text: number));
      case HomeDepositIbanCopyRequested(:final iban):
        Clipboard.setData(ClipboardData(text: iban));
      case HomeLoanNumberCopyRequested(:final number):
        Clipboard.setData(ClipboardData(text: number));
      case HomeTabRequested():
        _promptFocus.unfocus();
      case HomeMenuRequested(:final category):
        if (widget.onMenuPressed != null) {
          widget.onMenuPressed!();
        } else {
          _catalog(context, category: category);
        }
      case HomeAssistantRequested():
        _openService(context, DashboardService.assistant);
      case HomeCardSelectionChanged():
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) {
        final cubit = HomeCubit(repositories: _repositories);
        _repositoryScope = cubit;
        return cubit..load();
      },
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) =>
            previous.effectId != current.effectId,
        listener: _handleHomeEffect,
        child: BlocBuilder<HomeCubit, HomeState>(
          buildWhen: (previous, current) =>
              previous.selectedTab != current.selectedTab,
          builder: (context, state) {
            return IndexedStack(
              index: state.selectedTab.index,
              children: [
                TickerMode(
                  enabled: state.selectedTab == AppPrimaryTab.dashboard,
                  child: DashboardHomePanel(
                    promptFocus: _promptFocus,
                    selectedTab: state.selectedTab,
                    enableAnimations: widget.enableAnimations,
                    onNotificationsPressed: _openNotifications,
                    onProfilePressed: widget.onProfilePressed,
                    onMenuPressed:
                        widget.onMenuPressed ?? () => _catalog(context),
                    onPromptSubmitted: widget.onPromptSubmitted,
                    onFavoritesChanged: widget.onFavoritesChanged,
                    onAddService: () => _catalog(context, adding: true),
                    onResetFavorites: () => _reset(context),
                    onServiceRequested: (service) =>
                        _openService(context, service),
                    onTabSelected: (tab) => _selectTab(context, tab),
                  ),
                ),
                TickerMode(
                  enabled: state.selectedTab == AppPrimaryTab.cards,
                  child: const CardsTab(),
                ),
                TickerMode(
                  enabled: state.selectedTab == AppPrimaryTab.deposits,
                  child: const DepositsTab(),
                ),
                TickerMode(
                  enabled: state.selectedTab == AppPrimaryTab.loans,
                  child: const LoansTab(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
