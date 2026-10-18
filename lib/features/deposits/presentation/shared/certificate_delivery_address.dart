import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_address_card.dart';

import '../../domain/entities/certificate_data.dart';
import '../deposit_list/widgets/deposit_ui.dart';
import 'certificate_fields.dart';

class CertificateDeliveryAddress extends StatelessWidget {
  const CertificateDeliveryAddress({
    super.key,
    required this.addresses,
    required this.address,
    required this.onAddress,
    required this.onAddAddress,
    required this.onDeleteAddress,
  });
  final List<CertificateAddress> addresses;
  final CertificateAddress? address;
  final ValueChanged<CertificateAddress> onAddress;
  final VoidCallback onAddAddress;
  final VoidCallback onDeleteAddress;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CertificateSelect<CertificateAddress>(
          label: address == null
              ? S.current.issuanceAddress
              : S.current.issuanceSelectAddress,
          hint: S.current.certificateAddressHint,
          value: address,
          options: [
            for (final a in addresses)
              AppSelectOption(value: a, label: a.title),
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
                  onPressed: onAddAddress,
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
            onDeleteTap: onDeleteAddress,
          ),
      ],
    );
  }
}
