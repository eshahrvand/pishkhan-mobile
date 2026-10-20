import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';

Future<void> showAppDecisionSheet(
  BuildContext context, {
  required String message,
  required String confirmLabel,
  required VoidCallback onConfirm,
  String? title,
  String? cancelLabel,
}) {
  return showAppServiceSheet<void>(
    context,
    AppDecisionSheet(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onConfirm: onConfirm,
    ),
  );
}

/// Shared content for the confirmation and informational notices.
class AppDecisionSheet extends StatelessWidget {
  const AppDecisionSheet({
    super.key,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.title,
    this.cancelLabel,
  });
  final String? title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback onConfirm;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBottomSheetHeader(
          type: title == null
              ? AppBottomSheetHeaderType.handleOnly
              : AppBottomSheetHeaderType.withHeader,
          title: title ?? '',
          showLeftAction: false,
          showRightIcon: false,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              message,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 20 / 14,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Row(
            children: [
              if (cancelLabel != null) ...[
                Expanded(
                  child: AppButton(
                    label: cancelLabel!,
                    size: AppButtonSize.lg,
                    constrainLabel: true,
                    variant: AppButtonVariant.secondaryGray,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: AppButton(
                  label: confirmLabel,
                  size: AppButtonSize.lg,
                  constrainLabel: true,
                  isDestructive: cancelLabel != null,
                  onPressed: onConfirm,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
