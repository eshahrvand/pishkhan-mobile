import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The supplied quick-service artwork includes its wave and icon.
/// Flutter draws its shadow because SVG filter effects are unsupported.
class AppServiceArtworkTile extends StatelessWidget {
  const AppServiceArtworkTile({super.key, required this.asset});
  final String asset;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surfaceSubtle,
      borderRadius: AppRadius.borderMd,
      boxShadow: AppShadows.sm,
    ),
    child: SizedBox.square(
      dimension: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: -3, top: -2, child: SvgPicture.asset(asset)),
        ],
      ),
    ),
  );
}
