import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import 'app_decision_sheet.dart';
import 'app_service_sheet.dart';

Future<bool?> showFlowExitSheet(BuildContext context, {String? title}) {
  return showAppServiceSheet<bool>(context, FlowExitSheet(title: title));
}

/// Standard decision-sheet presentation with the flow's existing bool result.
class FlowExitSheet extends StatelessWidget {
  const FlowExitSheet({super.key, this.title});
  final String? title;

  @override
  Widget build(BuildContext context) {
    return AppDecisionSheet(
      title: title ?? S.current.flowExitTitle,
      message: S.current.passwordExitBody,
      cancelLabel: S.current.passwordStay,
      confirmLabel: S.current.passwordExit,
      onCancel: () => Navigator.of(context).pop(false),
      onConfirm: () => Navigator.of(context).pop(true),
    );
  }
}
