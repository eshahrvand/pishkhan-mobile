import '../widgets/notification_labels.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/notifications/notification_message.dart';
import 'package:pishkhan_mobile/features/profile/presentation/message_center/widgets/notification_header.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({super.key, required this.message});
  final NotificationMessage message;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = AppTypography.bodySmall.copyWith(
      height: 18 / 12,
      letterSpacing: 0,
      color: context.colors.textTertiary,
    );
    final dateStyle = AppTypography.caption.copyWith(
      height: 16 / 10,
      fontWeight: FontWeight.w300,
      color: AppPalette.gray400,
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.colors.surfaceSubtle,
        body: SafeArea(
          child: Column(
            children: [
              const NotificationHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(S.current.notificationSubject, style: dateStyle),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              getNotificationTitle(message),
                              style: AppTypography.bodyMedium.copyWith(
                                height: 20 / 14,
                                letterSpacing: 0,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(getNotificationDate(message), style: dateStyle),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 0,
                        child: OverflowBox(
                          minHeight: .5,
                          maxHeight: .5,
                          child: AvpImage(
                            image: AppAssets.notificationDivider,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (getNotificationIntro(message) != null) ...[
                        Text(getNotificationIntro(message)!, style: bodyStyle),
                        const SizedBox(height: 8),
                      ],
                      Text(getNotificationSubtitle(message), style: bodyStyle),
                      if (getNotificationAdvice(message) != null)
                        Text(getNotificationAdvice(message)!, style: bodyStyle),
                      for (final bullet in getNotificationBullets(message))
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 18,
                              child: Text(
                                '•',
                                textAlign: TextAlign.center,
                                style: bodyStyle,
                              ),
                            ),
                            Expanded(child: Text(bullet, style: bodyStyle)),
                          ],
                        ),
                      if (getNotificationClosing(message) != null)
                        Text(
                          getNotificationClosing(message)!,
                          style: bodyStyle,
                        ),
                      if (getNotificationImage(message) != null) ...[
                        const SizedBox(height: 32),
                        Container(
                          height: 136,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: AppNotificationColors.illustrationSurface,
                            borderRadius: AppRadius.borderLg,
                          ),
                          child: OverflowBox(
                            minWidth: 234,
                            maxWidth: 234,
                            minHeight: 156,
                            maxHeight: 156,
                            child: AvpImage(
                              image: getNotificationImage(message)!,
                              width: 234,
                              height: 156,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
