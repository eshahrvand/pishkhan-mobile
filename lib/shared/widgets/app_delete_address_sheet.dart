import 'app_delete_address_button.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

enum AppDeleteAddressSheetVariant { standard, compact }

/// Delete-address confirmation content from the Figma bottom sheet.
class AppDeleteAddressSheet extends StatelessWidget {
  const AppDeleteAddressSheet({
    super.key,
    required this.address,
    required this.postalCode,
    required this.onConfirm,
    required this.onCancel,
    this.variant = AppDeleteAddressSheetVariant.standard,
    this.title = 'حذف آدرس',
    this.prompt = 'مطمئنید می‌خواید آدرس زیر رو حذف کنید؟',
    this.confirmLabel = 'حذف و ادامه فرآیند',
    this.cancelLabel = 'انصراف',
    this.postalCodeLabel = 'کد پستی',
  });

  final AppDeleteAddressSheetVariant variant;
  final String address;
  final String postalCode;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String title;
  final String prompt;
  final String confirmLabel;
  final String cancelLabel;
  final String postalCodeLabel;

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
              type: variant == AppDeleteAddressSheetVariant.compact
                  ? AppBottomSheetHeaderType.handleOnly
                  : AppBottomSheetHeaderType.withHeader,
              title: title,
              showLeftAction: false,
              showRightIcon: false,
            ),
            Padding(
              padding: variant == AppDeleteAddressSheetVariant.compact
                  ? const EdgeInsets.fromLTRB(20, 20, 20, 32)
                  : const EdgeInsets.fromLTRB(20, 20, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    prompt,
                    textAlign: TextAlign.right,
                    style: bodyStyle.copyWith(
                      fontWeight:
                          variant == AppDeleteAddressSheetVariant.compact
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: variant == AppDeleteAddressSheetVariant.compact
                        ? 12
                        : 10,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: variant == AppDeleteAddressSheetVariant.compact
                          ? EdgeInsets.zero
                          : const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        variant == AppDeleteAddressSheetVariant.compact
                            ? '$address - $postalCodeLabel: $postalCode'
                            : '$address\n\n$postalCodeLabel: $postalCode',
                        textAlign: TextAlign.right,
                        style: variant == AppDeleteAddressSheetVariant.compact
                            ? bodyStyle.copyWith(
                                color: context.colors.textSecondary,
                              )
                            : bodyStyle,
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
                    child: AppDeleteAddressButton(
                      key: const Key('app_delete_address_confirm'),
                      onPressed: onConfirm,
                      label: confirmLabel,
                      destructive: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppDeleteAddressButton(
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
