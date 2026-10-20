import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_confirmer_details_card.dart';

import '../../../domain/entities/deposit_agent.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../../shared/certificate_summary_row.dart';
import 'agent_labels.dart';

class AgentDetails extends StatelessWidget {
  const AgentDetails({super.key, required this.agent});

  final DepositAgent agent;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: AppBadge(
            label: agentStatusLabel(agent.status),
            color: switch (agent.status) {
              AgentStatus.active => AppBadgeColor.success,
              AgentStatus.waiting => AppBadgeColor.warning,
              AgentStatus.expired => AppBadgeColor.error,
            },
            corner: AppBadgeCorner.rounded,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppRadius.borderLg,
          ),
          child: Column(
            children: [
              CertificateSummaryRow(
                label: S.current.agentSettingsNameLabel,
                value: agent.agentName,
                asset: AppAssets.agentNameDots,
              ),
              const SizedBox(height: 12),
              CertificateSummaryRow(
                label: S.current.agentSettingsNationalIdLabel,
                value: CurrencyFormatter.toPersianDigits(agent.agentNationalId),
                asset: AppAssets.agentNationalIdDots,
              ),
              const SizedBox(height: 12),
              CertificateSummaryRow(
                label: S.current.agentSettingsDepositLabel,
                value: CurrencyFormatter.toPersianDigits(agent.depositNumber),
                asset: AppAssets.agentDepositDots,
              ),
              const SizedBox(height: 12),
              CertificateSummaryRow(
                label: S.current.agentSettingsKindLabel,
                value: agentKindLabel(agent.kind),
                asset: AppAssets.agentKindDots,
              ),
              const SizedBox(height: 12),
              CertificateSummaryRow(
                label: S.current.agentSettingsIntroducedLabel,
                value: JalaliDateFormatter.format(agent.introducedAt),
                asset: AppAssets.agentIntroductionDots,
              ),
              const SizedBox(height: 12),
              CertificateSummaryRow(
                label: S.current.agentSettingsExpiryLabel,
                value: JalaliDateFormatter.format(agent.expiresAt),
                asset: AppAssets.agentExpiryDots,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const DepositDivider(asset: AppAssets.agentDivider),
        const SizedBox(height: 20),
        Text(
          S.current.agentSettingsConfirmers,
          style: Theme.of(context).textTheme.titleSmall!
              .copyWith(fontWeight: FontWeight.w600, height: 20 / 14),
        ),
        const SizedBox(height: 20),
        for (final confirmer in agent.confirmers) ...[
          AppConfirmerDetailsCard(
            bodyColor: AppPalette.gray100,
            detailLabelColor: context.colors.textTertiary,
            name: confirmer.name,
            phoneNumber: CurrencyFormatter.toPersianDigits(
              confirmer.nationalId,
            ),
            role: S.current.agentSettingsIntroducer,
            depositRelation: S.current.agentSettingsDepositRelation,
            sharePercentage: S.current.agentSettingsShare(
              CurrencyFormatter.toPersianDigits(
                confirmer.sharePercentage.toString(),
              ),
            ),
            status: confirmer.isApproved
                ? AppConfirmerStatus.approved
                : AppConfirmerStatus.waiting,
            approvedLabel: S.current.agentSettingsWaiting,
            waitingLabel: S.current.agentSettingsWaiting,
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}
