import 'package:flutter/material.dart';

import 'app_service_grid_card.dart';

class AppServiceGridItemViewIcon extends StatelessWidget {
  const AppServiceGridItemViewIcon({super.key, required this.item});
  final AppServiceGridItem item;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxWidth: item.iconSize.width,
      maxHeight: item.iconSize.height,
      child: SizedBox(
        width: item.iconSize.width,
        height: item.iconSize.height,
        child: Center(child: item.icon),
      ),
    );
  }
}
