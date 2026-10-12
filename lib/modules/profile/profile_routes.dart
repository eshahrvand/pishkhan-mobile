import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

import 'domain/entities/notification_message.dart';
import 'presentation/features/message_center/screens/notifications_screen.dart';
import 'presentation/features/message_center/screens/notification_detail_screen.dart';

class MessageCenterRouteArguments {
  const MessageCenterRouteArguments({required this.messages, this.onChanged});
  final List<NotificationMessage> messages;
  final ValueChanged<List<NotificationMessage>>? onChanged;
}

List<RouteBase> buildProfileRoutes() => [
  GoRoute(
    path: ProfileRoutes.messages,
    builder: (context, state) {
      final args = state.extra is MessageCenterRouteArguments
          ? state.extra as MessageCenterRouteArguments
          : null;
      return NotificationsScreen(
        messages: args?.messages ?? NotificationMessage.examples(context.l10n),
        onChanged: args?.onChanged,
      );
    },
  ),
  GoRoute(
    path: ProfileRoutes.messageDetail,
    builder: (context, state) {
      final message = state.extra is NotificationMessage
          ? state.extra as NotificationMessage
          : NotificationMessage.examples(context.l10n)
                .where((m) => m.id == state.pathParameters['messageId'])
                .firstOrNull;
      return message == null
          ? const NotificationsScreen(messages: [])
          : NotificationDetailScreen(message: message);
    },
  ),
];

String profileMessageDetailLocation(String id) =>
    '${ProfileRoutes.messages}/${Uri.encodeComponent(id)}';
