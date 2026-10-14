import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/notification_message.dart';
import 'notification_card.dart';

class NotificationGroup extends StatelessWidget {
  const NotificationGroup({
    super.key,
    required this.title,
    required this.messages,
    required this.onOpen,
  });
  final String title;
  final List<NotificationMessage> messages;
  final ValueChanged<NotificationMessage> onOpen;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTypography.bodySmall.copyWith(
            height: 18 / 12,
            letterSpacing: 0,
            color: context.colors.textTertiary,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < messages.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          NotificationCard(
            message: messages[i],
            onTap: () => onOpen(messages[i]),
          ),
        ],
      ],
    );
  }
}
