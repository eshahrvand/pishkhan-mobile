import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthFieldIcon extends StatelessWidget {
  const AuthFieldIcon(
    this.asset, {
    this.onPressed,
    this.semanticLabel,
    super.key,
  });
  final String asset;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final icon = SizedBox(
      width: 48,
      height: 44,
      child: Center(child: SvgPicture.asset(asset, width: 20, height: 20)),
    );
    if (onPressed == null) return icon;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Tooltip(
        message: semanticLabel ?? '',
        child: InkWell(onTap: onPressed, child: icon),
      ),
    );
  }
}
