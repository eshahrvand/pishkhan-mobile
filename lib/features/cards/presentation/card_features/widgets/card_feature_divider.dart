import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class CardFeatureDivider extends StatelessWidget {
  const CardFeatureDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 0,
      child: OverflowBox(
        minHeight: .5,
        maxHeight: .5,
        alignment: Alignment.center,
        child: AvpImage(image: AppAssets.cardFeaturesDivider, fit: BoxFit.fill),
      ),
    );
  }
}
