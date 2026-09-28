import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

enum AppCompactStatus { success, warning, error }

/// The compact 20px badge variant used by Figma detail cards.
class AppCompactStatusBadge extends StatelessWidget {
  const AppCompactStatusBadge({
    super.key,
    required this.label,
    required this.status,
  });

  final String label;
  final AppCompactStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      AppCompactStatus.success => (AppPalette.success50, AppPalette.success700),
      AppCompactStatus.warning => (AppPalette.warning50, AppPalette.warning700),
      AppCompactStatus.error => (AppPalette.error50, AppPalette.error700),
    };
    return Semantics(
      label: label,
      child: Container(
        height: 20,
        padding: const EdgeInsetsDirectional.only(start: 6, end: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          maxLines: 1,
          style: AppTypography.labelSmall.copyWith(
            color: foreground,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            height: 16 / 10,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
