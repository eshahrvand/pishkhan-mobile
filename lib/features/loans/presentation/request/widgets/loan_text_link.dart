import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';

/// Compact authored link; the shared button still owns enablement and taps.
class LoanTextLink extends StatelessWidget {
  const LoanTextLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.isActive = true,
    this.showArrow = true,
    this.color,
    this.trailingIcon,
  });
  final String label;
  final VoidCallback onPressed;
  final bool isActive;
  final bool showArrow;
  final Color? color;
  final Widget? trailingIcon;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: IntrinsicWidth(
        child: SizedBox(
          height: 20,
          child: AppButton(
            label: label,
            onPressed: onPressed,
            isActive: isActive,
            horizontalPadding: 0,
            variant: AppButtonVariant.text,
            foregroundColor: color,
            labelStyle: AppTypography.bodySmall.copyWith(
              fontSize: 12,
              letterSpacing: 0,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: color,
            ),
            trailingIcon:
                trailingIcon ??
                (showArrow
                    ? const AvpImage(
                        image:
                            '${AppConstants.baseImage}loan_request_link_arrow.svg',
                        width: 20,
                        height: 20,
                      )
                    : null),
          ),
        ),
      ),
    );
  }
}
