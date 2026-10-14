import 'deposit_owner_detail_row.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import '../../../domain/entities/listed_deposit.dart';

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
