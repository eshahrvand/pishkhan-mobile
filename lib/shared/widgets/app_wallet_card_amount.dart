import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class AppWalletCardAmount extends StatelessWidget {
  const AppWalletCardAmount({
    super.key,
    required this.balance,
    required this.currencyLabel,
  });
  final String balance;
  final String currencyLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: [
        Text(
          currencyLabel,
          style: AppTypography.bodyMedium.copyWith(
            color: colors.textTertiary,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          balance,
          style: AppTypography.bodyMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
