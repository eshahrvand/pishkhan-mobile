import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

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
      child: AvpImage(
        image: '${AppConstants.baseImage}icon_copy_16_white.svg',
        fit: BoxFit.contain,
      ),
    );
    return onTap == null
        ? KeyedSubtree(key: contentKey, child: icon)
        : InkWell(key: contentKey, onTap: onTap, child: icon);
  }
}
