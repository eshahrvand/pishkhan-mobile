import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

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
      child: Center(child: AvpImage(image: asset, width: 20, height: 20)),
    );
    if (onPressed == null) return icon;
    return SizedBox(
      width: 48,
      height: 44,
      child: AppButton(
        onPressed: onPressed,
        icon: AvpImage(image: asset, width: 20, height: 20),
        tooltip: semanticLabel,
        semanticLabel: semanticLabel,
        variant: AppButtonVariant.text,
        size: AppButtonSize.lg,
      ),
    );
  }
}
