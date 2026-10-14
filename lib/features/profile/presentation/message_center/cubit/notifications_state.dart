part of 'notifications_cubit.dart';

@freezed
abstract class NotificationsState with _$NotificationsState {
  const factory NotificationsState.initial({
    @Default(<NotificationMessage>[]) List<NotificationMessage> messages,
    @Default(<NotificationMessage>[]) List<NotificationMessage> unreadMessages,
    @Default(<NotificationMessage>[]) List<NotificationMessage> readMessages,
  }) = _NotificationsState;
}
