import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/notification_message.dart';
import '../cubit/notifications_cubit.dart';
import 'notification_group.dart';

/// Owns the inbox subscription and forwards actual externally replaced inboxes.
class NotificationsList extends StatefulWidget {
  const NotificationsList({super.key, required this.messages});
  final List<NotificationMessage> messages;
  @override
  State<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  @override
  void didUpdateWidget(covariant NotificationsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.messages, widget.messages)) {
      context.read<NotificationsCubit>().replaceInbox(widget.messages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      buildWhen: (previous, current) => previous.messages != current.messages,
      builder: (context, state) {
        return state.messages.isEmpty
            ? Center(
                child: Text(
                  S.current.notificationEmpty,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (state.unreadMessages.isNotEmpty)
                    NotificationGroup(
                      title: S.current.notificationNew,
                      messages: state.unreadMessages,
                      onOpen: (message) => context
                          .read<NotificationsCubit>()
                          .openMessage(message.id),
                    ),
                  if (state.unreadMessages.isNotEmpty &&
                      state.readMessages.isNotEmpty)
                    const SizedBox(height: 24),
                  if (state.readMessages.isNotEmpty)
                    NotificationGroup(
                      title: S.current.notificationRead,
                      messages: state.readMessages,
                      onOpen: (message) => context
                          .read<NotificationsCubit>()
                          .openMessage(message.id),
                    ),
                ],
              );
      },
    );
  }
}
