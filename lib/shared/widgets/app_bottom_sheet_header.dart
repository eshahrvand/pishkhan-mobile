import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppBottomSheetHeaderType { withHeader, handleOnly }

/// Standard Figma bottom-sheet drag handle and optional title row.
class AppBottomSheetHeader extends StatelessWidget {
  const AppBottomSheetHeader({
    super.key,
    this.type = AppBottomSheetHeaderType.withHeader,
    this.title = 'انتخاب کیف پول',
    this.showTitle = true,
    this.showLeftAction = true,
    this.showRightIcon = true,
    this.showTextAction = false,
    this.textActionLabel = 'انصراف',
    this.leftIcon,
    this.rightIcon,
    this.onLeftAction,
  });

  final AppBottomSheetHeaderType type;
  final String title;
  final bool showTitle;
  final bool showLeftAction;
  final bool showRightIcon;
  final bool showTextAction;
  final String textActionLabel;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final VoidCallback? onLeftAction;

  bool get _hasHeader => type == AppBottomSheetHeaderType.withHeader;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        key: const Key('app_bottom_sheet_header'),
        width: double.infinity,
        height: _hasHeader ? 56 : 32,
        padding: EdgeInsets.fromLTRB(20, 10, 20, _hasHeader ? 16 : 20),
        decoration: BoxDecoration(
          color: context.colors.surfaceSubtle,
          borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
        ),
        foregroundDecoration: BoxDecoration(
          border: _hasHeader
              ? Border(
                  bottom: BorderSide(color: context.colors.border, width: .5),
                )
              : null,
        ),
        child: Column(
          children: [
            Container(
              key: const Key('app_bottom_sheet_handle'),
              width: _hasHeader ? 31 : 33,
              height: 2,
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: AppRadius.borderFull,
              ),
            ),
            if (_hasHeader) ...[
              const SizedBox(height: 8),
              SizedBox(height: 20, child: _titleRow(context)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _titleRow(BuildContext context) => Row(
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
                    color: context.colors.primary,
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
                      SvgPicture.asset(
                        'assets/images/bottom_sheet_header/close.svg',
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
                    SvgPicture.asset(
                      'assets/images/bottom_sheet_header/wallet.svg',
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
