import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

Future<bool?> showDashboardResetSheet(BuildContext context) =>
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppDashboardColors.sheetScrim.withValues(alpha: .64),
      builder: (context) => const DashboardResetSheet(),
    );

class DashboardResetSheet extends StatelessWidget {
  const DashboardResetSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          color: context.colors.surfaceSubtle,
          borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBottomSheetHeader(
                  title: S.current.dashboardResetTitle,
                  showRightIcon: false,
                  showLeftAction: false,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Text(
                    S.current.dashboardResetDescription,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 20 / 14,
                      letterSpacing: 0,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      Expanded(
                        child: AppButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          label: S.current.dashboardResetConfirm,
                          size: AppButtonSize.lg,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          label: S.current.dashboardCancel,
                          variant: AppButtonVariant.secondaryGray,
                          size: AppButtonSize.lg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
