import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/features/dashboard/dashboard_routes.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_async_view.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/app_primary_navigation.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/dashboard_cubit.dart';
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
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) => PopScope(
          canPop: state.draft == null && selectedTab == AppPrimaryTab.dashboard,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              if (selectedTab != AppPrimaryTab.dashboard) {
                onTabSelected(AppPrimaryTab.dashboard);
              } else {
                context.read<DashboardCubit>().cancel();
              }
            }
          },
          child: state.status != RequestStatus.success || state.data == null
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
                                key: const Key('dashboard_home_status'),
                                loading:
                                    state.status == RequestStatus.initial ||
                                    state.status == RequestStatus.loading,
                                emptyMessage:
                                    state.status == RequestStatus.success &&
                                        state.data == null
                                    ? S.current.dashboardEmpty
                                    : null,
                                onRetry: state.status == RequestStatus.failure
                                    ? context.read<DashboardCubit>().load
                                    : null,
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 14,
                                child: AppPrimaryNavigation(
                                  key: const Key('dashboard_navigation'),
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
                                            balance: state.data!.walletBalance,
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
                                                .read<DashboardCubit>()
                                                .edit(
                                                  suggestions: state
                                                      .data!
                                                      .suggestedServiceIds,
                                                ),
                                            onAllServices: () =>
                                                context.push<void>(
                                                  DashboardRoutes.allServices,
                                                  extra:
                                                      AllServicesRouteArguments(
                                                        onServiceRequested,
                                                      ),
                                                ),
                                            onReset: onResetFavorites,
                                            onAdd: onAddService,
                                            onRemove: context
                                                .read<DashboardCubit>()
                                                .remove,
                                            onConfirm: () {
                                              context
                                                  .read<DashboardCubit>()
                                                  .confirm();
                                              onFavoritesChanged?.call(
                                                context
                                                        .read<DashboardCubit>()
                                                        .state
                                                        .data
                                                        ?.favorites ??
                                                    const <String>[],
                                              );
                                            },
                                            onCancel: context
                                                .read<DashboardCubit>()
                                                .cancel,
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
                                  key: const Key('dashboard_assistant_button'),
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
                                  key: const Key('dashboard_navigation'),
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
