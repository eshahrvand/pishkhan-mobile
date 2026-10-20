import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/surplus_deposit_closure.dart';

Future<void> showSurplusDepositReceiptDialog(
  BuildContext context,
  SurplusDepositClosureReceipt receipt,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => SurplusDepositReceiptDialog(receipt: receipt),
  );
}

class SurplusDepositReceiptDialog extends StatelessWidget {
  const SurplusDepositReceiptDialog({super.key, required this.receipt});
  final SurplusDepositClosureReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        '${receipt.isMock ? S.current.surplusDepositsMockComplete : S.current.issuanceComplete}\n${receipt.reference}',
      ),
      actions: [
        AppButton(label: S.current.backLabel, onPressed: () => context.pop()),
      ],
    );
  }
}
