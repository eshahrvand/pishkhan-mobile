import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';

class LoanRadioChoice extends StatelessWidget {
  const LoanRadioChoice({
    super.key,
    required this.label,
    required this.selected,
    this.checkMark = false,
    this.onPressed,
  });
  final String label;
  final bool selected;
  final bool checkMark;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      enabled: onPressed != null,
      child: InkWell(
        onTap: selected ? null : onPressed,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected && checkMark)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: AvpImage(
                      image: '${AppConstants.baseImage}loan_request_check.svg',
                      width: 16,
                      height: 16,
                    ),
                  ),
                )
              else if (selected)
                const AvpImage(
                  image:
                      '${AppConstants.baseImage}loan_request_radio_selected.svg',
                  width: 20,
                  height: 20,
                )
              else
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.border),
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: AppPalette.gray700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
