import '../../shared/card_service_sheet.dart';

import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/password_data.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_request_status.dart';

Future<void> showPasswordRecord(
  BuildContext context,
  PasswordRequestRecord record, {
  bool newlySubmitted = false,
  PasswordOperation operation = PasswordOperation.setSecondPassword,
}) => passwordSheet<void>(
  context,
  (context) => PasswordRecordSheet(
    record: record,
    newlySubmitted: newlySubmitted,
    operation: operation,
  ),
);

Future<bool?> showPasswordExitDialog(BuildContext context) =>
    showFlowExitDialog(context, title: S.current.passwordExitTitle);

Future<T?> passwordSheet<T>(BuildContext context, WidgetBuilder panel) {
  return showCardServiceSheet<T>(
    context,
    (context) => SingleChildScrollView(child: panel(context)),
    enableDrag: false,
  );
}
