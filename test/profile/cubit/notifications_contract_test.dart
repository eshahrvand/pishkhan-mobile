import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pishkhan_mobile/features/profile/domain/entities/notification_message.dart';
import 'package:pishkhan_mobile/features/profile/presentation/message_center/cubit/notifications_cubit.dart';
import 'package:pishkhan_mobile/features/profile/presentation/message_center/widgets/notification_labels.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

void main() {
  test(
    'constructor preserves the snapshot; load and opening own inbox changes',
    () async {
      const initial = NotificationsState.initial(detailRequestId: 8);
      final cubit = NotificationsCubit(
        NotificationMessage.examples(),
        initialState: initial,
      );
      expect(identical(cubit.state, initial), isTrue);
      cubit.load();
      expect(cubit.state.unreadMessages, hasLength(2));
      cubit.openMessage('secured-loan');
      expect(cubit.state.detailMessage!.isRead, isTrue);
      expect(cubit.state.unreadMessages, hasLength(1));
      final request = cubit.state.detailRequestId;
      cubit.openMessage('secured-loan');
      expect(cubit.state.detailRequestId, request + 1);
      cubit.openMessage('unknown');
      expect(cubit.state.detailRequestId, request + 1);
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
}
