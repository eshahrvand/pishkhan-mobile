import 'package:pishkhan_mobile/core/config/constant.dart';

import 'app_credit_card_mockup_header.dart';
import 'app_credit_card_mockup_footer.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

enum AppBankingChannel { mobile, web, phone }

enum AppCreditCardMockupState { inactive, active, wallet }

/// Figma credit-card mockup used for banking channels and the wallet card.
class AppCreditCardMockup extends StatelessWidget {
  const AppCreditCardMockup({
    super.key,
    this.state = AppCreditCardMockupState.inactive,
    this.channel = AppBankingChannel.mobile,
    this.userName = '123456789',
    this.walletBalance = '۶۰۰,۰۰۰',
    this.linkedDeposit = '10.12003456.1',
    this.onActivate,
    this.onRefresh,
    this.isCompact = false,
  });

  final AppCreditCardMockupState state;
  final AppBankingChannel channel;
  final String userName;
  final String walletBalance;
  final String linkedDeposit;
  final VoidCallback? onActivate;
  final VoidCallback? onRefresh;

  /// The active mobile-bank frame uses the existing card in a 104px slot.
  final bool isCompact;

  bool get _isWallet => state == AppCreditCardMockupState.wallet;

  String get _channelIcon => switch (channel) {
    AppBankingChannel.mobile =>
      '${AppConstants.baseImage}banking_channel_card_mobile.svg',
    AppBankingChannel.web =>
      '${AppConstants.baseImage}banking_channel_card_globe.svg',
    AppBankingChannel.phone =>
      '${AppConstants.baseImage}banking_channel_card_phone.svg',
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        key: const Key('app_credit_card_mockup'),
        width: 343,
        height: isCompact ? 104 : 136,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: AppPalette.white),
          borderRadius: AppRadius.borderLg,
          boxShadow: AppShadows.md,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AvpImage(
                image:
                    '${AppConstants.baseImage}banking_channel_card_background.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: -2,
              top: -1,
              width: 272,
              height: isCompact ? 104 : 136,
              child: ColoredBox(
                color: AppPalette.white,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isCompact ? 20 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 20,
                        child: AppCreditCardMockupHeader(
                          channel: channel,
                          onActivate: onActivate,
                          onRefresh: onRefresh,
                          state: state,
                          walletBalance: walletBalance,
                        ),
                      ),
                      SizedBox(height: isCompact ? 12 : 24),
                      SizedBox(
                        height: 1,
                        child: AvpImage(
                          image:
                              '${AppConstants.baseImage}banking_channel_card_divider.svg',
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(height: isCompact ? 11 : 23),
                      SizedBox(
                        height: 20,
                        child: AppCreditCardMockupFooter(
                          linkedDeposit: linkedDeposit,
                          state: state,
                          userName: userName,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 286,
              top: isCompact ? 31 : 47,
              width: 40,
              height: 40,
              child: AvpImage(
                image: _isWallet
                    ? '${AppConstants.baseImage}banking_channel_card_wallet.svg'
                    : _channelIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
