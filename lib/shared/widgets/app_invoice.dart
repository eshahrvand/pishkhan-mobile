import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// Local Figma SVG assets used by [AppInvoice].
abstract final class AppInvoiceIcons {
  static Widget cost() => _svg(AppAssets.invoiceCost);
  static Widget wallet() => _svg(AppAssets.iconWallet20Gray600);
  // Figma places the 12.8px money-unit glyph inside an 18px layout slot.
  // Keeping those two dimensions separate prevents the glyph from scaling up.
  static Widget currency() => _svg(
    AppAssets.invoiceCurrency,
    size: 18,
    assetSize: const Size(12.7951, 12.7572),
  );
  static Widget currencyPrimary() => _svg(
    AppAssets.invoiceCurrencyPrimary,
    size: 18,
    assetSize: const Size(12.7951, 12.7572),
  );
  static Widget chevronDown() => _svg(AppAssets.invoiceChevronDown);
  static Widget chevronUp() => _svg(AppAssets.invoiceChevronUp);
  static Widget print() => _svg(AppAssets.invoicePrint);
  static Widget identityVideo() => _svg(AppAssets.invoiceIdentityVideo);
  static Widget delivery() => _svg(AppAssets.invoiceDelivery);
  static Widget divider({bool zeroHeight = false}) => SizedBox(
    height: zeroHeight ? 0 : .5,
    width: double.infinity,
    child: OverflowBox(
      minHeight: .5,
      maxHeight: .5,
      child: SvgPicture.asset(AppAssets.invoiceDivider, fit: BoxFit.fill),
    ),
  );

  static Widget _svg(String path, {double size = 20, Size? assetSize}) =>
      SizedBox(
        width: size,
        height: size,
        child: Center(
          child: SizedBox(
            width: assetSize?.width,
            height: assetSize?.height,
            child: SvgPicture.asset(path, fit: BoxFit.contain),
          ),
        ),
      );
}

/// A configurable row in [AppInvoice].
@immutable
class AppInvoiceLine {
  const AppInvoiceLine({
    required this.id,
    required this.label,
    required this.amount,
    required this.icon,
  });

  final String id;
  final String label;
  final String amount;
  final Widget icon;
}

/// A Figma-aligned payment-cost summary with expandable fee details.
///
/// The parent owns the state via [isExpanded] and [onExpandedChanged], as well
/// as the list of [lines]. This makes the widget usable for any request flow.
class AppInvoice extends StatelessWidget {
  const AppInvoice({
    super.key,
    required this.totalAmount,
    required this.walletBalance,
    required this.lines,
    required this.isExpanded,
    required this.onExpandedChanged,
    required this.isWalletBalanceSufficient,
    this.title = 'هزینه قابل پرداخت',
    this.walletLabel = 'موجودی کیف پول',
    this.walletIcon,
    this.costIcon,
    this.showToggle = true,
    this.backgroundColor,
    this.labelColor,
    this.walletSufficientLabel,
    this.walletInsufficientLabel,
    this.borderRadius,
    this.zeroHeightDividers = false,
  });

