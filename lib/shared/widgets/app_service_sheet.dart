import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'app_service_sheet_route.dart';

/// Shared service-sheet layout with a stationary fading backdrop.
Future<T?> showAppServiceSheet<T>(
  BuildContext context,
  Widget panel, {
  Color? scrimColor,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  // The caller may be inside SafeArea, which has removed inherited padding.
  final insets = MediaQueryData.fromView(View.of(context)).viewPadding;
  final navigator = Navigator.of(context);
  return navigator.push<T>(
    AppServiceSheetRoute<T>(
      modalBarrierColor:
          scrimColor ?? AppDashboardColors.sheetScrim.withValues(alpha: .64),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.sizeOf(context).height -
                  insets.top -
                  insets.bottom,
            ),
            child: Material(
              color: context.colors.surfaceSubtle,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(child: panel),
            ),
          ),
        ),
      ),
    ),
  );
}
