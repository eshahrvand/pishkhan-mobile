import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

Future<void> showModernBankTerms(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const ModernBankTerms(),
  );
}

class ModernBankTerms extends StatelessWidget {
  const ModernBankTerms({super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.issuanceTerms),
      content: Text(S.current.modernTermsUnavailable),
      actions: [
        AppButton(
          label: S.current.passwordUnderstood,
          onPressed: () {
            context.pop();
          },
        ),
      ],
    );
  }
}
