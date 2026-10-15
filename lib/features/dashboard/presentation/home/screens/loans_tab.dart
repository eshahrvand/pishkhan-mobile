import '../widgets/dashboard_loans_carousel.dart';
import '../widgets/dashboard_loans_service_group.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_async_view.dart';

import '../cubit/loans_cubit.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_loan.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/loan_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/app_primary_navigation.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

/// Loan fetching, persistence, details and service execution are caller-owned.
class LoansTab extends StatefulWidget {
  const LoansTab({
    super.key,
    required this.repository,
    this.onActionRequested,
    this.onSelectedLoanChanged,
    this.onCopyNumber,
    this.onDetailsRequested,
    this.onTabSelected,
    this.onMenuPressed,
    this.onAssistantPressed,
  });
  final DashboardLoansRepository repository;
  final ValueChanged<LoanActionRequest>? onActionRequested;
  final ValueChanged<BankLoan>? onSelectedLoanChanged;
  final ValueChanged<String>? onCopyNumber;
  final ValueChanged<BankLoan>? onDetailsRequested;
  final ValueChanged<AppPrimaryTab>? onTabSelected;
  final VoidCallback? onMenuPressed, onAssistantPressed;
  @override
  State<LoansTab> createState() => _LoansTabState();
}

class _LoansTabState extends State<LoansTab> {
  // Only used by the existing runtime repository update API.
  // Provider owns the instance; UI actions and rendering read the scope directly.
  LoansCubit? _repositoryScope;
  @override
  void didUpdateWidget(covariant LoansTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.repository != oldWidget.repository) {
      _repositoryScope?.changeRepository(widget.repository);
    }
  }

  void _request(BuildContext context, LoanAction action) =>
      widget.onActionRequested?.call(
        LoanActionRequest(
          action: action,
          loan: context.read<LoansCubit>().state.selectedLoan!,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = LoansCubit(repository: widget.repository);
        _repositoryScope = cubit;
        return cubit..load();
      },
      child: BlocBuilder<LoansCubit, LoansState>(
        builder: (context, state) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: context.colors.surfaceSubtle,
            body: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: S.current.dashboardMyLoans,
                    showLeadingActions: false,
                    onMenuPressed: widget.onMenuPressed,
                  ),
                  if (state.visibleItems.isNotEmpty)
                    DashboardLoansCarousel(
                      onCopyNumber: widget.onCopyNumber,
                      onDetailsRequested: widget.onDetailsRequested,
                      onSelectedLoanChanged: widget.onSelectedLoanChanged,
                    ),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 126),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.status == RequestStatus.initial ||
                                  state.status == RequestStatus.loading)
                                const DashboardAsyncView(loading: true)
                              else if (state.status == RequestStatus.failure)
                                DashboardAsyncView(
                                  onRetry: context.read<LoansCubit>().load,
                                )
                              else if (state.visibleItems.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    S.current.loansEmpty,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodyMedium,
                                  ),
                                ),
                              if (state.visibleItems.isNotEmpty) ...[
                                DashboardLoansServiceGroup(
                                  title: S.current.loansOperations,
                                  actions: LoanAction.operations,
                                  onActionRequested: (action) =>
                                      _request(context, action),
                                ),
                                const SizedBox(height: 12),
                                DashboardLoansServiceGroup(
                                  title: S.current.cardsQuickAccess,
                                  actions: LoanAction.quick,
                                  onActionRequested: (action) =>
                                      _request(context, action),
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
                            onPressed: widget.onAssistantPressed ?? () {},
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: AppPrimaryNavigation(
                            selectedTab: AppPrimaryTab.loans,
                            onSelected: (tab) =>
                                widget.onTabSelected?.call(tab),
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
