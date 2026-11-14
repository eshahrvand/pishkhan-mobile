import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';

/// Separate currency and number preserve the authored RTL money alignment.
class LoanMoney extends StatelessWidget {
  const LoanMoney({
    super.key,
    required this.amountRial,
    this.color,
    this.highlightUnit = false,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.unitSize = 16,
  });
  final int amountRial;
  final Color? color;
  final bool highlightUnit;
  final double fontSize;
  final FontWeight fontWeight;
  final double unitSize;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: [
        SizedBox(
          width: highlightUnit ? 18 : unitSize,
          height: highlightUnit ? 18 : unitSize,
          child: Center(
            child: AvpImage(
              image: highlightUnit
                  ? '${AppConstants.baseImage}loan_request_currency_blue.svg'
                  : unitSize == 20
                  ? '${AppConstants.baseImage}loan_request_currency_score.svg'
                  : '${AppConstants.baseImage}loan_request_currency_gray.svg',
              width: highlightUnit
                  ? 12.7952
                  : unitSize == 20
                  ? 14.2168
                  : 11.3735,
              height: highlightUnit
                  ? 12.7572
                  : unitSize == 20
                  ? 14.1747
                  : 11.3399,
            ),
          ),
        ),
        SizedBox(width: highlightUnit ? 4 : 2),
        Flexible(
          child: Text(
            CurrencyFormatter.format(amountRial),
            textDirection: TextDirection.ltr,
            maxLines: 1,
            style: AppTypography.labelMedium.copyWith(
              fontSize: fontSize,
              height: (fontSize + 6) / fontSize,
              letterSpacing: 0,
              fontWeight: fontWeight,
              color: color ?? AppPalette.gray800,
            ),
          ),
        ),
      ],
    );
  }
}
