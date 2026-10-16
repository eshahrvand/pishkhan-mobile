import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/router/app_router.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_async_view.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/app_primary_navigation.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/dashboard_services.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_bank_services.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_reso_banner.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import 'package:pishkhan_mobile/shared/widgets/app_wallet_card.dart';

class DashboardHomePanel extends StatelessWidget {
  const DashboardHomePanel({
    super.key,
    required this.promptFocus,
    required this.selectedTab,
    required this.enableAnimations,
    required this.onMenuPressed,
    required this.onNotificationsPressed,
    this.onProfilePressed,
    required this.onAddService,
    required this.onResetFavorites,
    required this.onServiceRequested,
    required this.onTabSelected,
    this.onPromptSubmitted,
    this.onFavoritesChanged,
  });
  final FocusNode promptFocus;
  final AppPrimaryTab selectedTab;
  final bool enableAnimations;
  final VoidCallback onMenuPressed;
  final VoidCallback onNotificationsPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback onAddService;
  final VoidCallback onResetFavorites;
  final ValueChanged<DashboardService> onServiceRequested;
  final ValueChanged<AppPrimaryTab> onTabSelected;
  final ValueChanged<String>? onPromptSubmitted;
  final ValueChanged<List<String>>? onFavoritesChanged;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: (previous, current) {
          return previous.homeStatus != current.homeStatus ||
              previous.homeData != current.homeData ||
              previous.draft != current.draft;
        },
        builder: (context, state) => PopScope(
          canPop: state.draft == null && selectedTab == AppPrimaryTab.dashboard,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              if (selectedTab != AppPrimaryTab.dashboard) {
                onTabSelected(AppPrimaryTab.dashboard);
              } else {
                context.read<HomeCubit>().cancelFavorites();
              }
            }
          },
          child:
              state.homeStatus != RequestStatus.success ||
                  state.homeData == null
              ? Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Column(
                      children: [
                        AppTopBar(
                          onNotificationsPressed: onNotificationsPressed,
                          onProfilePressed: onProfilePressed,
                          onMenuPressed: onMenuPressed,
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              DashboardAsyncView(
                                loading:
                                    state.homeStatus == RequestStatus.initial ||
                                    state.homeStatus == RequestStatus.loading,
                                emptyMessage:
                                    state.homeStatus == RequestStatus.success &&
                                        state.homeData == null
                                    ? S.current.dashboardEmpty
                                    : null,
                                onRetry:
                                    state.homeStatus == RequestStatus.failure
                                    ? context.read<HomeCubit>().loadHome
                                    : null,
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 14,
                                child: AppPrimaryNavigation(
                                  selectedTab: AppPrimaryTab.dashboard,
                                  onSelected: onTabSelected,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Column(
                      children: [
                        AppTopBar(
                          onNotificationsPressed: onNotificationsPressed,
                          onProfilePressed: onProfilePressed,
                          onMenuPressed: onMenuPressed,
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              SingleChildScrollView(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      height: 122,
                                      child: AvpImage(
                                        image: AppAssets.dashboardPatternUp,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    Positioned(
                                      top: 1141,
                                      left: 0,
                                      right: 0,
                                      height: 122,
                                      child: AvpImage(
                                        image: AppAssets.dashboardPatternDown,
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
                                            title: S.current.walletBalanceTitle,
                                            balance:
                                                state.homeData!.walletBalance,
                                            currencyLabel:
                                                S.current.rialCurrency,
                                          ),
                                          const SizedBox(height: 16),
                                          DashboardResoBanner(
                                            focusNode: promptFocus,
                                            enableAnimations: enableAnimations,
                                            onPromptSubmitted:
                                                onPromptSubmitted,
                                          ),
                                          const SizedBox(height: 16),
                                          DashboardBankServices(
                                            onEdit: () => context
                                                .read<HomeCubit>()
                                                .editFavorites(),
                                            onAllServices: () =>
                                                context.push<void>(
                                                  AppRoutes.allServices,
                                                  extra:
                                                      AllServicesRouteArguments(
                                                        onServiceRequested,
                                                      ),
                                                ),
                                            onReset: onResetFavorites,
                                            onAdd: onAddService,
                                            onRemove: context
                                                .read<HomeCubit>()
                                                .removeFavorite,
                                            onConfirm: () {
                                              context
                                                  .read<HomeCubit>()
                                                  .confirmFavorites();
                                              onFavoritesChanged?.call(
                                                context
                                                        .read<HomeCubit>()
                                                        .state
                                                        .homeData
                                                        ?.favorites ??
                                                    const <String>[],
                                              );
                                            },
                                            onCancel: context
                                                .read<HomeCubit>()
                                                .cancelFavorites,
                                            onService: onServiceRequested,
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
                                  onPressed: () => onServiceRequested(
                                    DashboardService.assistant,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 14,
                                child: AppPrimaryNavigation(
                                  selectedTab: AppPrimaryTab.dashboard,
                                  onSelected: onTabSelected,
                                ),
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
  }
}
