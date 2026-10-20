import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/deposit_restriction.dart';

Future<void> showDepositRestrictionReceiptDialog(
  BuildContext context,
  DepositRestrictionReceipt receipt,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => DepositRestrictionReceiptDialog(receipt: receipt),
  );
}

class DepositRestrictionReceiptDialog extends StatelessWidget {
  const DepositRestrictionReceiptDialog({super.key, required this.receipt});
  final DepositRestrictionReceipt receipt;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        '${receipt.isMock ? S.current.depositRestrictionMockComplete : S.current.issuanceComplete}\n${receipt.reference}',
      ),
      actions: [
        AppButton(label: S.current.backLabel, onPressed: () => context.pop()),
      ],
    );
  }
}
