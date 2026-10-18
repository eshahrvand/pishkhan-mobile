import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/representative_request.dart';

Future<void> showRepresentativeReceiptDialog(
  BuildContext context,
  RepresentativeReceipt receipt,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => RepresentativeReceiptDialog(receipt: receipt),
  );
}

class RepresentativeReceiptDialog extends StatelessWidget {
  const RepresentativeReceiptDialog({super.key, required this.receipt});
  final RepresentativeReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        '${receipt.isMock ? S.current.representativeMockComplete : S.current.issuanceComplete}\n${receipt.reference}',
      ),
      actions: [
        AppButton(label: S.current.backLabel, onPressed: () => context.pop()),
      ],
    );
  }
}
