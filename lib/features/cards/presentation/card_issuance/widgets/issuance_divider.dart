import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class IssuanceDivider extends StatelessWidget {
  const IssuanceDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0,
      width: double.infinity,
      child: OverflowBox(
        minHeight: 1,
        maxHeight: 1,
        child: AvpImage(image: AppAssets.issuanceDivider, fit: BoxFit.fill),
      ),
    );
  }
}
