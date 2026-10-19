import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../../../domain/entities/cheque_cancellation.dart';

/// The identity rows shared by selection cards, reason cards and review sheets.
class ChequeCancellationDetails extends StatelessWidget {
  const ChequeCancellationDetails({
    super.key,
    required this.cheque,
    this.reasonLayout = false,
    this.reviewLayout = false,
  });
  final CancellableCheque cheque;
  final bool reasonLayout;
  final bool reviewLayout;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              S.current.chequeCancelNumber,
              style: certificateLabelStyle(context)
                  .copyWith(fontWeight: FontWeight.w400),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                CurrencyFormatter.toPersianDigits(cheque.number),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                style: certificateLabelStyle(context).copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AvpImage(
          image: cancellationDetailsDivider(reasonLayout, reviewLayout),
          height: .5,
          fit: BoxFit.fill,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              S.current.chequeCancelSayad,
              style: certificateLabelStyle(context)
                  .copyWith(fontWeight: FontWeight.w400),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                CurrencyFormatter.toPersianDigits(cheque.sayadId),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                style: certificateLabelStyle(context).copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String cancellationDetailsDivider(bool reasonLayout, bool reviewLayout) {
  if (reasonLayout) return AppAssets.chequeCancelReasonRowDivider;
  if (reviewLayout) return AppAssets.chequeCancelReviewDivider;
  return AppAssets.chequeCancelDivider;
}
