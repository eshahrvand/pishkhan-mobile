import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_agent_card_detail_row.dart';

import '../../../domain/entities/deposit_restriction.dart';
import '../../deposit_list/widgets/deposit_ui.dart';

class DepositBlockDetailsCard extends StatelessWidget {
  const DepositBlockDetailsCard({super.key, required this.details});
  final DepositBlockDetails details;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: AppRadius.borderSm,
      ),
      child: Column(
        children: [
          AppAgentCardDetailRow(
            row: (
              label: S.current.depositBlockedReason,
              value: depositRestrictionReasonLabel(details.reason),
            ),
            labelColor: context.colors.textSecondary,
          ),
          const SizedBox(height: 12),
          const DepositDivider(asset: AppAssets.depositBlockDetailsDivider),
          const SizedBox(height: 12),
          AppAgentCardDetailRow(
            row: (
              label: S.current.depositBlockedDate,
              value: JalaliDateFormatter.format(details.blockedAt),
            ),
            labelColor: context.colors.textSecondary,
          ),
          const SizedBox(height: 12),
          const DepositDivider(asset: AppAssets.depositBlockDetailsDivider),
          const SizedBox(height: 12),
          AppAgentCardDetailRow(
            row: (
              label: S.current.depositRestrictionDescription,
              value: details.description,
            ),
            labelColor: context.colors.textSecondary,
          ),
        ],
      ),
    );
  }
}

String depositRestrictionReasonLabel(DepositRestrictionReason reason) =>
    switch (reason) {
      DepositRestrictionReason.depositManagement =>
        S.current.depositRestrictionManagement,
    };
