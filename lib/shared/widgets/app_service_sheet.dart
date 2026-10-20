import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// Shared blurred service-sheet layout, including device safe-area insets.
Future<T?> showAppServiceSheet<T>(
  BuildContext context,
  Widget panel, {
  Color? scrimColor,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  // The caller may be inside SafeArea, which has removed inherited padding.
  final insets = MediaQueryData.fromView(View.of(context)).viewPadding;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    enableDrag: false,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: Stack(
          children: [
            Positioned.fill(
              top: insets.top,
              bottom: insets.bottom,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.pop(),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: scrimColor != null
                        ? ColoredBox(color: scrimColor)
                        : AvpImage(
                            image: AppAssets.depositFeatureScrim,
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
          ],
        ),
      ),
    ),
  );
}
