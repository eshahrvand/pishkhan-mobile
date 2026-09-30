import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/notifications/models/notification_message.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.message,
    required this.onTap,
  });
  final NotificationMessage message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: AppRadius.borderLg,
      boxShadow: AppShadows.xs,
    ),
    child: Material(
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderLg,
        side: BorderSide(color: AppPalette.gray200, width: .8),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('notification_${message.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: message.isRead
                      ? AppPalette.gray100
                      : AppPalette.brand50,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    message.isRead
                        ? AppAssets.notificationLogoGray
                        : AppAssets.notificationLogoBlue,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.title,
                            style: AppTypography.bodyMedium.copyWith(
                              color: message.isRead
                                  ? context.colors.textSecondary
                                  : AppPalette.gray800,
                              height: 20 / 14,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          message.dateLabel,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                            height: 16 / 10,
                            letterSpacing: 0,
                            color: AppPalette.gray400,
                          ),
                        ),
                        if (!message.isRead) ...[
                          const SizedBox(width: 8),
                          SvgPicture.asset(
                            AppAssets.notificationUnread,
                            key: Key('notification_unread_${message.id}'),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w300,
                        height: 18 / 12,
                        letterSpacing: 0,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
