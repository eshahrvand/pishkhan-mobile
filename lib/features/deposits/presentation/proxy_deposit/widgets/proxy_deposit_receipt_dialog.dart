import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/proxy_deposit.dart';

Future<void> showProxyDepositReceiptDialog(
  BuildContext context,
  ProxyDepositReceipt receipt,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => ProxyDepositReceiptDialog(receipt: receipt),
  );
}

class ProxyDepositReceiptDialog extends StatelessWidget {
  const ProxyDepositReceiptDialog({super.key, required this.receipt});
  final ProxyDepositReceipt receipt;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        '${receipt.isMock ? S.current.proxyDepositMockComplete : S.current.issuanceComplete}\n${receipt.reference}',
      ),
      actions: [
        AppButton(label: S.current.backLabel, onPressed: () => context.pop()),
      ],
    );
  }
}
