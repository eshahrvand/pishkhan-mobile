import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/deposit_mandate.dart';

Future<void> showDepositMandateReceiptDialog(
  BuildContext context,
  DepositMandateReceipt receipt,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => DepositMandateReceiptDialog(receipt: receipt),
  );
}

class DepositMandateReceiptDialog extends StatelessWidget {
  const DepositMandateReceiptDialog({super.key, required this.receipt});
  final DepositMandateReceipt receipt;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        '${receipt.isMock ? S.current.depositMandateMockComplete : S.current.issuanceComplete}\n${receipt.reference}',
      ),
      actions: [
        AppButton(label: S.current.backLabel, onPressed: () => context.pop()),
      ],
    );
  }
}
