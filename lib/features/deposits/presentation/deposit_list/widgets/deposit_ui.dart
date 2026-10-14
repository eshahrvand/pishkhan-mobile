import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../../domain/entities/listed_deposit.dart';

String depositKindLabel(BuildContext context, DepositKind kind) =>
    switch (kind) {
      DepositKind.savings => S.current.depositListSavings,
      DepositKind.current => S.current.depositListCurrent,
    };
String depositStatusLabel(BuildContext context, DepositStatus status) =>
    switch (status) {
      DepositStatus.open => S.current.depositListOpen,
      DepositStatus.closed => S.current.depositListClosed,
      DepositStatus.blocked => S.current.depositListBlocked,
    };

Widget depositIcon(String asset, {double size = 24}) => SizedBox.square(
  dimension: size,
  child: Center(child: SvgPicture.asset(asset)),
);

/// Zero-height layout slot, preserving the original half-pixel divider asset.
class DepositDivider extends StatelessWidget {
  const DepositDivider({
    super.key,
    this.asset = AppAssets.depositFeatureSheetDivider,
  });
  final String asset;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0,
      child: OverflowBox(
        minHeight: .5,
        maxHeight: .5,
        child: SvgPicture.asset(asset, fit: BoxFit.fill),
      ),
    );
  }
}
