import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    child: SvgPicture.asset(path, fit: BoxFit.contain),
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
        padding: const EdgeInsetsDirectional.only(end: 12),
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            Expanded(child: _balancePanel()),
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

  Widget _balancePanel() => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppPalette.white,
      borderRadius: BorderRadius.only(
        topLeft: AppRadius.md,
        bottomLeft: AppRadius.md,
      ),
    ),
    child: Padding(
      padding: EdgeInsetsDirectional.only(start: _isDesktop ? 16 : 20, end: 16),
      child: _isDesktop ? _desktopContent() : _mobileContent(),
    ),
  );

  Widget _amount(BuildContext context) {
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

  Widget _title(BuildContext context) => Text(
    title,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.end,
    style: AppTypography.bodySmall.copyWith(
      color: context.colors.textPrimary,
      height: 18 / 12,
      letterSpacing: 0,
    ),
  );

  Widget _mobileContent() => Builder(
    builder: (context) => Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: _amount(context),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _title(context),
          ),
        ),
      ],
    ),
  );

  Widget _desktopContent() => Builder(
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
              child: Center(child: angleIcon ?? AppWalletCardIcons.angleLeft()),
            ),
            const Spacer(),
            _title(context),
          ],
        ),
        const SizedBox(height: 14),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: _amount(context),
        ),
      ],
    ),
  );
}
