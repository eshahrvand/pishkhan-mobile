import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/notifications_cubit.dart';
import '../widgets/notifications_list.dart';

import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/notifications/notification_message.dart';
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

  void _handleDetail(BuildContext context, NotificationsState state) {
    context.push<void>(
      AppRoutes.messageDetailLocation(state.detailMessage!.id),
      extra: state.detailMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationsCubit()..openInbox(messages),
      child: BlocListener<NotificationsCubit, NotificationsState>(
        listenWhen: (previous, current) =>
            previous.detailRequestId != current.detailRequestId,
        listener: _handleDetail,
        child: BlocConsumer<NotificationsCubit, NotificationsState>(
          listenWhen: (previous, current) =>
              previous.messages != current.messages,
          listener: (context, state) =>
              onChanged?.call(List.unmodifiable(state.messages)),
          buildWhen: (previous, current) =>
              previous.unreadMessages.isEmpty != current.unreadMessages.isEmpty,
          builder: (context, state) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                backgroundColor: context.colors.surfaceSubtle,
                body: SafeArea(
                  child: Column(
                    children: [
                      NotificationHeader(
                        title: S.current.notificationTitle,
                        action: AppButton(
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
                      Expanded(child: NotificationsList(messages: messages)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
