import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/notifications/models/notification_message.dart';
import 'package:pishkhan_mobile/features/notifications/presentation/notification_detail_screen.dart';
import 'package:pishkhan_mobile/features/notifications/presentation/widgets/notification_card.dart';
import 'package:pishkhan_mobile/features/notifications/presentation/widgets/notification_header.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.messages,
    this.onChanged,
  });

  final List<NotificationMessage> messages;
  final ValueChanged<List<NotificationMessage>>? onChanged;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationMessage> _messages = List.of(widget.messages);

  @override
  void didUpdateWidget(covariant NotificationsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages != widget.messages) {
      _messages = List.of(widget.messages);
    }
  }

  void _update(List<NotificationMessage> messages) {
    setState(() => _messages = messages);
    widget.onChanged?.call(List.unmodifiable(messages));
  }

  void _open(NotificationMessage message) {
    if (!message.isRead) {
      _update([
        for (final item in _messages)
          item.id == message.id ? item.markRead() : item,
      ]);
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationDetailScreen(message: message.markRead()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = _messages.where((message) => !message.isRead).toList();
    final read = _messages.where((message) => message.isRead).toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: const Key('notifications_screen'),
        backgroundColor: context.colors.surfaceSubtle,
        body: SafeArea(
          child: Column(
            children: [
              NotificationHeader(
                title: context.l10n.notificationTitle,
                action: AppButton(
                  key: const Key('notification_read_all'),
                  label: context.l10n.notificationReadAll,
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.md,
                  horizontalPadding: 2,
                  leadingIcon: SvgPicture.asset(AppAssets.notificationReadAll),
                  onPressed: unread.isEmpty
                      ? null
                      : () => _update([
                          for (final message in _messages) message.markRead(),
                        ]),
                ),
              ),
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.notificationEmpty,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.colors.textTertiary,
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (unread.isNotEmpty)
                            _group(context.l10n.notificationNew, unread),
                          if (unread.isNotEmpty && read.isNotEmpty)
                            const SizedBox(height: 24),
                          if (read.isNotEmpty)
                            _group(context.l10n.notificationRead, read),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _group(String title, List<NotificationMessage> messages) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        title,
        style: AppTypography.bodySmall.copyWith(
          height: 18 / 12,
          letterSpacing: 0,
          color: context.colors.textTertiary,
        ),
      ),
      const SizedBox(height: 12),
      for (var i = 0; i < messages.length; i++) ...[
        if (i > 0) const SizedBox(height: 8),
        NotificationCard(message: messages[i], onTap: () => _open(messages[i])),
      ],
    ],
  );
}
