import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/widgets/app_arrow_button.dart';

enum AppLoanCardSize { single, multi }

/// Figma-aligned loan summary card.
class AppLoanCard extends StatelessWidget {
  const AppLoanCard({
    super.key,
    this.cardName = 'تسهیلات قرض الحسنه عادی (بدون کارمزد)',
    this.loanNumber = '۱۰-۱۲۲-۱۲۳۴۵۶۷-۱',
    this.loanTotal = '۵۰۰٬۰۰۰٬۰۰۰',
    this.installmentAmount = '۵۰٬۰۰۰٬۰۰۰',
    this.installmentsPaid = '۴/۱۰',
    this.nextInstallment = '۱۴۰۴/۰۸/۰۳',
    this.progress = .49,
    this.size = AppLoanCardSize.single,
    this.onArrowPressed,
    this.onCopyLoanNumber,
  }) : assert(progress >= 0 && progress <= 1);

  final String cardName;
  final String loanNumber;
  final String loanTotal;
  final String installmentAmount;
  final String installmentsPaid;
  final String nextInstallment;
  final double progress;
  final AppLoanCardSize size;
  final VoidCallback? onArrowPressed;
  final VoidCallback? onCopyLoanNumber;

  bool get _isSingle => size == AppLoanCardSize.single;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        key: const Key('app_loan_card'),
        width: _isSingle ? 335 : 316,
        height: 236,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: .32),
          border: Border.all(color: context.colors.surface),
          borderRadius: AppRadius.borderLg,
          boxShadow: AppShadows.md,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 54,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    AppArrowButton(
                      onPressed: onArrowPressed,
                      size: AppArrowButtonSize.compact,
                      direction: AppArrowDirection.left,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cardName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: AppTypography.bodySmall.copyWith(
                          color: const Color(0xFF24292E),
                          fontWeight: FontWeight.w600,
                          height: 18 / 12,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: context.colors.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      _loanNumberRow(),
                      const SizedBox(height: 12),
                      _amountRow(value: loanTotal, label: 'مبلغ وام'),
                      const SizedBox(height: 12),
                      _amountRow(
                        value: installmentAmount,
                        label: 'مبلغ هر قسط',
                      ),
                      const SizedBox(height: 12),
                      _divider(),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) => AppProgressIndicator(
                          value: progress,
                          width: constraints.maxWidth,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _footer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loanNumberRow() => SizedBox(
    height: 22,
    child: Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              Flexible(
                child: Text(
                  loanNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: _valueStyle,
                ),
              ),
              const SizedBox(width: 8),
              _copyButton(),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'شماره تسهیلات',
            textAlign: TextAlign.right,
            style: _labelStyle,
          ),
        ),
      ],
    ),
  );

  Widget _amountRow({required String value, required String label}) => SizedBox(
    height: 22,
    child: Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              Text('ریال', style: _labelStyle),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: _valueStyle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, textAlign: TextAlign.right, style: _labelStyle),
        ),
      ],
    ),
  );

  Widget _divider() => SizedBox(
    height: 0,
    width: double.infinity,
    child: OverflowBox(
      minHeight: 1,
      maxHeight: 1,
      child: SvgPicture.asset(
        _isSingle
            ? 'assets/images/loan_card/divider_single.svg'
            : 'assets/images/loan_card/divider_multi.svg',
        fit: BoxFit.fill,
      ),
    ),
  );

  Widget _footer() => SizedBox(
    height: 22,
    child: Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 140,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.ltr,
              children: [
                Text(nextInstallment, style: _mediumStyle),
                const SizedBox(width: 10),
                Text('قسط بعدی', style: _footerLabelStyle),
              ],
            ),
          ),
        ),
        Container(
          width: 1,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            border: Border.all(color: AppPalette.gray100),
          ),
        ),
        SizedBox(
          width: 133,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.ltr,
              children: [
                Text(installmentsPaid, style: _mediumStyle),
                const SizedBox(width: 10),
                Text('اقساط پرداخت شده', style: _footerLabelStyle),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _copyButton() {
    final icon = SizedBox.square(
      dimension: 16,
      child: SvgPicture.asset(
        'assets/images/loan_card/copy.svg',
        fit: BoxFit.contain,
      ),
    );
    return onCopyLoanNumber == null
        ? KeyedSubtree(key: const Key('app_loan_card_copy'), child: icon)
        : InkWell(
            key: const Key('app_loan_card_copy'),
            onTap: onCopyLoanNumber,
            child: icon,
          );
  }

  TextStyle get _valueStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray800,
    fontWeight: FontWeight.w600,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle get _labelStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray700,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle get _mediumStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray700,
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle get _footerLabelStyle => AppTypography.labelSmall.copyWith(
    color: AppPalette.gray700,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 20 / 10,
    letterSpacing: 0,
  );
}
