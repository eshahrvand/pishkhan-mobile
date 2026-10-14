import 'deposit_owner_detail_row.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import '../../../domain/entities/listed_deposit.dart';
import 'deposit_sheet.dart';
import 'deposit_ui.dart';

class DepositOwnerDetails extends StatelessWidget {
  const DepositOwnerDetails({
    super.key,
    required this.owner,
    required this.second,
  });

  final DepositOwner owner;
  final bool second;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DepositOwnerDetailRow(
          label: S.current.depositListOwnerName,
          value: owner.name,
          separatorAsset: AppAssets.depositFeatureNameDots,
        ),
        DepositOwnerDetailRow(
          label: S.current.depositListNationalId,
          value: owner.nationalId,
          separatorAsset: AppAssets.depositFeatureNationalIdDots,
          textDirection: TextDirection.ltr,
        ),
        DepositOwnerDetailRow(
          label: S.current.depositListOwnerRole,
          value: getDepositOwnerRoleTitle(owner.role),
          separatorAsset: AppAssets.depositFeatureRoleDots,
        ),
        DepositOwnerDetailRow(
          label: S.current.depositListOwnerPercent,
          value: '${owner.percent}٪',
          separatorAsset: second
              ? AppAssets.depositFeatureSecondPercentDots
              : AppAssets.depositFeaturePercentDots,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}

String getDepositOwnerRoleTitle(DepositOwnerRole role) {
  switch (role) {
    case DepositOwnerRole.ownerAndSignatory:
      return S.current.depositListOwnerAndSignatory;
    case DepositOwnerRole.owner:
      return S.current.depositListOwner;
    case DepositOwnerRole.signatory:
      return S.current.depositListSignatory;
  }
}
