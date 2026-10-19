import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/cheque_cancellation.dart';

Future<void> showChequeCancellationReceiptDialog(
  BuildContext context,
  ChequeCancellationReceipt receipt,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => ChequeCancellationReceiptDialog(receipt: receipt),
  );
}

class ChequeCancellationReceiptDialog extends StatelessWidget {
  const ChequeCancellationReceiptDialog({super.key, required this.receipt});
  final ChequeCancellationReceipt receipt;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        '${receipt.isMock ? S.current.chequeCancelMockComplete : S.current.chequeRequestComplete}\n${receipt.reference}',
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
