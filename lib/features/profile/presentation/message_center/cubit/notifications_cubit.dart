import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/notification_message.dart';

part 'notifications_state.dart';
part 'notifications_cubit.freezed.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(
    this.initialMessages, {
    NotificationsState initialState = const NotificationsState.initial(),
  }) : super(initialState);
  final List<NotificationMessage> initialMessages;

  void load() {
    replaceInbox(initialMessages);
  }

  void replaceInbox(List<NotificationMessage> inbox) {
    if (isClosed) return;
    emit(
      state.copyWith(
        messages: List.unmodifiable(inbox),
        unreadMessages: inbox.where((message) => !message.isRead).toList(),
        readMessages: inbox.where((message) => message.isRead).toList(),
        detailMessage: null,
      ),
    );
  }

  void openMessage(String id) {
    if (isClosed) return;
    final selected = state.messages
        .where((message) => message.id == id)
        .firstOrNull;
    if (selected == null) return;
    final readMessage = selected.markRead();
    final messages = [
      for (final message in state.messages)
        message.id == id ? readMessage : message,
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

  void markRead(String id) {
    final messages = [
      for (final message in state.messages)
        message.id == id ? message.markRead() : message,
    ];
    emit(
      state.copyWith(
        messages: messages,
        unreadMessages: messages.where((message) => !message.isRead).toList(),
        readMessages: messages.where((message) => message.isRead).toList(),
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
