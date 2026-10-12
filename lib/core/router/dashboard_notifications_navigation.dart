import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/modules/profile/profile_routes.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/modules/profile/domain/entities/notification_message.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

/// Router boundary: Dashboard does not import another feature's UI/model.
class DashboardNotificationsNavigation {
  List<NotificationMessage>? _messages;
  void open(BuildContext context) {
    _messages ??= NotificationMessage.examples(context.l10n);
    context.push<void>(
      ProfileRoutes.messages,
      extra: MessageCenterRouteArguments(
        messages: _messages!,
        onChanged: (messages) => _messages = messages,
      ),
    );
  }
}