  final String title;
  final String totalAmount;
  final String walletBalance;
  final List<AppInvoiceLine> lines;
  final bool isExpanded;
  final ValueChanged<bool> onExpandedChanged;
  final bool isWalletBalanceSufficient;
  final String walletLabel;
  final Widget? walletIcon;
  final Widget? costIcon;
  final bool showToggle;
  final Color? backgroundColor;
  final Color? labelColor;
  final String? walletSufficientLabel, walletInsufficientLabel;
  final BorderRadius? borderRadius;
  final bool zeroHeightDividers;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final content = Container(
      key: const Key('app_invoice_container'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Figma Gray/50 (#FAFAFA).
        color: backgroundColor ?? colors.surfaceSubtle,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InvoiceHeader(
            title: title,
            totalAmount: totalAmount,
            costIcon: costIcon ?? AppInvoiceIcons.cost(),
            showToggle: showToggle,
            isExpanded: isExpanded,
            labelColor: labelColor ?? colors.textSecondary,
          ),
          const SizedBox(height: 12),
          AppInvoiceIcons.divider(zeroHeight: zeroHeightDividers),
          const SizedBox(height: 12),
          if (isExpanded && lines.isNotEmpty) ...[
            for (var index = 0; index < lines.length; index++) ...[
              if (index > 0) const SizedBox(height: 12),
              _InvoiceLine(
                line: lines[index],
                labelColor: labelColor ?? colors.textSecondary,
              ),
            ],
            const SizedBox(height: 12),
            AppInvoiceIcons.divider(zeroHeight: zeroHeightDividers),
            const SizedBox(height: 12),
          ],
          _WalletRow(
            label: walletLabel,
            amount: walletBalance,
            icon: walletIcon ?? AppInvoiceIcons.wallet(),
            labelColor: labelColor ?? colors.textSecondary,
          ),
          const SizedBox(height: 12),
          AppWalletBalanceStatus(
            isSufficient: isWalletBalanceSufficient,
            sufficientLabel: walletSufficientLabel ?? 'موجودی کیف پول کافی است',
            insufficientLabel:
                walletInsufficientLabel ?? 'موجودی کیف پول کافی نیست',
          ),
        ],
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        type: MaterialType.transparency,
        child: Semantics(
          button: showToggle,
          expanded: showToggle ? isExpanded : null,
          child: InkWell(
            onTap: showToggle ? () => onExpandedChanged(!isExpanded) : null,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceHeader extends StatelessWidget {
  final Color labelColor;
  const _InvoiceHeader({
    required this.title,
    required this.totalAmount,
    required this.costIcon,
    required this.showToggle,
    required this.isExpanded,
    required this.labelColor,
  });

  final String title;
  final String totalAmount;
  final Widget costIcon;
  final bool showToggle;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: _Amount(
            amount: totalAmount,
            style: _invoiceTextStyle(
              AppTypography.bodySmall,
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          // Figma pins the cost icon to the physical right and the angle to
          // the physical left, regardless of the surrounding RTL direction.
          textDirection: TextDirection.ltr,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showToggle)
              KeyedSubtree(
                key: const Key('app_invoice_toggle_icon'),
                child: isExpanded
                    ? AppInvoiceIcons.chevronUp()
                    : AppInvoiceIcons.chevronDown(),
              ),
            if (showToggle) const SizedBox(width: 4),
            Text(
              key: const Key('app_invoice_title'),
              title,
              textDirection: TextDirection.rtl,
              style: _invoiceTextStyle(
                AppTypography.bodySmall,
                color: labelColor,
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              key: const Key('app_invoice_cost_icon'),
              width: 20,
              height: 20,
              child: Center(child: costIcon),
            ),
          ],
        ),
      ],
    );
  }
}

class _InvoiceLine extends StatelessWidget {
  const _InvoiceLine({required this.line, required this.labelColor});
  final Color labelColor;
  final AppInvoiceLine line;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: _Amount(
            amount: line.amount,
            style: _invoiceTextStyle(
              AppTypography.bodySmall,
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            textDirection: TextDirection.ltr,
            children: [
              Flexible(
                child: Text(
                  line.label,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: _invoiceTextStyle(
                    AppTypography.bodySmall,
                    color: labelColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(width: 20, height: 20, child: Center(child: line.icon)),
            ],
          ),
        ),
      ],
    );
  }
}

class _WalletRow extends StatelessWidget {
  const _WalletRow({
    required this.label,
    required this.amount,
    required this.icon,
    required this.labelColor,
  });
  final Color labelColor;
  final String label;
  final String amount;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: _Amount(
            amount: amount,
            style: _invoiceTextStyle(
              AppTypography.bodySmall,
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            textDirection: TextDirection.ltr,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: _invoiceTextStyle(
                    AppTypography.bodySmall,
                    color: labelColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(width: 20, height: 20, child: Center(child: icon)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({
    required this.amount,
    required this.style,
    this.isPrimary = false,
  });
  final String amount;
  final TextStyle style;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        isPrimary
            ? AppInvoiceIcons.currencyPrimary()
            : AppInvoiceIcons.currency(),
        const SizedBox(width: 2),
        Flexible(
          child: Text(amount, overflow: TextOverflow.ellipsis, style: style),
        ),
      ],
    );
  }
}

/// The two Figma wallet-status variants: sufficient (green) and insufficient
/// (red).
class AppWalletBalanceStatus extends StatelessWidget {
  const AppWalletBalanceStatus({
    super.key,
    required this.isSufficient,
    this.sufficientLabel = 'موجودی کیف پول کافی است',
    this.insufficientLabel = 'موجودی کیف پول کافی نیست',
  });

  final bool isSufficient;
  final String sufficientLabel;
  final String insufficientLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      liveRegion: true,
      label: isSufficient ? sufficientLabel : insufficientLabel,
      child: Text(
        isSufficient ? sufficientLabel : insufficientLabel,
        textAlign: TextAlign.center,
        style: _invoiceTextStyle(
          AppTypography.bodySmall,
          color: isSufficient ? colors.success : colors.error,
          fontWeight: FontWeight.w500,
          height: 22 / 12,
        ),
      ),
    );
  }
}

/// Applies the exact Figma 12px/18px invoice rhythm to the design-system
/// typography token. The family, fallbacks, and all other defaults remain
/// owned by `avp_ui`.
TextStyle _invoiceTextStyle(
  TextStyle base, {
  required Color color,
  FontWeight fontWeight = FontWeight.w400,
  double height = 18 / 12,
}) => base.copyWith(
  color: color,
  fontWeight: fontWeight,
  height: height,
  letterSpacing: 0,
);
