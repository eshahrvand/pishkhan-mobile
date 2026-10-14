import '../widgets/dashboard_deposits_carousel.dart';
import '../widgets/dashboard_deposits_service_group.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/repositories/dashboard_repositories.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/dashboard_async_view.dart';

import '../cubit/deposits_cubit.dart';


import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/dashboard/domain/entities/bank_deposit.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/deposit_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/features/dashboard/presentation/shared/widgets/app_primary_navigation.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

/// Deposit fetching, persistence and service execution are caller-owned.
class DepositsTab extends StatefulWidget {
  const DepositsTab({
    super.key,
    required this.repository,
    this.onActionRequested,
    this.onSelectedDepositChanged,
    this.onCopyNumber,
    this.onCopyIban,
    this.onTabSelected,
    this.onMenuPressed,
    this.onAssistantPressed,
  });
  final DashboardDepositsRepository repository;
  final ValueChanged<DepositActionRequest>? onActionRequested;
  final ValueChanged<BankDeposit>? onSelectedDepositChanged;
  final ValueChanged<String>? onCopyNumber, onCopyIban;
  final ValueChanged<AppPrimaryTab>? onTabSelected;
  final VoidCallback? onMenuPressed, onAssistantPressed;
  @override
  State<DepositsTab> createState() => _DepositsTabState();
}

class _DepositsTabState extends State<DepositsTab> {
  // Only used by the existing runtime repository update API.
  // Provider owns the instance; UI actions and rendering read the scope directly.
  DepositsCubit? _repositoryScope;
  @override
  void didUpdateWidget(covariant DepositsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.repository != oldWidget.repository) {
      _repositoryScope?.changeRepository(widget.repository);
    }
  }

  void _request(BuildContext context, DepositAction action) =>
      widget.onActionRequested?.call(
        DepositActionRequest(
          action: action,
          deposit: context.read<DepositsCubit>().state.selectedDeposit!,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = DepositsCubit(repository: widget.repository);
        _repositoryScope = cubit;
        return cubit..load();
      },
      child: BlocBuilder<DepositsCubit, DepositsState>(
        builder: (context, state) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            key: const Key('deposits_screen'),
            backgroundColor: context.colors.surfaceSubtle,
            body: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: S.current.depositsMyTitle,
                    showLeadingActions: false,
                    onMenuPressed: widget.onMenuPressed,
                  ),
                  if (state.visibleItems.isNotEmpty)
                    DashboardDepositsCarousel(
                      onCopyNumber: widget.onCopyNumber,
                      onCopyIban: widget.onCopyIban,
                      onSelectedDepositChanged: widget.onSelectedDepositChanged,
                    ),
                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          key: const Key('deposits_services_scroll'),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 126),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.status == RequestStatus.initial ||
                                  state.status == RequestStatus.loading)
                                const DashboardAsyncView(
                                  key: Key("deposits_loading"),
                                  loading: true,
                                )
                              else if (state.status == RequestStatus.failure)
                                DashboardAsyncView(
                                  key: const Key("deposits_error"),
                                  onRetry: context.read<DepositsCubit>().load,
                                )
                              else if (state.visibleItems.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    S.current.depositsEmpty,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodyMedium,
                                  ),
                                ),
                              if (state.visibleItems.isNotEmpty) ...[
                                DashboardDepositsServiceGroup(
                                  groupId: 'deposits_operations',
                                  title: S.current.depositsOperations,
                                  actions: DepositAction.operations,
                                  onActionRequested: (action) =>
                                      _request(context, action),
                                ),
                                const SizedBox(height: 16),
                                if (state
                                    .selectedDeposit!
                                    .hasChequeOperations) ...[
                                  DashboardDepositsServiceGroup(
                                    groupId: 'deposits_cheque_operations',
                                    title: S.current.depositsChequeOperations,
                                    actions: DepositAction.cheques,
                                    onActionRequested: (action) =>
                                        _request(context, action),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                DashboardDepositsServiceGroup(
                                  groupId: 'deposits_quick_access',
                                  title: S.current.cardsQuickAccess,
                                  actions: DepositAction.quick,
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
                            key: const Key('deposits_assistant_button'),
                            onPressed: widget.onAssistantPressed ?? () {},
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: AppPrimaryNavigation(
                            key: const Key('deposits_navigation'),
                            selectedTab: AppPrimaryTab.deposits,
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
