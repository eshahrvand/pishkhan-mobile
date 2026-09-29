import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

enum AppArrowDirection { left, right }

enum AppArrowButtonSize { compact, large }

/// Circular Figma arrow action used by cards and carousel navigation.
class AppArrowButton extends StatelessWidget {
  const AppArrowButton({
    super.key,
    required this.onPressed,
    this.direction = AppArrowDirection.left,
    this.size = AppArrowButtonSize.large,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final AppArrowDirection direction;
  final AppArrowButtonSize size;
  final String? tooltip;

  double get _diameter => size == AppArrowButtonSize.large ? 48 : 28;
  double get _iconSize => size == AppArrowButtonSize.large ? 24 : 16;

  @override
  Widget build(BuildContext context) {
    final path = direction == AppArrowDirection.left
        ? AppAssets.arrowButtonArrowLeft
        : AppAssets.arrowButtonArrowRight;
    final button = SizedBox.square(
      dimension: _diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: context.colors.surface.withValues(alpha: .8),
          ),
          boxShadow: AppShadows.xs,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: const Key('app_arrow_button'),
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: SizedBox.square(
                dimension: _iconSize,
                child: SvgPicture.asset(path, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: tooltip,
      child: tooltip == null
          ? button
          : Tooltip(message: tooltip!, child: button),
    );
  }
}
