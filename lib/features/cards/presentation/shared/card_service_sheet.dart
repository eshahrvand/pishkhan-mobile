import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// Common mobile sheet surface, authored scrim and constrained scroll area.
Future<T?> showCardServiceSheet<T>(
  BuildContext context,
  WidgetBuilder builder,
) {
  FocusManager.instance.primaryFocus?.unfocus();
  final insets = MediaQuery.viewPaddingOf(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    builder: (sheetContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height,
        child: Stack(
          children: [
            Positioned.fill(
              top: insets.top,
              bottom: insets.bottom,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(sheetContext).pop(),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: AvpImage(
                      image: AppAssets.cardFeaturesScrim,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: insets.bottom,
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
          ],
        ),
      ),
    ),
  );
}
