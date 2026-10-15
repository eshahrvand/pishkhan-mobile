import 'app_wallet_card_amount.dart';
import 'app_wallet_card_title.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// Figma WalletCard layouts.
enum AppWalletCardType { mobile, desktop }

/// Local Figma SVG assets used by [AppWalletCard].
abstract final class AppWalletCardIcons {
  static Widget wallet() => _svg(AppAssets.walletCardWallet, size: 32);
  static Widget angleLeft() => _svg(AppAssets.iconAngleLeft20Gray700, size: 20);

  static Widget _svg(String path, {required double size}) => SizedBox(
    width: size,
    height: size,
    child: AvpImage(image: path, fit: BoxFit.contain),
  );
}

/// App-owned, Figma-aligned wallet balance card for mobile and desktop.
class AppWalletCard extends StatelessWidget {
  const AppWalletCard({
    super.key,
    required this.balance,
    this.title = 'موجودی کیف پول',
    this.currencyLabel = 'ریال',
    this.type = AppWalletCardType.mobile,
    this.walletIcon,
    this.angleIcon,
    this.onTap,
  });

  final String title;
  final String balance;
  final String currencyLabel;
  final AppWalletCardType type;
  final Widget? walletIcon;
  final Widget? angleIcon;
  final VoidCallback? onTap;

  bool get _isDesktop => type == AppWalletCardType.desktop;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final content = SizedBox(
      height: _isDesktop ? 88 : 56,
      child: Padding(
        // Figma pins the wallet affordance to the physical right edge.
        padding: const EdgeInsets.only(right: 12),
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppPalette.white,
                  borderRadius: BorderRadius.only(
                    topLeft: AppRadius.md,
                    bottomLeft: AppRadius.md,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: _isDesktop ? 16 : 20,
                    right: 16,
                  ),
                  child: _isDesktop
                      ? Builder(
                          builder: (context) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                textDirection: TextDirection.ltr,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Center(
                                      child:
                                          angleIcon ??
                                          AppWalletCardIcons.angleLeft(),
                                    ),
                                  ),
                                  const Spacer(),
                                  AppWalletCardTitle(title: title),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Align(
                                alignment: Alignment.centerRight,
                                child: AppWalletCardAmount(
                                  balance: balance,
                                  currencyLabel: currencyLabel,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Builder(
                          builder: (context) => Row(
                            textDirection: TextDirection.ltr,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: AppWalletCardAmount(
                                      balance: balance,
                                      currencyLabel: currencyLabel,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: AppWalletCardTitle(title: title),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 32,
              height: 32,
              child: Center(child: walletIcon ?? AppWalletCardIcons.wallet()),
            ),
          ],
        ),
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalette.blueGray50,
          border: Border.all(color: colors.surface.withValues(alpha: .2)),
          borderRadius: AppRadius.borderMd,
          boxShadow: AppShadows.sm,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: onTap == null
              ? content
              : InkWell(
                  onTap: onTap,
                  borderRadius: AppRadius.borderMd,
                  child: content,
                ),
        ),
      ),
    );
  }
}
