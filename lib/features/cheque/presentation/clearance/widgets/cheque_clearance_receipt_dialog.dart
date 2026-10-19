import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/cheque_clearance.dart';

Future<void> showChequeClearanceReceiptDialog(
  BuildContext context,
  ChequeClearanceReceipt receipt,
) => showDialog<void>(
  context: context,
  builder: (_) => ChequeClearanceReceiptDialog(receipt: receipt),
);

class ChequeClearanceReceiptDialog extends StatelessWidget {
  const ChequeClearanceReceiptDialog({super.key, required this.receipt});
  final ChequeClearanceReceipt receipt;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        '${receipt.isMock ? S.current.chequeMockComplete : S.current.chequeRequestComplete}\n${receipt.reference}',
      ),
      actions: [
        AppButton(
          label: S.current.backLabel,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
