import 'wallet_amount_input_formatter.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

class WalletAmountField extends StatelessWidget {
  const WalletAmountField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.amountToman,
    this.isError = false,
    this.enabled = true,
  });
  final String label, value;
  final ValueChanged<String> onChanged;
  final num? amountToman;
  final bool isError, enabled;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: certificateLabelStyle(context)),
        const SizedBox(height: 8),
        AppTextField(
          value: value,
          hintText: S.current.walletAmountHint,
          enabled: enabled,
          normalizeDigits: true,
          keyboardType: TextInputType.number,
          maxLength: 19,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9,٬]')),
            WalletAmountInputFormatter(),
          ],
          textStyle: certificateValueStyle(context),
          onChanged: onChanged,
          errorText: isError ? S.current.walletAmountInvalid : null,
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              widthFactor: 1,
              child: Text(
                S.current.rialCurrency,
                style: certificateValueStyle(context),
              ),
            ),
          ),
        ),
        if (amountToman != null && !isError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const AvpImage(
                  image: '${AppConstants.baseImage}card_deposit_info.svg',
                  width: 14,
                  height: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  S.current.walletTomanAmount(
                    CurrencyFormatter.format(amountToman!),
                  ),
                  style: certificateLabelStyle(context),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
