import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class AppBottomSheetHeaderTitleRow extends StatelessWidget {
  const AppBottomSheetHeaderTitleRow({
    super.key,
    required this.leftIcon,
    required this.onLeftAction,
    required this.rightIcon,
    required this.showLeftAction,
    required this.showRightIcon,
    required this.showTextAction,
    required this.showTitle,
    required this.textActionColor,
    required this.textActionLabel,
    required this.title,
  });
  final Widget? leftIcon;
  final VoidCallback? onLeftAction;
  final Widget? rightIcon;
  final bool showLeftAction;
  final bool showRightIcon;
  final bool showTextAction;
  final bool showTitle;
  final Color? textActionColor;
  final String textActionLabel;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        if (showLeftAction)
          showTextAction
              ? InkWell(
                  key: const Key('app_bottom_sheet_left_action'),
                  onTap: onLeftAction,
                  child: Text(
                    textActionLabel,
                    style: AppTypography.bodySmall.copyWith(
                      color: textActionColor ?? context.colors.primary,
                      fontWeight: FontWeight.w500,
                      height: 18 / 12,
                      letterSpacing: 0,
                    ),
                  ),
                )
              : InkWell(
                  key: const Key('app_bottom_sheet_left_action'),
                  onTap: onLeftAction,
                  child: SizedBox.square(
                    dimension: 20,
                    child:
                        leftIcon ??
                        AvpImage(
                          image:
                              '${AppConstants.baseImage}icon_close_24_gray700.svg',
                          fit: BoxFit.contain,
                        ),
                  ),
                ),
        if (showLeftAction) const SizedBox(width: 8),
        Expanded(
          child: Row(
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showTitle)
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.titleSmall.copyWith(
                      color: context.colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              if (showRightIcon) ...[
                const SizedBox(width: 8),
                SizedBox.square(
                  dimension: 20,
                  child:
                      rightIcon ??
                      AvpImage(
                        image:
                            '${AppConstants.baseImage}bottom_sheet_header_wallet.svg',
                        fit: BoxFit.contain,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
