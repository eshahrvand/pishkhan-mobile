import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/notifications_cubit.dart';
import '../widgets/notification_group.dart';

import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/features/profile/profile_routes.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/profile/domain/entities/notification_message.dart';
import 'package:pishkhan_mobile/features/profile/presentation/message_center/widgets/notification_header.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    required this.messages,
    this.onChanged,
  });

  final List<NotificationMessage> messages;
  final ValueChanged<List<NotificationMessage>>? onChanged;

  void openMessage(BuildContext context, NotificationMessage message) {
    if (!message.isRead) {
      context.read<NotificationsCubit>().markRead(message.id);
    }
    context.push<void>(
      profileMessageDetailLocation(message.id),
      extra: message.markRead(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // New input messages replace the externally supplied inbox, as before.
      key: ValueKey(messages),
      create: (context) => NotificationsCubit(messages),
      child: BlocConsumer<NotificationsCubit, NotificationsState>(
        listenWhen: (previous, current) =>
            previous.messages != current.messages,
        listener: (context, state) =>
            onChanged?.call(List.unmodifiable(state.messages)),
        buildWhen: (previous, current) => previous.messages != current.messages,
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              key: const Key('notifications_screen'),
              backgroundColor: context.colors.surfaceSubtle,
              body: SafeArea(
                child: Column(
                  children: [
                    NotificationHeader(
                      title: S.current.notificationTitle,
                      action: AppButton(
                        key: const Key('notification_read_all'),
                        label: S.current.notificationReadAll,
                        variant: AppButtonVariant.text,
                        size: AppButtonSize.md,
                        horizontalPadding: 2,
                        leadingIcon: AvpImage(
                          image: AppAssets.notificationReadAll,
                        ),
                        onPressed: state.unreadMessages.isEmpty
                            ? null
                            : () => context
                                  .read<NotificationsCubit>()
                                  .markAllRead(),
                      ),
                    ),
                    Expanded(
                      child: state.messages.isEmpty
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
                                    onOpen: (message) =>
                                        openMessage(context, message),
                                  ),
                                if (state.unreadMessages.isNotEmpty &&
                                    state.readMessages.isNotEmpty)
                                  const SizedBox(height: 24),
                                if (state.readMessages.isNotEmpty)
                                  NotificationGroup(
                                    title: S.current.notificationRead,
                                    messages: state.readMessages,
                                    onOpen: (message) =>
                                        openMessage(context, message),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
