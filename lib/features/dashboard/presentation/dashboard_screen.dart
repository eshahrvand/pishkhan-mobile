import 'package:pishkhan_mobile/core/router/card_features_navigation.dart';
import 'package:pishkhan_mobile/features/dashboard/data/mock/mock_dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/core/router/dashboard_notifications_navigation.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/cubit/dashboard_navigation_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_async_view.dart';
import 'package:pishkhan_mobile/features/dashboard/data/mock/dashboard_mock_data.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/loans/loans_tab.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/loans/loan_actions.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/deposits/deposits_tab.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/deposits/deposit_actions.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_card.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/tabs/cards/cards_tab.dart';
import 'package:pishkhan_mobile/shared/widgets/app_primary_navigation.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_assets.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_bank_services.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_all_services_screen.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_header.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_reso_banner.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_services_sheet.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

import 'package:pishkhan_mobile/shared/widgets/app_wallet_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.onMenuPressed,
    this.onProfilePressed,
    this.enableAnimations = true,
    this.onServiceRequested,
    this.onPromptSubmitted,
    this.onFavoritesChanged,
    this.initialFavorites = const [],
    this.cards = DashboardMockData.cards,
    this.onCardActionRequested,
    this.onCardMorePressed,
    this.deposits = DashboardMockData.deposits,
    this.onDepositActionRequested,
    this.onSelectedDepositChanged,
    this.loans = DashboardMockData.loans,
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
  final List<String> initialFavorites;
  final List<BankCard> cards;
  final ValueChanged<CardActionRequest>? onCardActionRequested;
  final ValueChanged<BankCard>? onCardMorePressed;
  final List<BankDeposit> deposits;
  final ValueChanged<DepositActionRequest>? onDepositActionRequested;
  final ValueChanged<BankDeposit>? onSelectedDepositChanged;
  final DashboardRepositories? repositories;
  final List<BankLoan> loans;
  final ValueChanged<LoanActionRequest>? onLoanActionRequested;
  final ValueChanged<BankLoan>? onSelectedLoanChanged, onLoanDetailsRequested;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardCubit _cubit;
  final _promptFocus = FocusNode();
  late DashboardRepositories _repositories;
  final _navigationCubit = DashboardNavigationCubit();
  AppPrimaryTab get _selectedTab => _navigationCubit.state.selectedTab;
  final _notifications = DashboardNotificationsNavigation();

  void _openNotifications() => _notifications.open(context);

  DashboardRepositories _dependencies() =>
      widget.repositories ??
      DashboardRepositories(
        home: MockDashboardHomeRepository(
          favorites: widget.initialFavorites
              .where(
                (id) =>
                    DashboardService.values.any((service) => service.id == id),
              )
              .toList(),
        ),
        cards: MockDashboardCardsRepository(cards: widget.cards),
        deposits: MockDashboardDepositsRepository(deposits: widget.deposits),
        loans: MockDashboardLoansRepository(loans: widget.loans),
      );
  @override
  void initState() {
    super.initState();
    _repositories = _dependencies();
    _cubit = DashboardCubit(repository: _repositories.home)..load();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.repositories != oldWidget.repositories ||
        widget.cards != oldWidget.cards ||
        widget.deposits != oldWidget.deposits ||
        widget.loans != oldWidget.loans ||
        widget.initialFavorites != oldWidget.initialFavorites) {
      final previousHome = _repositories.home;
      final previous = _repositories;
      final next = _dependencies();
      _repositories =
          widget.repositories == null && oldWidget.repositories == null
          ? DashboardRepositories(
              home: widget.initialFavorites == oldWidget.initialFavorites
                  ? previous.home
                  : next.home,
              cards: widget.cards == oldWidget.cards
                  ? previous.cards
                  : next.cards,
              deposits: widget.deposits == oldWidget.deposits
                  ? previous.deposits
                  : next.deposits,
              loans: widget.loans == oldWidget.loans
                  ? previous.loans
                  : next.loans,
            )
          : next;
      if (previousHome != _repositories.home) {
        _cubit.changeRepository(_repositories.home);
      }
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _navigationCubit.close();
    _promptFocus.dispose();
    super.dispose();
  }

  void _openService(DashboardService service) {
    if (service == DashboardService.assistant &&
        widget.onServiceRequested == null) {
      _promptFocus.requestFocus();
    } else {
      _serviceId(service.id);
    }
  }

  void _serviceId(String id, {String? depositNumber, String? cardNumber}) {
    if (widget.onServiceRequested != null) {
      widget.onServiceRequested!(id);
    } else {
      openCardFeaturesService(
        context,
        id,
        initialDepositNumber: depositNumber,
        initialCardNumber: cardNumber,
        onAssistantPressed: () {
          _selectTab(AppPrimaryTab.dashboard);
          _promptFocus.requestFocus();
        },
      );
    }
  }

  Future<void> _catalog({
    bool adding = false,
    List<DashboardService>? category,
  }) async {
    final selected = await showDashboardServicesSheet(
      context,
      excluded: adding ? _cubit.state.visibleFavorites.toSet() : const {},
      category: category,
    );
    if (!mounted || selected == null) return;
    if (adding) {
      _cubit.add(selected.id);
    } else {
      _openService(selected);
    }
  }

  Future<void> _reset() async {
    if (await showDashboardResetSheet(context) != true || !mounted) return;
    _cubit.reset();
    widget.onFavoritesChanged?.call(_cubit.state.favorites);
  }

  void _selectTab(AppPrimaryTab tab) {
    _promptFocus.unfocus();
    _navigationCubit.select(tab);
  }

  @override
  Widget build(BuildContext context) =>
      BlocSelector<
        DashboardNavigationCubit,
        DashboardNavigationState,
        AppPrimaryTab
      >(
        bloc: _navigationCubit,
        selector: (state) => state.selectedTab,
        builder: (context, selectedTab) => IndexedStack(
          index: _selectedTab.index,
          children: [
            TickerMode(
              enabled: _selectedTab == AppPrimaryTab.dashboard,
              child: _dashboard(context),
            ),
            TickerMode(
              enabled: _selectedTab == AppPrimaryTab.cards,
              child: CardsTab(
                repository: _repositories.cards,
                onTabSelected: _selectTab,
                onMenuPressed: widget.onMenuPressed ?? () => _catalog(),
                onAssistantPressed: () {
                  _selectTab(AppPrimaryTab.dashboard);
                  _openService(DashboardService.assistant);
                },
                onMorePressed: widget.onCardMorePressed,
                onActionRequested: (request) {
                  if (widget.onCardActionRequested != null) {
                    widget.onCardActionRequested!(request);
                  } else {
                    _serviceId(
                      request.action.id,
                      cardNumber: request.card.number,
                    );
                  }
                },
              ),
            ),
            TickerMode(
              enabled: _selectedTab == AppPrimaryTab.deposits,
              child: DepositsTab(
                repository: _repositories.deposits,
                onTabSelected: _selectTab,
                onMenuPressed:
                    widget.onMenuPressed ??
                    () => _catalog(category: DashboardService.deposits),
                onAssistantPressed: () {
                  _selectTab(AppPrimaryTab.dashboard);
                  _openService(DashboardService.assistant);
                },
                onSelectedDepositChanged: widget.onSelectedDepositChanged,
                onActionRequested: (request) {
                  if (widget.onDepositActionRequested != null) {
                    widget.onDepositActionRequested!(request);
                  } else {
                    _serviceId(
                      request.action.id,
                      depositNumber: request.deposit.number,
                    );
                  }
                },
              ),
            ),
            TickerMode(
              enabled: _selectedTab == AppPrimaryTab.loans,
              child: LoansTab(
                repository: _repositories.loans,
                onTabSelected: _selectTab,
                onMenuPressed:
                    widget.onMenuPressed ??
                    () => _catalog(category: DashboardService.loans),
                onAssistantPressed: () {
                  _selectTab(AppPrimaryTab.dashboard);
                  _openService(DashboardService.assistant);
                },
                onSelectedLoanChanged: widget.onSelectedLoanChanged,
                onDetailsRequested: widget.onLoanDetailsRequested,
                onActionRequested: (request) {
                  if (widget.onLoanActionRequested != null) {
                    widget.onLoanActionRequested!(request);
                  } else {
                    _serviceId(request.action.id);
                  }
                },
              ),
            ),
          ],
        ),
      );

  Widget _dashboard(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: BlocBuilder<DashboardCubit, DashboardState>(
      bloc: _cubit,
      builder: (context, state) => PopScope(
        canPop: !state.isEditing && _selectedTab == AppPrimaryTab.dashboard,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            if (_selectedTab != AppPrimaryTab.dashboard) {
              _selectTab(AppPrimaryTab.dashboard);
            } else {
              _cubit.cancel();
            }
          }
        },
        child: state is! DashboardLoaded
            ? _homeStatus(context, state)
            : Scaffold(
                backgroundColor: context.colors.surfaceSubtle,
                body: SafeArea(
                  child: Column(
                    children: [
                      DashboardHeader(
                        onNotificationsPressed: _openNotifications,
                        onProfilePressed: widget.onProfilePressed,
                        onMenuPressed: widget.onMenuPressed ?? () => _catalog(),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            SingleChildScrollView(
                              key: const Key('dashboard_scroll'),
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    height: 122,
                                    child: SvgPicture.asset(
                                      DashboardAssets.patternUp,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Positioned(
                                    top: 1141,
                                    left: 0,
                                    right: 0,
                                    height: 122,
                                    child: SvgPicture.asset(
                                      DashboardAssets.patternDown,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      16,
                                      16,
                                      126,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        AppWalletCard(
                                          title:
                                              context.l10n.walletBalanceTitle,
                                          balance: state.data.walletBalance,
                                          currencyLabel:
                                              context.l10n.rialCurrency,
                                        ),
                                        const SizedBox(height: 16),
                                        DashboardResoBanner(
                                          focusNode: _promptFocus,
                                          enableAnimations:
                                              widget.enableAnimations,
                                          onPromptSubmitted:
                                              widget.onPromptSubmitted,
                                        ),
                                        const SizedBox(height: 16),
                                        DashboardBankServices(
                                          state: state,
                                          fixedServices: [
                                            for (final id
                                                in state.data.fixedServiceIds)
                                              for (final service
                                                  in DashboardService.values)
                                                if (service.id == id) service,
                                          ],
                                          onEdit: () => _cubit.edit(
                                            suggestions:
                                                state.data.suggestedServiceIds,
                                          ),
                                          onAllServices: () =>
                                              Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                  builder: (_) =>
                                                      DashboardAllServicesScreen(
                                                        onServiceRequested:
                                                            _openService,
                                                      ),
                                                ),
                                              ),
                                          onReset: _reset,
                                          onAdd: () => _catalog(adding: true),
                                          onRemove: _cubit.remove,
                                          onConfirm: () {
                                            _cubit.confirm();
                                            widget.onFavoritesChanged?.call(
                                              _cubit.state.favorites,
                                            );
                                          },
                                          onCancel: _cubit.cancel,
                                          onService: _openService,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 16,
                              bottom: 82,
                              child: AppAssistantButton(
                                key: const Key('dashboard_assistant_button'),
                                onPressed: () =>
                                    _openService(DashboardService.assistant),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 14,
                              child: _navigation(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    ),
  );

  Widget _homeStatus(BuildContext context, DashboardState state) => Scaffold(
    backgroundColor: context.colors.surfaceSubtle,
    body: SafeArea(
      child: Column(
        children: [
          DashboardHeader(
            onNotificationsPressed: _openNotifications,
            onProfilePressed: widget.onProfilePressed,
            onMenuPressed: widget.onMenuPressed ?? () => _catalog(),
          ),
          Expanded(
            child: Stack(
              children: [
                DashboardAsyncView(
                  key: const Key('dashboard_home_status'),
                  loading:
                      state is DashboardInitial || state is DashboardLoading,
                  emptyMessage: state is DashboardEmpty
                      ? context.l10n.dashboardEmpty
                      : null,
                  onRetry: state is DashboardError ? _cubit.load : null,
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: _navigation(context),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _navigation(BuildContext context) => AppPrimaryNavigation(
    key: const Key('dashboard_navigation'),
    selectedTab: AppPrimaryTab.dashboard,
    onSelected: _selectTab,
  );
}
