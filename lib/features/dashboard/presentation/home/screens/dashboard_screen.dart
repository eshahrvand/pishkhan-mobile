import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/router/card_features_navigation.dart';
import 'package:pishkhan_mobile/core/router/dashboard_notifications_navigation.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_effect.dart';
import '../widgets/dashboard_home_panel.dart';
import '../../shared/dashboard_services.dart';
import '../../shared/dashboard_tab.dart';
import '../../shared/widgets/dashboard_services_sheet.dart';
import 'cards_tab.dart';
import 'deposits_tab.dart';
import 'loans_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _notifications = DashboardNotificationsNavigation();

  void _openService(
    BuildContext context,
    String id, {
    String? depositNumber,
    String? cardNumber,
  }) {
    final home = context.read<HomeCubit>();
    openCardFeaturesService(
      context,
      id,
      initialDepositNumber: depositNumber,
      initialCardNumber: cardNumber,
      onAssistantPressed: () {
        if (!home.isClosed) home.requestAssistant();
      },
    );
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
      context.read<HomeCubit>().requestService(selected);
    }
  }

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showDashboardResetSheet(context);
    if (!context.mounted || confirmed != true) return;
    context.read<HomeCubit>().resetFavorites();
  }

  void _handleHomeEffect(BuildContext context, HomeState state) {
    switch (state.effect) {
      case HomeServiceRequested(:final serviceId):
        _openService(context, serviceId);
      case HomeCardActionRequested(:final request):
        _openService(
          context,
          request.action.id,
          cardNumber: request.card.number,
        );
      case HomeDepositActionRequested(:final request):
        _openService(
          context,
          request.action.id,
          depositNumber: request.deposit.number,
        );
      case HomeLoanActionRequested(:final request):
        _openService(context, request.action.id);
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
      case HomeMenuRequested(:final category):
        _catalog(context, category: category);
      case HomeFavoritePickerRequested():
        _catalog(context, adding: true);
      case HomeFavoritesResetRequested():
        _reset(context);
      case HomeNotificationsRequested():
        _notifications.open(context);
      case HomeProfileRequested():
      case HomePromptSubmitted():
      case HomeCardMoreRequested():
      case HomeLoanDetailsRequested():
      case HomeCardSelectionChanged():
      case HomeDepositSelectionChanged():
      case HomeLoanSelectionChanged():
      case HomeTabRequested():
      case HomeAssistantRequested():
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) =>
          previous.effectId != current.effectId &&
          current.effect is! HomeCardSelectionChanged &&
          current.effect is! HomeDepositSelectionChanged &&
          current.effect is! HomeLoanSelectionChanged &&
          current.effect is! HomeTabRequested &&
          current.effect is! HomeAssistantRequested,
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
                child: const DashboardHomePanel(),
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
    );
  }
}
