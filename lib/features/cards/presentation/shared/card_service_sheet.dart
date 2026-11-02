import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet_route.dart';

/// Common mobile sheet surface with a stationary backdrop and constrained content.
Future<T?> showCardServiceSheet<T>(
  BuildContext context,
  WidgetBuilder builder, {
  bool enableDrag = true,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  final insets = MediaQuery.viewPaddingOf(context);
  final navigator = Navigator.of(context);
  return navigator.push<T>(
    AppServiceSheetRoute<T>(
      modalBarrierColor: AppDashboardColors.sheetScrim.withValues(alpha: .64),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      enableDrag: enableDrag,
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: Material(
            color: sheetContext.colors.surfaceSubtle,
            borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.sizeOf(sheetContext).height -
                    insets.top -
                    insets.bottom -
                    16,
              ),
              child: builder(sheetContext),
            ),
          ),
        ),
      ),
    ),
  );
}
