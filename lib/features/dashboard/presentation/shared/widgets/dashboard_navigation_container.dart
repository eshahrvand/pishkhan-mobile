import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

/// Glass container wrapping the dashboard bottom navigation.
/// The navigation attaches to the top of this container, and the container
/// extends all the way down to the bottom of the screen with a glass decoration.
class DashboardNavigationContainer extends StatelessWidget {
  const DashboardNavigationContainer({
    super.key,
    required this.child,
    this.bottomOffset = 14,
  });

  final Widget child;
  final double bottomOffset;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface.withValues(alpha: 0.70),
            border: Border(
              top: BorderSide(
                color: context.colors.border.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, bottomOffset),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
