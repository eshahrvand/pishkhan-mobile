import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/profile/domain/entities/notification_message.dart';

/// Flutter routing adapter; message data is owned by the dashboard flow.
class DashboardNotificationsNavigation {
  void open(
    BuildContext context, {
    required List<NotificationMessage> messages,
    required ValueChanged<List<NotificationMessage>> onChanged,
  }) {
    context.push<void>(
      AppRoutes.messages,
      extra: MessageCenterRouteArguments(
        messages: messages,
        onChanged: onChanged,
      ),
    );
  }
}
