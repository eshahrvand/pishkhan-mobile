import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

/// Authored compact label/value surface used by assessment and summaries.
class LoanValueRow extends StatelessWidget {
  const LoanValueRow({
    super.key,
    required this.label,
    this.value = '',
    this.valueContent,
    this.icon,
    this.color,
    this.onInfoPressed,
    this.valueDirection,
    this.valueFontSize = 14,
    this.valueFontWeight = FontWeight.w500,
    this.height,
    this.labelStyle,
    this.valueWidth,
    this.backgroundColor,
    this.bordered = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  });
  final String label;
  final String value;
  final Widget? valueContent;
  final String? icon;
  final Color? color;
  final VoidCallback? onInfoPressed;
  final TextDirection? valueDirection;
  final double valueFontSize;
  final FontWeight valueFontWeight;
  final double? height;
  final TextStyle? labelStyle;
  final double? valueWidth;
  final Color? backgroundColor;
  final bool bordered;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.surface,
        border: bordered
            ? Border.all(color: context.colors.borderSubtle)
            : null,
        borderRadius: AppRadius.borderSm,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            if (icon != null) ...[
              AvpImage(image: icon, width: 18, height: 18),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style:
                          labelStyle ??
                          AppTypography.bodySmall.copyWith(
                            fontSize: 12,
                            height: 1.5,
                            color: context.colors.textSecondary,
                          ),
                    ),
                  ),
                  if (onInfoPressed != null) ...[
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: onInfoPressed,
                      child: const AvpImage(
                        image: '${AppConstants.baseImage}loan_request_info.svg',
                        width: 12,
                        height: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: valueWidth == null ? 8 : 0),
            Flexible(
              flex: valueWidth == null ? 1 : 0,
              child: SizedBox(
                // 315px is the inner width of the 343px reference field.
                width: valueWidth == null
                    ? null
                    : valueWidth! * (constraints.maxWidth / 315).clamp(0, 1),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child:
                      valueContent ??
                      Text(
                        value,
                        textDirection: valueDirection,
                        style: AppTypography.labelMedium.copyWith(
                          fontSize: valueFontSize,
                          fontWeight: valueFontWeight,
                          letterSpacing: 0,
                          color: color ?? context.colors.textPrimary,
                        ),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
