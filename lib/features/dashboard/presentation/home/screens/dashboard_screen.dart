import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/router/card_features_navigation.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/router/app_router.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/core/router/dashboard_notifications_navigation.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_effect.dart';
import '../widgets/dashboard_home_panel.dart';
import '../../shared/dashboard_tab.dart';
import '../../shared/widgets/dashboard_services_sheet.dart';
import '../../shared/widgets/dashboard_reset_sheet.dart';
import 'cards_tab.dart';
import 'deposits_tab.dart';
import 'loans_tab.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
      onAssistantPressed: home.requestAssistant,
    );
  }

  Future<void> _handleHomeEffect(BuildContext context, HomeState state) async {
    switch (state.effect) {
      case HomeAllServicesRequested():
        context.push<void>(
          AppRoutes.allServices,
          extra: AllServicesRouteArguments(
            context.read<HomeCubit>().requestService,
          ),
        );
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
        final service = await showDashboardServicesSheet(
          context,
          category: category,
        );
        if (context.mounted) {
          context.read<HomeCubit>().applyMenuSelection(service);
        }
      case HomeFavoritePickerRequested(:final excluded):
        final service = await showDashboardServicesSheet(
          context,
          excluded: excluded,
        );
        if (context.mounted) {
          context.read<HomeCubit>().applyFavoriteSelection(service);
        }
      case HomeFavoritesResetRequested():
        final confirmed = await showDashboardResetSheet(context);
        if (context.mounted) {
          context.read<HomeCubit>().applyResetConfirmation(confirmed);
        }
      case HomeNotificationsRequested():
        DashboardNotificationsNavigation().open(
          context,
          messages: state.messages!,
          onChanged: context.read<HomeCubit>().updateNotifications,
        );
      case HomeProfileRequested():
      case HomePromptSubmitted():
      case HomeCardMoreRequested():
      case HomeLoanDetailsRequested():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.cardFeatureUnavailable)),
        );
      case HomeTabRequested():
      case HomeAssistantRequested():
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) => HomeCubit()..fetchDashboard(),
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) =>
            previous.effectId != current.effectId &&
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
      ),
    );
  }
}
