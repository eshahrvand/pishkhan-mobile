import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/on_site_transfer.dart';

Future<void> showTransferReceiptDialog(
  BuildContext context,
  TransferReceipt receipt,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => TransferReceiptDialog(receipt: receipt),
  );
}

class TransferReceiptDialog extends StatelessWidget {
  const TransferReceiptDialog({super.key, required this.receipt});
  final TransferReceipt receipt;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text('${S.current.transferMockComplete}\n${receipt.trackingId}'),
      actions: [
        AppButton(
          label: S.current.backLabel,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
