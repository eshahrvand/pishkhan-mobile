import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../../domain/entities/listed_deposit.dart';
import 'deposit_sheet.dart';
import 'deposit_ui.dart';

Future<void> showDepositAccountDetailsSheet(
  BuildContext context,
  ListedDeposit deposit,
) => showDepositSheet<void>(
  context,
  DepositAccountDetailsSheet(deposit: deposit),
);

class DepositAccountDetailsSheet extends StatelessWidget {
  const DepositAccountDetailsSheet({super.key, required this.deposit});

  final ListedDeposit deposit;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppBottomSheetHeader(
        title: context.l10n.depositListCustomerInformation,
        showLeftAction: false,
        showRightIcon: false,
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (deposit.owners.isEmpty) Text(context.l10n.depositListNoOwners),
            for (var i = 0; i < deposit.owners.length; i++) ...[
              if (i > 0) ...[
                const SizedBox(height: 16),
                const DepositDivider(),
                const SizedBox(height: 16),
              ],
              _DepositOwnerDetails(owner: deposit.owners[i], second: i > 0),
            ],
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: AppButton(
          label: context.l10n.backLabel,
          size: AppButtonSize.lg,
          onPressed: () => context.pop(),
        ),
      ),
    ],
  );
}

class _DepositOwnerDetails extends StatelessWidget {
  const _DepositOwnerDetails({required this.owner, required this.second});

  final DepositOwner owner;
  final bool second;

  @override
  Widget build(BuildContext context) {
    final labels = [
      context.l10n.depositListOwnerName,
      context.l10n.depositListNationalId,
      context.l10n.depositListOwnerRole,
      context.l10n.depositListOwnerPercent,
    ];
    final values = [
      owner.name,
      owner.nationalId,
      switch (owner.role) {
        DepositOwnerRole.ownerAndSignatory =>
          context.l10n.depositListOwnerAndSignatory,
        DepositOwnerRole.owner => context.l10n.depositListOwner,
        DepositOwnerRole.signatory => context.l10n.depositListSignatory,
      },
      '${owner.percent}٪',
    ];
    final dots = [
      AppAssets.depositFeatureNameDots,
      AppAssets.depositFeatureNationalIdDots,
      AppAssets.depositFeatureRoleDots,
      second
          ? AppAssets.depositFeatureSecondPercentDots
          : AppAssets.depositFeaturePercentDots,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < labels.length; i++)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(
                    labels[i],
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      height: 18 / 12,
                      letterSpacing: 0,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SvgPicture.asset(
                      dots[i],
                      height: .5,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: (MediaQuery.sizeOf(context).width - 40) * .6,
                    ),
                    child: Text(
                      values[i],
                      textAlign: TextAlign.end,
                      textDirection: i == 1 || i == 3
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 18 / 12,
                        letterSpacing: 0,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
