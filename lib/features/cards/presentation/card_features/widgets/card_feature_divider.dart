import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        child: SvgPicture.asset(
          AppAssets.cardFeaturesDivider,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
