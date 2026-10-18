import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_deposit_list.dart';

import '../../../domain/entities/listed_deposit.dart';
import '../cubit/deposit_list_cubit.dart';
import 'deposit_ui.dart';

class DepositListContent extends StatelessWidget {
  const DepositListContent({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepositListCubit, DepositListState>(
      buildWhen: (previous, current) =>
          previous.depositsStatus != current.depositsStatus ||
          previous.visibleDeposits != current.visibleDeposits ||
          previous.deposits != current.deposits,
      builder: (context, state) {
        if (state.depositsStatus == RequestStatus.initial ||
            state.depositsStatus == RequestStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.depositsStatus == RequestStatus.failure) {
          return Column(
            children: [
              Text(S.current.dashboardLoadError),
              AppButton(
                label: S.current.dashboardRetry,
                onPressed: context.read<DepositListCubit>().fetchDeposits,
              ),
            ],
          );
        }
        if (state.visibleDeposits.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              state.deposits.isEmpty
                  ? S.current.depositsEmpty
                  : S.current.depositListNoMatches,
              textAlign: TextAlign.center,
            ),
          );
        }
        return Column(
          children: [
            for (var i = 0; i < state.visibleDeposits.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              AppDepositList(
                alignContentToEdges: true,
                title: depositKindLabel(state.visibleDeposits[i].kind),
                accountNumber: state.visibleDeposits[i].number,
                accountNumberLabel: S.current.depositListNumber,
                statusFieldLabel: S.current.depositListStatus,
                statusLabel: depositStatusLabel(
                  state.visibleDeposits[i].status,
                ),
                statusColor: switch (state.visibleDeposits[i].status) {
                  DepositStatus.open => AppBadgeColor.success,
                  DepositStatus.closed => AppBadgeColor.warning,
                  DepositStatus.blocked => AppBadgeColor.error,
                },
                depositIcon: depositIcon(
                  AppAssets.depositFeatureDeposit,
                  size: 20,
                ),
                moreIcon: Transform.rotate(
                  angle: -math.pi / 2,
                  child: depositIcon(AppAssets.depositFeatureMore, size: 20),
                ),
                divider: const DepositDivider(
                  asset: AppAssets.depositFeatureDivider,
                ),
                onMoreTap: () => context
                    .read<DepositListCubit>()
                    .requestDepositActions(state.visibleDeposits[i]),
              ),
            ],
          ],
        );
      },
    );
  }
}
