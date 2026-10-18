import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import 'app_credit_card_mockup.dart';

class AppCreditCardMockupHeader extends StatelessWidget {
  const AppCreditCardMockupHeader({
    super.key,
    required this.channel,
    required this.onActivate,
    required this.onRefresh,
    required this.state,
    required this.walletBalance,
  });
  final AppBankingChannel channel;
  final VoidCallback? onActivate;
  final VoidCallback? onRefresh;
  final AppCreditCardMockupState state;
  final String walletBalance;

  @override
  Widget build(BuildContext context) {
    if (_isWallet) {
      return Row(
        textDirection: TextDirection.ltr,
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.ltr,
                children: [
                  Text('ریال', style: _walletRegularStyle),
                  const SizedBox(width: 4.25),
                  Text(walletBalance, style: _walletMediumStyle),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: InkWell(
                key: const Key('app_credit_card_mockup_refresh'),
                onTap: onRefresh,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AvpImage(
                      image: AppAssets.bankingChannelCardRefresh,
                      width: 17,
                      height: 17,
                    ),
                    const SizedBox(width: 8.5),
                    Text('موجودی', style: _walletRegularStyle),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        if (state == AppCreditCardMockupState.inactive) ...[
          SizedBox(
            width: 91,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: InkWell(
                key: const Key('app_credit_card_mockup_activate'),
                onTap: onActivate,
                borderRadius: AppRadius.borderSm,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.ltr,
                  children: [
                    AvpImage(
                      image: AppAssets.bankingChannelCardAngleLeft,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    Text('فعالسازی', style: _mediumStyle(AppPalette.brand600)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              _channelTitle,
              textAlign: TextAlign.right,
              style: _demiBoldStyle(const Color(0xFF24292E)),
            ),
          ),
        ),
      ],
    );
  }

  String get _channelTitle => switch (channel) {
    AppBankingChannel.mobile => 'همراه بانک',
    AppBankingChannel.web => 'اینترنت بانک',
    AppBankingChannel.phone => 'تلفن بانک',
  };
  TextStyle get _walletRegularStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray800,
    fontSize: 12.752,
    height: 19.128 / 12.752,
    letterSpacing: 0,
  );
  TextStyle _regularStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    height: 18 / 12,
    letterSpacing: 0,
  );
  TextStyle _mediumStyle(Color color) =>
      _regularStyle(color).copyWith(fontWeight: FontWeight.w500);
  bool get _isWallet => state == AppCreditCardMockupState.wallet;
  TextStyle _demiBoldStyle(Color color) =>
      _regularStyle(color).copyWith(fontWeight: FontWeight.w600);
  TextStyle get _walletMediumStyle =>
      _walletRegularStyle.copyWith(fontWeight: FontWeight.w500);
}
