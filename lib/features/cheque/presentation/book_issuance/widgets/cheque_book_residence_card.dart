import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../../../domain/entities/cheque_book.dart';

/// Registry status is not part of the existing delivery-only address card.
class ChequeBookResidenceCard extends StatelessWidget {
  const ChequeBookResidenceCard({
    super.key,
    required this.residence,
    required this.canDelete,
    required this.onDelete,
  });
  final ChequeBookResidence residence;
  final bool canDelete;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: residence.isRegistered
            ? context.colors.surface
            : AppPalette.error25,
        borderRadius: AppRadius.borderSm,
        border: residence.isRegistered
            ? null
            : Border.all(color: AppPalette.error500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  residence.address.detail,
                  style: certificateLabelStyle(context)
                      .copyWith(fontWeight: FontWeight.w400),
                ),
              ),
              if (canDelete) ...[
                const SizedBox(width: 12),
                Semantics(
                  button: true,
                  label: S.current.issuanceDeleteAddress,
                  child: InkWell(
                    onTap: onDelete,
                    child: const AvpImage(
                      image: '${AppConstants.baseImage}file_upload_trash.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          const AvpImage(
            image: '${AppConstants.baseImage}chequebook_residence_divider.svg',
            height: .5,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${S.current.issuancePostalCode}:',
                style: certificateLabelStyle(context)
                    .copyWith(fontWeight: FontWeight.w400),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  CurrencyFormatter.toPersianDigits(
                    residence.address.postalCode,
                  ),
                  style: certificateLabelStyle(context)
                      .copyWith(fontWeight: FontWeight.w400),
                ),
              ),
              Text(
                residence.isRegistered
                    ? S.current.chequeBookRegistered
                    : S.current.chequeBookNotRegistered,
                style: certificateLabelStyle(context).copyWith(
                  fontWeight: FontWeight.w400,
                  color: residence.isRegistered
                      ? context.colors.success
                      : AppPalette.error500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
