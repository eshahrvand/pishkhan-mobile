import 'package:go_router/go_router.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

Future<bool?> showFlowExitDialog(BuildContext context, {String? title}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => FlowExitDialog(title: title),
  );
}

class FlowExitDialog extends StatelessWidget {
  const FlowExitDialog({super.key, this.title});
  final String? title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? S.current.flowExitTitle),
      content: Text(S.current.passwordExitBody),
      actions: [
        AppButton(
          onPressed: () => context.pop(false),
          label: S.current.passwordStay,
          variant: AppButtonVariant.text,
          constrainLabel: true,
        ),
        AppButton(
          onPressed: () => context.pop(true),
          label: S.current.passwordExit,
          isDestructive: true,
        ),
      ],
    );
  }
}
