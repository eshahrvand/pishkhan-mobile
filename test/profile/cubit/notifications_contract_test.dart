import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/core/notifications/notification_message.dart';
import 'package:pishkhan_mobile/features/profile/presentation/message_center/cubit/notifications_cubit.dart';
import 'package:pishkhan_mobile/features/profile/presentation/message_center/widgets/notification_labels.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

void main() {
  test(
    'constructor preserves the snapshot; load and opening own inbox changes',
    () async {
      const initial = NotificationsState.initial();
      final cubit = NotificationsCubit(initialState: initial);
      expect(identical(cubit.state, initial), isTrue);
      cubit.openInbox(NotificationMessage.examples());
      expect(cubit.state.unreadMessages, hasLength(2));
      cubit.openMessage(cubit.state.messages.first);
      expect(cubit.state.detailMessage!.isRead, isTrue);
      expect(cubit.state.unreadMessages, hasLength(1));
      final detail = cubit.state.detailMessage;
      cubit.consumeMessageDetail();
      expect(cubit.state.detailMessage, isNull);
      cubit.openMessage(cubit.state.messages.first);
      expect(cubit.state.detailMessage, detail);
      await cubit.close();
    },
  );

  test(
    'localized sample content keeps stable message and route identities',
    () async {
      await S.load(const Locale('fa'));
      final persian = NotificationMessage.examples();
      final title = getNotificationTitle(persian.first);
      await S.load(const Locale('en'));
      final english = NotificationMessage.examples();
      expect(
        english.map((message) => message.id),
        persian.map((message) => message.id),
      );
      expect(getNotificationTitle(english.first), isNot(title));
      expect(english.last.id, 'security-sample-date');
    },
  );
  test('notification values are equal and snapshot incoming bullet lists', () {
    final bullets = ['First'];
    final message = NotificationMessage(
      id: 'one',
      title: 'Title',
      subtitle: 'Body',
      dateLabel: '',
      bullets: bullets,
    );
    final equal = NotificationMessage(
      id: 'one',
      title: 'Title',
      subtitle: 'Body',
      dateLabel: '',
      bullets: ['First'],
    );
    expect(message, equal);
    bullets.add('Changed outside State');
    expect(message.bullets, ['First']);
    expect(
      () => message.bullets.add('Changed inside State'),
      throwsUnsupportedError,
    );
    expect(message.markRead(), isNot(message));
    expect(message.markRead().markRead(), message.markRead());
  });
}
