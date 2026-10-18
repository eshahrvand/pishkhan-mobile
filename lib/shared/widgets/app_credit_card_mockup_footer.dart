import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'app_credit_card_mockup.dart';

class AppCreditCardMockupFooter extends StatelessWidget {
  const AppCreditCardMockupFooter({
    super.key,
    required this.linkedDeposit,
    required this.state,
    required this.userName,
  });
  final String linkedDeposit;
  final AppCreditCardMockupState state;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final inactive = state == AppCreditCardMockupState.inactive;
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: Text(
            _isWallet
                ? linkedDeposit
                : inactive
                ? 'نیاز به فعالسازی'
                : userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
            style: _mediumStyle(
              inactive ? AppPalette.warning600 : AppPalette.gray700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _isWallet ? 'سپرده متصل' : 'نام کاربری',
            textAlign: TextAlign.right,
            style: _regularStyle(AppPalette.gray700),
          ),
        ),
      ],
    );
  }

  TextStyle _regularStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    height: 18 / 12,
    letterSpacing: 0,
  );
  TextStyle _mediumStyle(Color color) =>
      _regularStyle(color).copyWith(fontWeight: FontWeight.w500);
  bool get _isWallet => state == AppCreditCardMockupState.wallet;
}
