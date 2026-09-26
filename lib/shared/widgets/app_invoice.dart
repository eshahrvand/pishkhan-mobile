import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Local Figma SVG assets used by [AppInvoice].
abstract final class AppInvoiceIcons {
  static const _basePath = 'assets/images/invoice/';

  static Widget cost() => _svg('cost.svg');
  static Widget wallet() => _svg('wallet.svg');
  static Widget currency() => _svg('currency.svg', size: 18);
  static Widget currencyPrimary() => _svg('currency_primary.svg', size: 18);
  static Widget chevronDown() => _svg('chevron_down.svg');
  static Widget chevronUp() => _svg('chevron_up.svg');
  static Widget print() => _svg('print.svg');
  static Widget identityVideo() => _svg('identity_video.svg');
  static Widget delivery() => _svg('delivery.svg');
  static Widget divider() => SizedBox(
    height: .5,
    width: double.infinity,
    child: SvgPicture.asset('${_basePath}divider.svg', fit: BoxFit.fill),
  );

  static Widget _svg(String name, {double size = 20}) => SizedBox(
    width: size,
    height: size,
    child: SvgPicture.asset('$_basePath$name', fit: BoxFit.contain),
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: showToggle ? () => onExpandedChanged(!isExpanded) : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: BorderRadius.circular(16),
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
                  ),
                  const SizedBox(height: 12),
                  AppInvoiceIcons.divider(),
                  const SizedBox(height: 12),
                  if (isExpanded && lines.isNotEmpty) ...[
                    _InvoiceLine(line: lines.first),
                    for (final line in lines.skip(1)) ...[
                      const SizedBox(height: 8),
                      _InvoiceLine(line: line),
                    ],
                    const SizedBox(height: 12),
                    AppInvoiceIcons.divider(),
                    const SizedBox(height: 12),
                  ],
                  _WalletRow(
                    label: walletLabel,
                    amount: walletBalance,
                    icon: walletIcon ?? AppInvoiceIcons.wallet(),
                  ),
                  const SizedBox(height: 12),
                  AppWalletBalanceStatus(
                    isSufficient: isWalletBalanceSufficient,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceHeader extends StatelessWidget {
  const _InvoiceHeader({
    required this.title,
    required this.totalAmount,
    required this.costIcon,
    required this.showToggle,
    required this.isExpanded,
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
            style: _amountStyle(colors.primary, FontWeight.w600),
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showToggle)
              isExpanded
                  ? AppInvoiceIcons.chevronUp()
                  : AppInvoiceIcons.chevronDown(),
            if (showToggle) const SizedBox(width: 4),
            Text(
              title,
              textDirection: TextDirection.rtl,
              style: _labelStyle(colors.textSecondary),
            ),
            const SizedBox(width: 4),
            SizedBox(width: 20, height: 20, child: Center(child: costIcon)),
          ],
        ),
      ],
    );
  }
}

class _InvoiceLine extends StatelessWidget {
  const _InvoiceLine({required this.line});
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
            style: _amountStyle(colors.textPrimary, FontWeight.w500),
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
                  style: _labelStyle(colors.textSecondary),
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
  });
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
            style: _amountStyle(colors.textPrimary, FontWeight.w500),
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
                  style: _labelStyle(colors.textSecondary),
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
        style: _amountStyle(
          isSufficient ? colors.success : colors.error,
          FontWeight.w500,
        ).copyWith(height: 22 / 12),
      ),
    );
  }
}

TextStyle _labelStyle(Color color) => TextStyle(
  color: color,
  fontSize: 12,
  fontWeight: FontWeight.w400,
  height: 18 / 12,
);

TextStyle _amountStyle(Color color, FontWeight weight) =>
    TextStyle(color: color, fontSize: 12, fontWeight: weight, height: 18 / 12);
