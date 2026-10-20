import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import 'certificate_fields.dart';

class CertificateDeliveryAgent extends StatelessWidget {
  const CertificateDeliveryAgent({
    super.key,
    required this.includeAgent,
    required this.agentIdentifier,
    required this.canCheckAgent,
    required this.onIncludeAgent,
    required this.onAgent,
    required this.onAgentLookup,
  });
  final bool includeAgent;
  final String agentIdentifier;
  final bool canCheckAgent;
  final ValueChanged<bool> onIncludeAgent;
  final ValueChanged<String> onAgent;
  final VoidCallback onAgentLookup;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AppToggle(
              value: includeAgent,
              onChanged: onIncludeAgent,
              size: AppToggleSize.sm,
              appearance: AppToggleAppearance.issuance,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                S.current.issuanceIncludeAgent,
                style: certificateValueStyle(context),
              ),
            ),
          ],
        ),
        if (includeAgent) ...[
          const SizedBox(height: 20),
          Text(
            S.current.certificateAgentNotice,
            style: certificateValueStyle(context)
                .copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          CertificateInput(
            label: S.current.certificateAgentIdentifier,
            hint: S.current.certificateOptional,
            value: agentIdentifier,
            numeric: true,
            onChanged: onAgent,
            addonEnd: SizedBox(
              width: 48 * MediaQuery.textScalerOf(context).scale(1),
              child: AppButton(
                label: S.current.certificateCheckAgent,
                variant: AppButtonVariant.text,
                size: AppButtonSize.sm,
                horizontalPadding: 4,
                onPressed: canCheckAgent ? onAgentLookup : null,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
