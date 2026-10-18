import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/agent_request.dart';

Future<void> showAgentReceiptDialog(
  BuildContext context,
  AgentReceipt receipt,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => AgentReceiptDialog(receipt: receipt),
  );
}

class AgentReceiptDialog extends StatelessWidget {
  const AgentReceiptDialog({super.key, required this.receipt});
  final AgentReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        '${receipt.isMock ? S.current.agentMockComplete : S.current.issuanceComplete}\n${receipt.reference}',
      ),
      actions: [
        AppButton(label: S.current.backLabel, onPressed: () => context.pop()),
      ],
    );
  }
}
