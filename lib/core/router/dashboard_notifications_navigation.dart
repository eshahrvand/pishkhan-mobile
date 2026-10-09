import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/notifications/models/notification_message.dart';
import 'package:pishkhan_mobile/features/notifications/presentation/notifications_screen.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

/// Router boundary: Dashboard does not import another feature's UI/model.
class DashboardNotificationsNavigation {
  List<NotificationMessage>? _messages;
  void open(BuildContext context) {
    _messages ??= NotificationMessage.examples(context.l10n);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationsScreen(
          messages: _messages!,
          onChanged: (messages) => _messages = messages,
        ),
      ),
    );
  }
}
