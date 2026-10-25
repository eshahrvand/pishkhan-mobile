import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

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
        child: AvpImage(
          image: '${AppConstants.baseImage}card_features_divider.svg',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
