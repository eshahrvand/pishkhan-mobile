import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/home/cubit/home_cubit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/app_primary_navigation.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_async_view.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_bank_services.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_reso_banner.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/app_wallet_card.dart';

import '../cubit/home_effect.dart';

class DashboardHomePanel extends StatefulWidget {
  const DashboardHomePanel({super.key});

  @override
  State<DashboardHomePanel> createState() => _DashboardHomePanelState();
}

class _DashboardHomePanelState extends State<DashboardHomePanel> {
  final _promptFocus = FocusNode();

  @override
  void dispose() {
    _promptFocus.dispose();
    super.dispose();
  }

  void _applyFocusEffect(BuildContext context, HomeState state) {
    switch (state.effect) {
      case HomeAssistantRequested():
        _promptFocus.requestFocus();
      case HomeTabRequested():
        _promptFocus.unfocus();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<HomeCubit, HomeState>(
        listenWhen: (previous, current) =>
            previous.effectId != current.effectId &&
            (current.effect is HomeAssistantRequested ||
                current.effect is HomeTabRequested),
        listener: _applyFocusEffect,
        buildWhen: (previous, current) {
          return previous.homeStatus != current.homeStatus ||
              previous.homeData != current.homeData ||
              previous.isEditingFavorites != current.isEditingFavorites ||
              previous.selectedTab != current.selectedTab ||
              previous.enableAnimations != current.enableAnimations;
        },
        builder: (context, state) {
          return PopScope(
            canPop:
                !state.isEditingFavorites &&
                state.selectedTab == AppPrimaryTab.dashboard,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) context.read<HomeCubit>().requestBack();
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
                            onNotificationsPressed: () {
                              context.read<HomeCubit>().requestNotifications();
                            },
                            onProfilePressed: () {
                              context.read<HomeCubit>().requestProfile();
                            },
                            onMenuPressed: () {
                              context.read<HomeCubit>().requestMenu();
                            },
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                DashboardAsyncView(
                                  loading:
                                      state.homeStatus ==
                                          RequestStatus.initial ||
                                      state.homeStatus == RequestStatus.loading,
                                  emptyMessage:
                                      state.homeStatus ==
                                              RequestStatus.success &&
                                          state.homeData == null
                                      ? S.current.dashboardEmpty
                                      : null,
                                  onRetry:
                                      state.homeStatus == RequestStatus.failure
                                      ? context.read<HomeCubit>().fetchHome
                                      : null,
                                ),
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 14,
                                  child: AppPrimaryNavigation(
                                    selectedTab: AppPrimaryTab.dashboard,
                                    onSelected: (tab) {
                                      context.read<HomeCubit>().selectTab(tab);
                                    },
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
                            onNotificationsPressed: () {
                              context.read<HomeCubit>().requestNotifications();
                            },
                            onProfilePressed: () {
                              context.read<HomeCubit>().requestProfile();
                            },
                            onMenuPressed: () {
                              context.read<HomeCubit>().requestMenu();
                            },
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
                                              title:
                                                  S.current.walletBalanceTitle,
                                              balance:
                                                  state.homeData!.walletBalance,
                                              currencyLabel:
                                                  S.current.rialCurrency,
                                            ),
                                            const SizedBox(height: 16),
                                            DashboardResoBanner(
                                              focusNode: _promptFocus,
                                              enableAnimations:
                                                  state.enableAnimations,
                                            ),
                                            const SizedBox(height: 16),
                                            DashboardBankServices(
                                              onEdit: () => context
                                                  .read<HomeCubit>()
                                                  .beginFavoritesEditing(),
                                              onAllServices: context
                                                  .read<HomeCubit>()
                                                  .requestAllServices,
                                              onReset: () {
                                                context
                                                    .read<HomeCubit>()
                                                    .requestFavoritesReset();
                                              },
                                              onAdd: () {
                                                context
                                                    .read<HomeCubit>()
                                                    .requestFavoritePicker();
                                              },
                                              onRemove: context
                                                  .read<HomeCubit>()
                                                  .removeFavorite,
                                              onConfirm: () {
                                                context
                                                    .read<HomeCubit>()
                                                    .applyFavorites();
                                              },
                                              onCancel: context
                                                  .read<HomeCubit>()
                                                  .cancelFavorites,
                                              onService: (service) {
                                                context
                                                    .read<HomeCubit>()
                                                    .requestService(service);
                                              },
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
                                    onPressed: () {
                                      context
                                          .read<HomeCubit>()
                                          .requestAssistant();
                                    },
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 14,
                                  child: AppPrimaryNavigation(
                                    selectedTab: AppPrimaryTab.dashboard,
                                    onSelected: (tab) {
                                      context.read<HomeCubit>().selectTab(tab);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
