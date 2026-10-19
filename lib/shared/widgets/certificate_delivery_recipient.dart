import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import 'certificate_fields.dart';

class CertificateDeliveryRecipient extends StatelessWidget {
  const CertificateDeliveryRecipient({
    super.key,
    required this.otherRecipient,
    required this.recipientName,
    required this.recipientNationalId,
    required this.onOtherRecipient,
    required this.onRecipientName,
    required this.onRecipientNationalId,
    this.nameError,
    this.nationalIdError,
  });
  final String? nameError;
  final String? nationalIdError;
  final bool otherRecipient;
  final String recipientName;
  final String recipientNationalId;
  final ValueChanged<bool> onOtherRecipient;
  final ValueChanged<String> onRecipientName;
  final ValueChanged<String> onRecipientNationalId;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AppToggle(
              value: otherRecipient,
              onChanged: onOtherRecipient,
              size: AppToggleSize.sm,
              appearance: AppToggleAppearance.issuance,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                S.current.issuanceOtherRecipient,
                style: certificateValueStyle(context),
              ),
            ),
          ],
        ),
        if (otherRecipient) ...[
          const SizedBox(height: 20),
          Text(
            S.current.certificateRecipientNotice,
            style: certificateValueStyle(context)
                .copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          CertificateInput(
            label: S.current.certificateRecipientName,
            hint: S.current.certificateRecipientNameHint,
            value: recipientName,
            errorText: nameError,
            onChanged: onRecipientName,
          ),
          const SizedBox(height: 20),
          CertificateInput(
            label: S.current.depositListNationalId,
            hint: S.current.certificateRecipientNationalIdHint,
            value: recipientNationalId,
            errorText: nationalIdError,
            numeric: true,
            maxLength: 10,
            onChanged: onRecipientNationalId,
          ),
        ],
      ],
    );
  }
}
