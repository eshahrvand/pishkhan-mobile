import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

/// Delete-address confirmation content from the Figma bottom sheet.
class AppDeleteAddressSheet extends StatelessWidget {
  const AppDeleteAddressSheet({
    super.key,
    required this.address,
    required this.postalCode,
    required this.onConfirm,
    required this.onCancel,
    this.title = 'حذف آدرس',
    this.prompt = 'مطمئنید می‌خواید آدرس زیر رو حذف کنید؟',
    this.confirmLabel = 'حذف و ادامه فرآیند',
    this.cancelLabel = 'انصراف',
  });

  final String address;
  final String postalCode;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String title;
  final String prompt;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = AppTypography.bodyMedium.copyWith(
      color: context.colors.textPrimary,
      fontSize: 14,
      height: 20 / 14,
      letterSpacing: 0,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        key: const Key('app_delete_address_sheet'),
        width: 375,
        color: context.colors.surfaceSubtle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetHeader(
              title: title,
              showLeftAction: false,
              showRightIcon: false,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    prompt,
                    textAlign: TextAlign.right,
                    style: bodyStyle.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        '$address\n\nکد پستی: $postalCode',
                        textAlign: TextAlign.right,
                        style: bodyStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  Expanded(
                    child: _SheetButton(
                      key: const Key('app_delete_address_confirm'),
                      onPressed: onConfirm,
                      label: confirmLabel,
                      destructive: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetButton(
                      key: const Key('app_delete_address_cancel'),
                      onPressed: onCancel,
                      label: cancelLabel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
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
