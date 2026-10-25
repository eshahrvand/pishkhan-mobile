import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class AppAssistantButton extends StatelessWidget {
  const AppAssistantButton({super.key, required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: S.current.dashboardAssistant,
      child: Material(
        color: AppDashboardColors.assistantAccent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: const SizedBox.square(
            dimension: 44,
            child: Center(child: AppAssistantIcon(floating: true)),
          ),
        ),
      ),
    );
  }
}

class AppAssistantIcon extends StatelessWidget {
  const AppAssistantIcon({super.key, this.floating = false});
  final bool floating;
  @override
  Widget build(BuildContext context) {
    final size = floating ? 24.0 : 32.0;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          Positioned(
            left: size * (floating ? .534 : .5079),
            top: size * (floating ? .125 : .099),
            right: size * (floating ? .1175 : .0915),
            bottom: size * (floating ? .5265 : .5005),
            child: AvpImage(
              image: floating
                  ? '${AppConstants.baseImage}dashboard_fab_star.svg'
                  : '${AppConstants.baseImage}dashboard_assistant_star.svg',
            ),
          ),
          Positioned(
            left: size * (floating ? .1175 : .0915),
            top: size * (floating ? .3035 : .2774),
            right: size * (floating ? .296 : .27),
            bottom: size * (floating ? .1101 : .084),
            child: AvpImage(
              image: floating
                  ? '${AppConstants.baseImage}dashboard_fab_spark.svg'
                  : '${AppConstants.baseImage}dashboard_assistant_spark.svg',
            ),
          ),
        ],
      ),
    );
  }
}
