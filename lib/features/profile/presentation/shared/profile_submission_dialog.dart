import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

/// Shared presentation of the existing phone/job information submission acknowledgement.
class ProfileSubmissionDialog extends StatelessWidget {
  const ProfileSubmissionDialog({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(message),
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
