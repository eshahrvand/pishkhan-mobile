import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../domain/entities/certificate_data.dart';

Future<void> showCertificateReceiptDialog(
  BuildContext context,
  CertificateReceipt receipt,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => CertificateReceiptDialog(receipt: receipt),
  );
}

class CertificateReceiptDialog extends StatelessWidget {
  const CertificateReceiptDialog({super.key, required this.receipt});
  final CertificateReceipt receipt;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        '${receipt.isMock ? S.current.certificateMockComplete : S.current.issuanceComplete}\n${receipt.reference}',
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
