import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';

/// One status card, including the actual expansion affordance when applicable.
class LoanStatusCard extends StatelessWidget {
  const LoanStatusCard({
    super.key,
    required this.label,
    required this.approved,
    this.onPressed,
    this.expanded = false,
  });
  final String label;
  final bool approved;
  final VoidCallback? onPressed;
  final bool expanded;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
        decoration: BoxDecoration(
          color: context.colors.surfaceSubtle,
          border: Border.all(color: context.colors.borderSubtle),
          borderRadius: AppRadius.borderSm,
        ),
        child: Row(
          children: [
            AvpImage(
              image: approved
                  ? '${AppConstants.baseImage}loan_request_shield_ok.svg'
                  : '${AppConstants.baseImage}loan_request_shield_error.svg',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 14,
                  height: 20 / 14,
                  letterSpacing: 0,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            if (onPressed != null)
              RotatedBox(
                quarterTurns: expanded ? 0 : 2,
                child: const AvpImage(
                  image: '${AppConstants.baseImage}loan_request_expand.svg',
                  width: 20,
                  height: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
