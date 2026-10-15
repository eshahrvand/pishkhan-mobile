import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'package:pishkhan_mobile/features/auth/presentation/shared/auth_assets.dart';

class AuthSectionHeading extends StatelessWidget {
  const AuthSectionHeading({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AvpImage(image: AuthAssets.sectionMark, width: 10, height: 20),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w600,
                  height: 24 / 16,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: context.colors.textTertiary,
            height: 20 / 14,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

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
