import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/deposit_mandate.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../../shared/certificate_fields.dart';

class DepositMandateSubjectDetails extends StatelessWidget {
  const DepositMandateSubjectDetails({
    super.key,
    required this.subject,
    required this.amountToman,
  });
  final DepositMandateSubject subject;
  final num amountToman;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DepositDivider(
          asset: '${AppConstants.baseImage}issuance_divider.svg',
          thickness: 1,
        ),
        const SizedBox(height: 20),
        CertificateInput(
          label: S.current.depositMandateBroker,
          hint: '',
          value: subject.brokerName,
          readOnly: true,
          textStyle: certificateValueStyle(context)
              .copyWith(color: context.colors.textSecondary),
        ),
        const SizedBox(height: 20),
        CertificateInput(
          label: S.current.depositMandateAmount,
          hint: '',
          value: CurrencyFormatter.format(subject.amountRial),
          readOnly: true,
          textStyle: certificateValueStyle(context)
              .copyWith(color: context.colors.textSecondary),
          addonEnd: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              widthFactor: 1,
              child: Text(
                S.current.rialCurrency,
                style: Theme.of(context).textTheme.bodyLarge!
                    .copyWith(color: context.colors.textTertiary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const AvpImage(
              image: '${AppConstants.baseImage}proxy_deposit_info.svg',
              width: 14,
              height: 14,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                S.current.depositMandateAmountToman(
                  NumberFormat.compact(
                    locale: Localizations.localeOf(context).languageCode,
                  ).format(amountToman),
                ),
                style: certificateLabelStyle(context).copyWith(
                  fontWeight: FontWeight.w400,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
