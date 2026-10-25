import 'package:pishkhan_mobile/core/enums/request_status.dart';
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
import '../widgets/dashboard_drawer.dart';
import '../../shared/dashboard_tab.dart';
import '../../shared/dashboard_services.dart';
import '../widgets/dashboard_services_sheet.dart';
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
    final opened = openCardFeaturesService(
      context,
      id,
      initialDepositNumber: depositNumber,
      initialCardNumber: cardNumber,
      onAssistantPressed: home.requestAssistant,
    );
    if (!opened) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.current.cardFeatureUnavailable)));
    }
  }

  Future<void> _handleHomeEffect(BuildContext context, HomeState state) async {
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    switch (state.effect) {
      case HomeAllServicesRequested():
        context.read<HomeCubit>().consumeHomeInteraction();
        context.push<void>(
          AppRoutes.allServices,
          extra: AllServicesRouteArguments(
            context.read<HomeCubit>().requestService,
          ),
        );
      case HomeServiceRequested(:final serviceId):
        context.read<HomeCubit>().consumeHomeInteraction();
        _openService(context, serviceId);
      case HomeCardActionRequested(:final request):
        context.read<HomeCubit>().consumeHomeInteraction();
        _openService(
          context,
          request.action.id,
          cardNumber: request.card.number,
        );
      case HomeDepositActionRequested(:final request):
        context.read<HomeCubit>().consumeHomeInteraction();
        _openService(
          context,
          request.action.id,
          depositNumber: request.deposit.number,
        );
      case HomeLoanActionRequested(:final request):
        context.read<HomeCubit>().consumeHomeInteraction();
        _openService(context, request.action.id);
      case HomeCardNumberCopyRequested(:final number):
        context.read<HomeCubit>().consumeHomeInteraction();
        Clipboard.setData(ClipboardData(text: number));
      case HomeCardIbanCopyRequested(:final iban):
        context.read<HomeCubit>().consumeHomeInteraction();
        Clipboard.setData(ClipboardData(text: iban));
      case HomeDepositNumberCopyRequested(:final number):
        context.read<HomeCubit>().consumeHomeInteraction();
        Clipboard.setData(ClipboardData(text: number));
      case HomeDepositIbanCopyRequested(:final iban):
        context.read<HomeCubit>().consumeHomeInteraction();
        Clipboard.setData(ClipboardData(text: iban));
      case HomeLoanNumberCopyRequested(:final number):
        context.read<HomeCubit>().consumeHomeInteraction();
        Clipboard.setData(ClipboardData(text: number));
      case HomeMenuRequested():
        context.read<HomeCubit>().consumeHomeInteraction();
        final selection = await showDashboardDrawer(context);
        if (context.mounted) {
          context.read<HomeCubit>().applyDrawerSelection(selection);
        }
      case HomeFavoritePickerRequested():
        context.read<HomeCubit>().consumeHomeInteraction();
        final service = await showDashboardServicesSheet(context);
        if (context.mounted) {
          context.read<HomeCubit>().applyFavoriteSelection(service);
        }
      case HomeFavoritesResetRequested():
        context.read<HomeCubit>().consumeHomeInteraction();
        final confirmed = await showDashboardResetSheet(context);
        if (context.mounted) {
          context.read<HomeCubit>().applyResetConfirmation(confirmed);
        }
      case HomeNotificationsRequested():
        context.read<HomeCubit>().consumeHomeInteraction();
        DashboardNotificationsNavigation().open(
          context,
          messages: state.messages!,
          onChanged: context.read<HomeCubit>().updateNotifications,
        );
      case HomeProfileRequested():
      case HomePromptSubmitted():
      case HomeCardMoreRequested():
      case HomeLoanDetailsRequested():
        context.read<HomeCubit>().consumeHomeInteraction();
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
      create: (_) => HomeCubit(
        drawerSectionLabels: dashboardDrawerSectionLabels(),
        drawerServiceLabels: dashboardDrawerServiceLabels(),
        servicePickerLabels: getDashboardServiceSearchLabels(),
      )..fetchDashboard(),
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) =>
            ((previous.effect != current.effect && current.effect != null) &&
                current.effect is! HomeTabRequested &&
                current.effect is! HomeAssistantRequested) ||
            ((previous.homeStatus != current.homeStatus &&
                    current.homeStatus == RequestStatus.failure) ||
                (previous.cardsStatus != current.cardsStatus &&
                    current.cardsStatus == RequestStatus.failure) ||
                (previous.depositsStatus != current.depositsStatus &&
                    current.depositsStatus == RequestStatus.failure) ||
                (previous.loansStatus != current.loansStatus &&
                    current.loansStatus == RequestStatus.failure)),
        listener: _handleHomeEffect,
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            // Inactive tabs must not duplicate snackbar Heroes during navigation.
            return PopScope(
              canPop:
                  state.homeStatus != RequestStatus.loading &&
                  state.cardsStatus != RequestStatus.loading &&
                  state.depositsStatus != RequestStatus.loading &&
                  state.loansStatus != RequestStatus.loading,
              child: TooltipVisibility(
                visible: false,
                child: IndexedStack(
                  index: state.selectedTab.index,
                  children: [
                    TickerMode(
                      enabled: state.selectedTab == AppPrimaryTab.dashboard,
                      child: HeroMode(
                        enabled: state.selectedTab == AppPrimaryTab.dashboard,
                        child: const DashboardHomePanel(),
                      ),
                    ),
                    TickerMode(
                      enabled: state.selectedTab == AppPrimaryTab.cards,
                      child: HeroMode(
                        enabled: state.selectedTab == AppPrimaryTab.cards,
                        child: const CardsTab(),
                      ),
                    ),
                    TickerMode(
                      enabled: state.selectedTab == AppPrimaryTab.deposits,
                      child: HeroMode(
                        enabled: state.selectedTab == AppPrimaryTab.deposits,
                        child: const DepositsTab(),
                      ),
                    ),
                    TickerMode(
                      enabled: state.selectedTab == AppPrimaryTab.loans,
                      child: HeroMode(
                        enabled: state.selectedTab == AppPrimaryTab.loans,
                        child: const LoansTab(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
