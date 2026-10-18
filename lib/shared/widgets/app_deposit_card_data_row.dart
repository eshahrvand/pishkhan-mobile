import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'app_deposit_card_copy_button.dart';

class AppDepositCardDataRow extends StatelessWidget {
  const AppDepositCardDataRow({
    super.key,
    required this.value,
    required this.label,
    required this.onCopy,
    required this.copyKey,
  });
  final String value;
  final String label;
  final VoidCallback? onCopy;
  final Key copyKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: _valueStyle,
                ),
              ),
              const SizedBox(width: 8),
              AppDepositCardCopyButton(onTap: onCopy, contentKey: copyKey),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(label, textDirection: TextDirection.rtl, style: _labelStyle),
      ],
    );
  }

  TextStyle get _valueStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.white,
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    letterSpacing: 0,
  );
  TextStyle get _labelStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.white,
    height: 18 / 12,
    letterSpacing: 0,
  );
}
