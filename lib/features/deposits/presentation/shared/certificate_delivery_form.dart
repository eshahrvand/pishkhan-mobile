import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CertificateSelect<String>(
          label: address == null
              ? S.current.issuanceAddress
              : S.current.issuanceSelectAddress,
          hint: S.current.certificateAddressHint,
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
                  label: S.current.issuanceAddAddress,
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
            deleteLabel: S.current.issuanceDeleteAddress,
            onDeleteTap: () async {
              final confirmed = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (sheetContext) => AppDeleteAddressSheet(
                  address: address!.detail,
                  postalCode: address!.postalCode,
                  title: S.current.issuanceDeleteAddress,
                  prompt: S.current.certificateDeleteAddressPrompt,
                  confirmLabel: S.current.issuanceDeleteAddress,
                  cancelLabel: S.current.backLabel,
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
            onChanged: (value) => onRecipient(value, recipientNationalId),
          ),
          const SizedBox(height: 20),
          CertificateInput(
            label: S.current.depositListNationalId,
            hint: S.current.certificateRecipientNationalIdHint,
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
                onPressed: agentIdentifier.trim().isEmpty
                    ? null
                    : () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(S.current.certificateAgentUnavailable),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
