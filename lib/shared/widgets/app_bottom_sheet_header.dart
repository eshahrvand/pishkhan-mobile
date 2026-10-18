import 'app_bottom_sheet_header_title_row.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

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
    this.textActionColor,
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
  final Color? textActionColor;

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
              SizedBox(
                height: 20,
                child: AppBottomSheetHeaderTitleRow(
                  leftIcon: leftIcon,
                  onLeftAction: onLeftAction,
                  rightIcon: rightIcon,
                  showLeftAction: showLeftAction,
                  showRightIcon: showRightIcon,
                  showTextAction: showTextAction,
                  showTitle: showTitle,
                  textActionColor: textActionColor,
                  textActionLabel: textActionLabel,
                  title: title,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
