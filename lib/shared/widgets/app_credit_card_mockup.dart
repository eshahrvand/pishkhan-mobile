import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

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
  });

  final AppCreditCardMockupState state;
  final AppBankingChannel channel;
  final String userName;
  final String walletBalance;
  final String linkedDeposit;
  final VoidCallback? onActivate;
  final VoidCallback? onRefresh;

  bool get _isWallet => state == AppCreditCardMockupState.wallet;

  String get _channelTitle => switch (channel) {
    AppBankingChannel.mobile => 'همراه بانک',
    AppBankingChannel.web => 'اینترنت بانک',
    AppBankingChannel.phone => 'تلفن بانک',
  };

  String get _channelIcon => switch (channel) {
    AppBankingChannel.mobile => AppAssets.bankingChannelCardMobile,
    AppBankingChannel.web => AppAssets.bankingChannelCardGlobe,
    AppBankingChannel.phone => AppAssets.bankingChannelCardPhone,
  };

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      key: const Key('app_credit_card_mockup'),
      width: 343,
      height: 136,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: AppPalette.white),
        borderRadius: AppRadius.borderLg,
        boxShadow: AppShadows.md,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.bankingChannelCardBackground,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: -2,
            top: -1,
            width: 272,
            height: 136,
            child: ColoredBox(
              color: AppPalette.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20, child: _header()),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 1,
                      child: SvgPicture.asset(
                        AppAssets.bankingChannelCardDivider,
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(height: 23),
                    SizedBox(height: 20, child: _footer()),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 286,
            top: 47,
            width: 40,
            height: 40,
            child: SvgPicture.asset(
              _isWallet ? AppAssets.bankingChannelCardWallet : _channelIcon,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _header() {
    if (_isWallet) {
      return Row(
        textDirection: TextDirection.ltr,
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: _amount(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: _refreshAction(),
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
              child: _activationAction(),
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

  Widget _footer() {
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

  Widget _activationAction() => InkWell(
    key: const Key('app_credit_card_mockup_activate'),
    onTap: onActivate,
    borderRadius: AppRadius.borderSm,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: [
        SvgPicture.asset(
          AppAssets.bankingChannelCardAngleLeft,
          width: 20,
          height: 20,
        ),
        const SizedBox(width: 8),
        Text('فعالسازی', style: _mediumStyle(AppPalette.brand600)),
      ],
    ),
  );

  Widget _refreshAction() => InkWell(
    key: const Key('app_credit_card_mockup_refresh'),
    onTap: onRefresh,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppAssets.bankingChannelCardRefresh,
          width: 17,
          height: 17,
        ),
        const SizedBox(width: 8.5),
        Text('موجودی', style: _walletRegularStyle),
      ],
    ),
  );

  Widget _amount() => Row(
    mainAxisSize: MainAxisSize.min,
    textDirection: TextDirection.ltr,
    children: [
      Text('ریال', style: _walletRegularStyle),
      const SizedBox(width: 4.25),
      Text(walletBalance, style: _walletMediumStyle),
    ],
  );

  TextStyle _regularStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle _mediumStyle(Color color) =>
      _regularStyle(color).copyWith(fontWeight: FontWeight.w500);

  TextStyle _demiBoldStyle(Color color) =>
      _regularStyle(color).copyWith(fontWeight: FontWeight.w600);

  TextStyle get _walletRegularStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray800,
    fontSize: 12.752,
    height: 19.128 / 12.752,
    letterSpacing: 0,
  );

  TextStyle get _walletMediumStyle =>
      _walletRegularStyle.copyWith(fontWeight: FontWeight.w500);
}
