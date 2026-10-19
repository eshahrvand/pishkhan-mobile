import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/cheque_book.dart';

Future<void> showChequeBookReceiptDialog(
  BuildContext context,
  ChequeBookReceipt receipt,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => ChequeBookReceiptDialog(receipt: receipt),
  );
}

class ChequeBookReceiptDialog extends StatelessWidget {
  const ChequeBookReceiptDialog({super.key, required this.receipt});
  final ChequeBookReceipt receipt;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        '${receipt.isMock ? S.current.chequeBookMockComplete : S.current.chequeRequestComplete}\n${receipt.reference}',
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
