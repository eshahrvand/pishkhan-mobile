import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import 'certificate_summary_row.dart';

/// The shared deposit/operation summary used by request confirmations.
class AppRequestSummary extends StatelessWidget {
  const AppRequestSummary({
    super.key,
    required this.depositNumber,
    required this.operation,
    required this.isExpanded,
    required this.onExpandedChanged,
    this.depositDivider =
        '${AppConstants.baseImage}issuance_summary_divider.svg',
    this.operationDivider =
        '${AppConstants.baseImage}issuance_summary_divider_operation.svg',
    this.chevron = '${AppConstants.baseImage}issuance_summary_chevron.svg',
  });
  final String depositNumber;
  final String operation;
  final bool isExpanded;
  final ValueChanged<bool> onExpandedChanged;
  final String depositDivider;
  final String operationDivider;
  final String chevron;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppCardIssuanceColors.summarySurface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppShadows.cardList,
      ),
      child: Column(
        children: [
          Semantics(
            button: true,
            expanded: isExpanded,
            child: InkWell(
              onTap: () => onExpandedChanged(!isExpanded),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      S.current.issuanceSummary,
                      style: Theme.of(context).textTheme.bodySmall!
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: isExpanded ? 0 : 2,
                    child: SizedBox.square(
                      dimension: 20,
                      child: Center(child: AvpImage(image: chevron)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 16),
            CertificateSummaryRow(
              label: S.current.depositListNumber,
              value: depositNumber,
              asset: depositDivider,
            ),
            const SizedBox(height: 12),
            CertificateSummaryRow(
              label: S.current.issuanceOperation,
              value: operation,
              asset: operationDivider,
            ),
          ],
        ],
      ),
    );
  }
}
