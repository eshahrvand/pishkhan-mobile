import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/notification_message.dart';

part 'notifications_state.dart';
part 'notifications_cubit.freezed.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(List<NotificationMessage> messages)
    : super(
        NotificationsState.initial(
          messages: List.of(messages),
          unreadMessages: messages.where((message) => !message.isRead).toList(),
          readMessages: messages.where((message) => message.isRead).toList(),
        ),
      );

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
