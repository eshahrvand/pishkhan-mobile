import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_address_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_delete_address_sheet.dart';

import '../../domain/entities/certificate_data.dart';
import '../deposit_list/widgets/deposit_ui.dart';
import 'certificate_fields.dart';
import 'certificate_address_sheet.dart';

/// Delivery composition; request state, validation and execution stay in the flow.
class CertificateDeliveryForm extends StatelessWidget {
  const CertificateDeliveryForm({
    super.key,
    required this.addresses,
    required this.address,
    required this.otherRecipient,
    required this.recipientName,
    required this.recipientNationalId,
    required this.includeAgent,
    required this.agentIdentifier,
    required this.onAddress,
    required this.onAddAddress,
    required this.onDeleteAddress,
    required this.onOtherRecipient,
    required this.onRecipient,
    required this.onIncludeAgent,
    required this.onAgent,
  });
  final List<CertificateAddress> addresses;
  final CertificateAddress? address;
  final bool otherRecipient, includeAgent;
  final String recipientName, recipientNationalId, agentIdentifier;
  final ValueChanged<String> onAddress, onAgent;
  final bool Function(CertificateAddress) onAddAddress;
  final VoidCallback onDeleteAddress;
  final ValueChanged<bool> onOtherRecipient, onIncludeAgent;
  final void Function(String, String) onRecipient;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CertificateSelect<String>(
        label: address == null
            ? context.l10n.issuanceAddress
            : context.l10n.issuanceSelectAddress,
        hint: context.l10n.certificateAddressHint,
        value: address?.id,
        options: [
          for (final a in addresses)
            AppSelectOption(value: a.id, label: a.title),
        ],
        onChanged: onAddress,
      ),
      const SizedBox(height: 12),
      if (address == null)
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: IntrinsicWidth(
            child: SizedBox(
              height: 20,
              child: AppButton(
                label: context.l10n.issuanceAddAddress,
                variant: AppButtonVariant.text,
                leadingIcon: depositIcon(AppAssets.certificatePlus, size: 20),
                size: AppButtonSize.sm,
                horizontalPadding: 0,
                labelStyle: certificateValueStyle(context)
                    .copyWith(fontWeight: FontWeight.w500),
                onPressed: () async {
                  final result = await showCertificateAddressSheet(context);
                  if (context.mounted && result != null) onAddAddress(result);
                },
              ),
            ),
          ),
        )
      else
        AppAddressCard(
          variant: AppAddressCardVariant.delivery,
          address: address!.detail,
          postalCode: address!.postalCode,
          deleteIcon: depositIcon(AppAssets.issuanceTrash, size: 20),
          deleteLabel: context.l10n.issuanceDeleteAddress,
          onDeleteTap: () async {
            final confirmed = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (sheetContext) => AppDeleteAddressSheet(
                address: address!.detail,
                postalCode: address!.postalCode,
                title: context.l10n.issuanceDeleteAddress,
                prompt: context.l10n.certificateDeleteAddressPrompt,
                confirmLabel: context.l10n.issuanceDeleteAddress,
                cancelLabel: context.l10n.backLabel,
                onConfirm: () => sheetContext.pop(true),
                onCancel: () => sheetContext.pop(false),
              ),
            );
            if (context.mounted && confirmed == true) onDeleteAddress();
          },
        ),
      const SizedBox(height: 20),
      const DepositDivider(asset: AppAssets.certificateDivider),
      const SizedBox(height: 20),
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
              context.l10n.issuanceOtherRecipient,
              style: certificateValueStyle(context),
            ),
          ),
        ],
      ),
      if (otherRecipient) ...[
        const SizedBox(height: 20),
        Text(
          context.l10n.certificateRecipientNotice,
          style: certificateValueStyle(context)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        CertificateInput(
          label: context.l10n.certificateRecipientName,
          hint: context.l10n.certificateRecipientNameHint,
          value: recipientName,
          onChanged: (value) => onRecipient(value, recipientNationalId),
        ),
        const SizedBox(height: 20),
        CertificateInput(
          label: context.l10n.depositListNationalId,
          hint: context.l10n.certificateRecipientNationalIdHint,
          value: recipientNationalId,
          numeric: true,
          maxLength: 10,
          onChanged: (value) => onRecipient(recipientName, value),
        ),
      ],
      const SizedBox(height: 20),
      const DepositDivider(asset: AppAssets.certificateDivider),
      const SizedBox(height: 20),
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
              context.l10n.issuanceIncludeAgent,
              style: certificateValueStyle(context),
            ),
          ),
        ],
      ),
      if (includeAgent) ...[
        const SizedBox(height: 20),
        Text(
          context.l10n.certificateAgentNotice,
          style: certificateValueStyle(context)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        CertificateInput(
          label: context.l10n.certificateAgentIdentifier,
          hint: context.l10n.certificateOptional,
          value: agentIdentifier,
          numeric: true,
          onChanged: onAgent,
          addonEnd: SizedBox(
            width: 48 * MediaQuery.textScalerOf(context).scale(1),
            child: AppButton(
              label: context.l10n.certificateCheckAgent,
              variant: AppButtonVariant.text,
              size: AppButtonSize.sm,
              horizontalPadding: 4,
              onPressed: agentIdentifier.trim().isEmpty
                  ? null
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.certificateAgentUnavailable),
                      ),
                    ),
            ),
          ),
        ),
      ],
    ],
  );
}
