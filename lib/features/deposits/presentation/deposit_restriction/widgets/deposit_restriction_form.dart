import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';

import '../../../domain/entities/deposit_restriction.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../../shared/certificate_fields.dart';
import '../cubit/deposit_restriction_cubit.dart';
import 'deposit_block_details.dart';

class DepositRestrictionForm extends StatelessWidget {
  const DepositRestrictionForm({super.key, required this.operation});
  final DepositRestrictionOperation operation;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepositRestrictionCubit, DepositRestrictionState>(
      buildWhen: (previous, current) =>
          previous.catalogStatus != current.catalogStatus ||
          previous.catalog != current.catalog ||
          previous.deposit != current.deposit ||
          previous.reason != current.reason ||
          previous.description != current.description ||
          previous.isEditable != current.isEditable ||
          previous.isWalletSufficient != current.isWalletSufficient,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 76),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                switch (operation) {
                  DepositRestrictionOperation.block =>
                    S.current.depositBlockIntro,
                  DepositRestrictionOperation.unblock =>
                    S.current.depositUnblockIntro,
                },
                style: certificateValueStyle(context).copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppDashboardColors.sectionText,
                ),
              ),
              const SizedBox(height: 20),
              CertificateSelect<DepositRestrictionOption>(
                label: S.current.agentDepositShort,
                hint: S.current.agentDepositHint,
                value: state.deposit,
                enabled: state.isEditable,
                options: [
                  for (final option
                      in state.catalog?.deposits ??
                          <DepositRestrictionOption>[])
                    AppSelectOption(
                      value: option,
                      label: option.deposit.number,
                    ),
                ],
                onChanged: context
                    .read<DepositRestrictionCubit>()
                    .selectDeposit,
              ),
              if (state.deposit?.blockDetails != null) ...[
                const SizedBox(height: 12),
                DepositBlockDetailsCard(details: state.deposit!.blockDetails!),
              ],
              const SizedBox(height: 20),
              if (operation == DepositRestrictionOperation.unblock) ...[
                const DepositDivider(
                  asset: AppAssets.issuanceDivider,
                  thickness: 1,
                ),
                const SizedBox(height: 20),
              ],
              CertificateSelect<DepositRestrictionReason>(
                label: operation == DepositRestrictionOperation.block
                    ? S.current.depositRestrictionReason
                    : S.current.depositUnblockReason,
                hint: S.current.depositRestrictionReasonHint,
                value: state.reason,
                enabled: state.isEditable,
                options: [
                  for (final reason
                      in state.catalog?.reasons ?? <DepositRestrictionReason>[])
                    AppSelectOption(
                      value: reason,
                      label: depositRestrictionReasonLabel(reason),
                    ),
                ],
                onChanged: context.read<DepositRestrictionCubit>().selectReason,
              ),
              const SizedBox(height: 20),
              CertificateInput(
                label: S.current.depositRestrictionDescription,
                hint: S.current.depositRestrictionDescriptionHint,
                value: state.description,
                readOnly: !state.isEditable,
                onChanged: context
                    .read<DepositRestrictionCubit>()
                    .updateDescription,
              ),
              const SizedBox(height: 20),
              const DepositDivider(
                asset: AppAssets.issuanceDivider,
                thickness: 1,
              ),
              const SizedBox(height: 20),
              if (state.catalog != null)
                AppInvoice(
                  totalAmount: CurrencyFormatter.format(state.catalog!.feeRial),
                  walletBalance: CurrencyFormatter.format(
                    state.catalog!.walletBalanceRial,
                  ),
                  lines: const [],
                  isExpanded: false,
                  onExpandedChanged: (_) {},
                  showToggle: false,
                  zeroHeightDividers: true,
                  backgroundColor: context.colors.surface,
                  labelColor: context.colors.textTertiary,
                  isWalletBalanceSufficient: state.isWalletSufficient,
                  title: S.current.issuancePayable,
                  walletLabel: S.current.issuanceWallet,
                  walletSufficientLabel: S.current.issuanceWalletSufficient,
                  walletInsufficientLabel: S.current.issuanceWalletInsufficient,
                ),
              if (state.catalogStatus == RequestStatus.loading)
                const Center(child: CircularProgressIndicator()),
              if (state.catalogStatus == RequestStatus.failure) ...[
                Text(
                  S.current.dashboardLoadError,
                  style: certificateLabelStyle(context)
                      .copyWith(color: context.colors.error),
                ),
                AppButton(
                  label: S.current.dashboardRetry,
                  onPressed: context
                      .read<DepositRestrictionCubit>()
                      .fetchCatalog,
                ),
              ],
              if (state.catalogStatus == RequestStatus.success &&
                  state.catalog!.deposits.isEmpty)
                Text(S.current.depositsEmpty),
            ],
          ),
        );
      },
    );
  }
}
