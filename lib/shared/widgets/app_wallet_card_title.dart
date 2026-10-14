import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';


class AppWalletCardTitle extends StatelessWidget {
  const AppWalletCardTitle({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
      style: AppTypography.bodySmall.copyWith(
        color: context.colors.textPrimary,
        height: 18 / 12,
        letterSpacing: 0,
      ),
    );
  }
}
