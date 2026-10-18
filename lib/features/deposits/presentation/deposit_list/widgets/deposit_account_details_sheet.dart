import 'deposit_owner_details.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
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
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBottomSheetHeader(
          title: S.current.depositListCustomerInformation,
          showLeftAction: false,
          showRightIcon: false,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (deposit.owners.isEmpty) Text(S.current.depositListNoOwners),
              for (var i = 0; i < deposit.owners.length; i++) ...[
                if (i > 0) ...[
                  const SizedBox(height: 16),
                  const DepositDivider(),
                  const SizedBox(height: 16),
                ],
                DepositOwnerDetails(owner: deposit.owners[i], second: i > 0),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: AppButton(
            label: S.current.backLabel,
            size: AppButtonSize.lg,
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }
}
