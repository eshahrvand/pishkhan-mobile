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
        unreadMessages: _unreadMessages(inbox),
        readMessages: _readMessages(inbox),
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
        unreadMessages: _unreadMessages(messages),
        readMessages: _readMessages(messages),
        detailMessage: readMessage,
      ),
    );
  }

  void consumeMessageDetail() {
    emit(state.copyWith(detailMessage: null));
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

  List<NotificationMessage> _unreadMessages(
    List<NotificationMessage> messages,
  ) {
    return messages.where((message) => !message.isRead).toList();
  }

  List<NotificationMessage> _readMessages(List<NotificationMessage> messages) {
    return messages.where((message) => message.isRead).toList();
  }
}
