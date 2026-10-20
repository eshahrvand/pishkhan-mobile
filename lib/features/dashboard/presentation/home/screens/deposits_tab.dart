import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';

import '../../shared/widgets/app_primary_navigation.dart';
import '../../shared/widgets/dashboard_async_view.dart';
import '../cubit/home_cubit.dart';
import '../widgets/dashboard_deposits_carousel.dart';
import '../widgets/dashboard_deposits_service_group.dart';

class DepositsTab extends StatelessWidget {
  const DepositsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.depositsStatus != current.depositsStatus ||
          previous.visibleDeposits != current.visibleDeposits ||
          previous.depositActions != current.depositActions ||
          previous.depositQuickActions != current.depositQuickActions ||
          previous.depositChequeActions != current.depositChequeActions,
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: context.colors.surfaceSubtle,
            body: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: S.current.depositsMyTitle,
                    showLeadingActions: false,
                    onMenuPressed: () {
                      context.read<HomeCubit>().requestMenu();
                    },
                  ),
                  if (state.visibleDeposits.isNotEmpty)
                    const DashboardDepositsCarousel(),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 126),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.depositsStatus ==
                                      RequestStatus.initial ||
                                  state.depositsStatus == RequestStatus.loading)
                                const DashboardAsyncView(loading: true)
                              else if (state.depositsStatus ==
                                  RequestStatus.failure)
                                DashboardAsyncView(
                                  onRetry: () {
                                    context.read<HomeCubit>().fetchDeposits();
                                  },
                                )
                              else if (state.visibleDeposits.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    S.current.depositsEmpty,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodyMedium,
                                  ),
                                ),
                              if (state.visibleDeposits.isNotEmpty) ...[
                                DashboardDepositsServiceGroup(
                                  title: S.current.depositsOperations,
                                  actions: state.depositActions,
                                  onActionRequested: (action) {
                                    context
                                        .read<HomeCubit>()
                                        .requestDepositAction(action);
                                  },
                                ),
                                const SizedBox(height: 16),
                                if (state.depositChequeActions.isNotEmpty) ...[
                                  DashboardDepositsServiceGroup(
                                    title: S.current.depositsChequeOperations,
                                    actions: state.depositChequeActions,
                                    onActionRequested: (action) {
                                      context
                                          .read<HomeCubit>()
                                          .requestDepositAction(action);
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                DashboardDepositsServiceGroup(
                                  title: S.current.cardsQuickAccess,
                                  actions: state.depositQuickActions,
                                  onActionRequested: (action) {
                                    context
                                        .read<HomeCubit>()
                                        .requestDepositAction(action);
                                  },
                                  quick: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 84,
                          child: AppAssistantButton(
                            onPressed: () {
                              context.read<HomeCubit>().requestAssistant();
                            },
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: AppPrimaryNavigation(
                            selectedTab: AppPrimaryTab.deposits,
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
    );
  }
}
