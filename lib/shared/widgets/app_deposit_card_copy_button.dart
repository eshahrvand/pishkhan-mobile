import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class AppDepositCardCopyButton extends StatelessWidget {
  const AppDepositCardCopyButton({
    super.key,
    required this.onTap,
    required this.contentKey,
  });
  final VoidCallback? onTap;
  final Key contentKey;

  @override
  Widget build(BuildContext context) {
    final icon = SizedBox.square(
      dimension: 16,
      child: AvpImage(image: AppAssets.iconCopy16White, fit: BoxFit.contain),
    );
    return onTap == null
        ? KeyedSubtree(key: contentKey, child: icon)
        : InkWell(key: contentKey, onTap: onTap, child: icon);
  }
}
