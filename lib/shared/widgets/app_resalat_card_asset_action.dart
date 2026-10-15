import 'package:avp_ui/avp_ui.dart';

import 'package:flutter/material.dart';

class AppResalatCardAssetAction extends StatelessWidget {
  const AppResalatCardAssetAction({
    super.key,
    required this.path,
    required this.size,
    required this.onTap,
    required this.contentKey,
    this.label,
  });
  final String path;
  final double size;
  final VoidCallback? onTap;
  final Key contentKey;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final icon = SizedBox.square(
      dimension: size,
      child: AvpImage(image: path, fit: BoxFit.contain),
    );
    return onTap == null
        ? KeyedSubtree(key: contentKey, child: icon)
        : Semantics(
            button: true,
            label: label,
            child: InkWell(key: contentKey, onTap: onTap, child: icon),
          );
  }
}
