import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class AppTopBarAction extends StatelessWidget {
  const AppTopBarAction({
    required this.asset,
    required this.tooltip,
    required this.onPressed,
    super.key,
    this.dimension = 40,
    this.icon,
  });

  final double dimension;
  final String asset;
  final Widget? icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
      child: AppButton(
        onPressed: onPressed ?? () {},
        variant: AppButtonVariant.text,
        tooltip: tooltip,
        icon: icon ?? SvgPicture.asset(asset, width: 24, height: 24),
      ),
    );
  }
}
