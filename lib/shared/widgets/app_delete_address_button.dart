import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class AppDeleteAddressButton extends StatelessWidget {
  const AppDeleteAddressButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.destructive = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: destructive ? colors.error : colors.surface,
          border: destructive ? null : Border.all(color: colors.border),
          borderRadius: AppRadius.borderSm,
          boxShadow: AppShadows.xs,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.borderSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: AppTypography.titleSmall.copyWith(
                      color: destructive
                          ? colors.textOnPrimary
                          : colors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
