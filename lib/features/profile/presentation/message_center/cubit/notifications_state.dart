part of 'notifications_cubit.dart';

@Freezed(toStringOverride: false)
abstract class NotificationsState with _$NotificationsState {
  const factory NotificationsState.initial({
    NotificationMessage? detailMessage,
    @Default(0) int detailRequestId,
    @Default(<NotificationMessage>[]) List<NotificationMessage> messages,
    @Default(<NotificationMessage>[]) List<NotificationMessage> unreadMessages,
    @Default(<NotificationMessage>[]) List<NotificationMessage> readMessages,
  }) = _NotificationsState;
}
