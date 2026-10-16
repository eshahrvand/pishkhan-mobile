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
import '../widgets/dashboard_loans_carousel.dart';
import '../widgets/dashboard_loans_service_group.dart';

class LoansTab extends StatelessWidget {
  const LoansTab({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.loansStatus != current.loansStatus ||
          previous.visibleLoans != current.visibleLoans ||
          previous.loanActions != current.loanActions ||
          previous.loanQuickActions != current.loanQuickActions,
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: context.colors.surfaceSubtle,
            body: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: S.current.dashboardMyLoans,
                    showLeadingActions: false,
                    onMenuPressed: () {
                      context.read<HomeCubit>().requestMenu(
                        AppPrimaryTab.loans,
                      );
                    },
                  ),
                  if (state.visibleLoans.isNotEmpty)
                    const DashboardLoansCarousel(),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 126),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.loansStatus == RequestStatus.initial ||
                                  state.loansStatus == RequestStatus.loading)
                                const DashboardAsyncView(loading: true)
                              else if (state.loansStatus ==
                                  RequestStatus.failure)
                                DashboardAsyncView(
                                  onRetry: () {
                                    context.read<HomeCubit>().loadLoans();
                                  },
                                )
                              else if (state.visibleLoans.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    S.current.loansEmpty,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodyMedium,
                                  ),
                                ),
                              if (state.visibleLoans.isNotEmpty) ...[
                                DashboardLoansServiceGroup(
                                  title: S.current.loansOperations,
                                  actions: state.loanActions,
                                  onActionRequested: (action) {
                                    context.read<HomeCubit>().requestLoanAction(
                                      action,
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                DashboardLoansServiceGroup(
                                  title: S.current.cardsQuickAccess,
                                  actions: state.loanQuickActions,
                                  onActionRequested: (action) {
                                    context.read<HomeCubit>().requestLoanAction(
                                      action,
                                    );
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
                            selectedTab: AppPrimaryTab.loans,
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
