import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:pishkhan_mobile/core/notifications/notification_message.dart';

part 'notifications_state.dart';
part 'notifications_cubit.freezed.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    NotificationsState initialState = const NotificationsState.initial(),
  }) : super(initialState);

  void openInbox(List<NotificationMessage> inbox) {
    emit(
      state.copyWith(
        messages: List.unmodifiable(inbox),
        unreadMessages: inbox.where((message) => !message.isRead).toList(),
        readMessages: inbox.where((message) => message.isRead).toList(),
        detailMessage: null,
      ),
    );
  }

  void openMessage(NotificationMessage selected) {
    final readMessage = selected.markRead();
    final messages = [
      for (final message in state.messages)
        message.id == selected.id ? readMessage : message,
    ];
    emit(
      state.copyWith(
        messages: messages,
        unreadMessages: messages.where((message) => !message.isRead).toList(),
        readMessages: messages.where((message) => message.isRead).toList(),
        detailMessage: readMessage,
        detailRequestId: state.detailRequestId + 1,
      ),
    );
  }

  void markAllRead() {
    final messages = [for (final message in state.messages) message.markRead()];
    emit(
      state.copyWith(
        messages: messages,
        unreadMessages: const [],
        readMessages: messages,
      ),
    );
  }
}
