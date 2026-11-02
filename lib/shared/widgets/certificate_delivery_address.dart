import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_address_card.dart';

import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';

import 'certificate_fields.dart';

class CertificateDeliveryAddress extends StatelessWidget {
  const CertificateDeliveryAddress({
    super.key,
    required this.addresses,
    required this.address,
    required this.onAddress,
    required this.onAddAddress,
    required this.onDeleteAddress,
    this.addressLabel,
    this.addressHint,
    this.trailing,
  });
  final List<DeliveryAddress> addresses;
  final DeliveryAddress? address;
  final ValueChanged<DeliveryAddress> onAddress;
  final VoidCallback onAddAddress;
  final VoidCallback onDeleteAddress;
  final String? addressLabel;
  final String? addressHint;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CertificateSelect<DeliveryAddress>(
          label:
              addressLabel ??
              (address == null
                  ? S.current.issuanceAddress
                  : S.current.issuanceSelectAddress),
          hint: addressHint ?? S.current.certificateAddressHint,
          trailing: trailing,
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
                  leadingIcon: AvpImage(
                    image: '${AppConstants.baseImage}certificate_certPlus.svg',
                    width: 20,
                    height: 20,
                  ),
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
            deleteIcon: AvpImage(
              image: '${AppConstants.baseImage}issuance_trash.svg',
              width: 20,
              height: 20,
            ),
            deleteLabel: S.current.issuanceDeleteAddress,
            onDeleteTap: onDeleteAddress,
          ),
      ],
    );
  }
}
