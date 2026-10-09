import 'package:pishkhan_mobile/features/cards/models/bank_card.dart';
import 'package:pishkhan_mobile/features/cards/presentation/cards_screen.dart';
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
import 'package:pishkhan_mobile/features/notifications/models/notification_message.dart';
import 'package:pishkhan_mobile/features/notifications/presentation/notifications_screen.dart';
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
    this.cards = BankCard.examples,
    this.onCardActionRequested,
    this.onCardMorePressed,
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

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardCubit _cubit;
  final _promptFocus = FocusNode();
  AppPrimaryTab _selectedTab = AppPrimaryTab.dashboard;
  List<NotificationMessage>? _notifications;

  void _openNotifications() {
    _notifications ??= NotificationMessage.examples(context.l10n);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationsScreen(
          messages: _notifications!,
          onChanged: (messages) => _notifications = messages,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _cubit = DashboardCubit(
      favorites: widget.initialFavorites.where(
        (id) => DashboardService.values.any((service) => service.id == id),
      ),
    );
  }

  @override
  void dispose() {
    _cubit.close();
    _promptFocus.dispose();
    super.dispose();
  }

  void _openService(DashboardService service) {
    if (service == DashboardService.assistant &&
        widget.onServiceRequested == null) {
      _promptFocus.requestFocus();
    } else {
      widget.onServiceRequested?.call(service.id);
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
    if (tab == AppPrimaryTab.cards || tab == AppPrimaryTab.dashboard) {
      _promptFocus.unfocus();
      setState(() => _selectedTab = tab);
    } else {
      _catalog(
        category: tab == AppPrimaryTab.deposits
            ? DashboardService.deposits
            : DashboardService.loans,
      );
    }
  }

  @override
  Widget build(BuildContext context) => IndexedStack(
    index: _selectedTab == AppPrimaryTab.cards ? 1 : 0,
    children: [
      TickerMode(
        enabled: _selectedTab == AppPrimaryTab.dashboard,
        child: _dashboard(context),
      ),
      TickerMode(
        enabled: _selectedTab == AppPrimaryTab.cards,
        child: CardsScreen(
          cards: widget.cards,
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
              widget.onServiceRequested?.call(request.action.id);
            }
          },
        ),
      ),
    ],
  );

  Widget _dashboard(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: BlocBuilder<DashboardCubit, DashboardState>(
      bloc: _cubit,
      builder: (context, state) => PopScope(
        canPop: !state.isEditing && _selectedTab != AppPrimaryTab.cards,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            if (_selectedTab == AppPrimaryTab.cards) {
              _selectTab(AppPrimaryTab.dashboard);
            } else {
              _cubit.cancel();
            }
          }
        },
        child: Scaffold(
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AppWalletCard(
                                    title: context.l10n.walletBalanceTitle,
                                    balance:
                                        context.l10n.dashboardWalletBalance,
                                    currencyLabel: context.l10n.rialCurrency,
                                  ),
                                  const SizedBox(height: 16),
                                  DashboardResoBanner(
                                    focusNode: _promptFocus,
                                    enableAnimations: widget.enableAnimations,
                                    onPromptSubmitted: widget.onPromptSubmitted,
                                  ),
                                  const SizedBox(height: 16),
                                  DashboardBankServices(
                                    state: state,
                                    onEdit: () => _cubit.edit(
                                      suggestions: DashboardService.recommended
                                          .map((service) => service.id),
                                    ),
                                    onAllServices: () => Navigator.of(context)
                                        .push(
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

  Widget _navigation(BuildContext context) => AppPrimaryNavigation(
    key: const Key('dashboard_navigation'),
    selectedTab: AppPrimaryTab.dashboard,
    onSelected: _selectTab,
  );
}
