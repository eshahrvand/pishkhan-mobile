import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_deposit_list.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../data/repositories/mock_deposits_repository.dart';
import '../../../domain/entities/listed_deposit.dart';
import '../../../domain/repositories/deposits_repository.dart';
import '../cubit/deposit_list_cubit.dart';
import '../widgets/deposit_account_details_sheet.dart';
import '../widgets/deposit_actions_sheet.dart';
import '../widgets/deposit_filters.dart';
import '../widgets/deposit_ui.dart';

class DepositListScreen extends StatelessWidget {
  const DepositListScreen({
    super.key,
    this.repository,
    this.onActionRequested,
    this.onAssistantPressed,
  });
  final DepositsRepository? repository;
  final ValueChanged<DepositListActionRequest>? onActionRequested;
  final VoidCallback? onAssistantPressed;
  @override
  Widget build(BuildContext context) => BlocProvider(
    // Replacing the repository intentionally starts a fresh list scope.
    key: ObjectKey(repository),
    create: (_) => DepositListCubit(
      repository: repository ?? MockDepositsRepository(),
      initialState: const DepositListState(),
    )..load(),
    child: _DepositListView(
      onActionRequested: onActionRequested,
      onAssistantPressed: onAssistantPressed,
    ),
  );
}

class _DepositListView extends StatelessWidget {
  const _DepositListView({this.onActionRequested, this.onAssistantPressed});
  final ValueChanged<DepositListActionRequest>? onActionRequested;
  final VoidCallback? onAssistantPressed;
  Future<void> _openActions(BuildContext context, ListedDeposit deposit) async {
    final action = await showDepositActionsSheet(context);
    if (!context.mounted || action == null) return;
    if (action == DepositListAction.accountDetails) {
      await showDepositAccountDetailsSheet(context, deposit);
    } else if (onActionRequested != null) {
      onActionRequested!(
        DepositListActionRequest(action: action, deposit: deposit),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.depositListServiceUnavailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: context.colors.surfaceSubtle,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: context.l10n.dashboardDepositsList,
              showLeadingActions: false,
              trailingIcon: depositIcon(AppAssets.depositFeatureBack),
              trailingTooltip: context.l10n.backLabel,
              onTrailingPressed: () => NavigationActions.back(context),
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const DepositFilters(),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 0,
                          child: OverflowBox(
                            minHeight: 1,
                            maxHeight: 1,
                            child: Image.asset(
                              AppAssets.cardFeaturesSeparator,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<DepositListCubit, DepositListState>(
                          buildWhen: (previous, next) =>
                              previous.status != next.status ||
                              previous.visibleDeposits != next.visibleDeposits,
                          builder: (context, state) {
                            if (state.status == RequestStatus.initial ||
                                state.status == RequestStatus.loading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (state.status == RequestStatus.failure) {
                              return Column(
                                children: [
                                  Text(context.l10n.dashboardLoadError),
                                  AppButton(
                                    label: context.l10n.dashboardRetry,
                                    onPressed: context
                                        .read<DepositListCubit>()
                                        .load,
                                  ),
                                ],
                              );
                            }
                            if (state.visibleDeposits.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                child: Text(
                                  state.deposits.isEmpty
                                      ? context.l10n.depositsEmpty
                                      : context.l10n.depositListNoMatches,
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return Column(
                              children: [
                                for (
                                  var i = 0;
                                  i < state.visibleDeposits.length;
                                  i++
                                ) ...[
                                  if (i > 0) const SizedBox(height: 10),
                                  AppDepositList(
                                    alignContentToEdges: true,
                                    title: depositKindLabel(
                                      context,
                                      state.visibleDeposits[i].kind,
                                    ),
                                    accountNumber:
                                        state.visibleDeposits[i].number,
                                    accountNumberLabel:
                                        context.l10n.depositListNumber,
                                    statusFieldLabel:
                                        context.l10n.depositListStatus,
                                    statusLabel: depositStatusLabel(
                                      context,
                                      state.visibleDeposits[i].status,
                                    ),
                                    statusColor: switch (state
                                        .visibleDeposits[i]
                                        .status) {
                                      DepositStatus.open =>
                                        AppBadgeColor.success,
                                      DepositStatus.closed =>
                                        AppBadgeColor.warning,
                                      DepositStatus.blocked =>
                                        AppBadgeColor.error,
                                    },
                                    depositIcon: depositIcon(
                                      AppAssets.depositFeatureDeposit,
                                      size: 20,
                                    ),
                                    moreIcon: Transform.rotate(
                                      angle: -math.pi / 2,
                                      child: depositIcon(
                                        AppAssets.depositFeatureMore,
                                        size: 20,
                                      ),
                                    ),
                                    divider: const DepositDivider(
                                      asset: AppAssets.depositFeatureDivider,
                                    ),
                                    onMoreTap: () => _openActions(
                                      context,
                                      state.visibleDeposits[i],
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: AppAssistantButton(
                      onPressed:
                          onAssistantPressed ??
                          () => NavigationActions.returnHome(context),
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
}
