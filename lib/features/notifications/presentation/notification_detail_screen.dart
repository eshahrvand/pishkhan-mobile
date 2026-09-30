import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/notifications/models/notification_message.dart';
import 'package:pishkhan_mobile/features/notifications/presentation/widgets/notification_header.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
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
    final dateStyle = bodyStyle.copyWith(
      fontSize: 10,
      height: 16 / 10,
      fontWeight: FontWeight.w300,
      color: AppPalette.gray400,
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: const Key('notification_detail_screen'),
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
                      Text(context.l10n.notificationSubject, style: dateStyle),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message.title,
                              style: AppTypography.bodyMedium.copyWith(
                                height: 20 / 14,
                                letterSpacing: 0,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(message.dateLabel, style: dateStyle),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 0,
                        child: OverflowBox(
                          minHeight: .5,
                          maxHeight: .5,
                          child: SvgPicture.asset(
                            AppAssets.notificationDivider,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (message.intro != null) ...[
                        Text(message.intro!, style: bodyStyle),
                        const SizedBox(height: 8),
                      ],
                      Text(message.subtitle, style: bodyStyle),
                      if (message.advice != null)
                        Text(message.advice!, style: bodyStyle),
                      for (final bullet in message.bullets)
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
                      if (message.closing != null)
                        Text(message.closing!, style: bodyStyle),
                      if (message.imageAsset != null) ...[
                        const SizedBox(height: 32),
                        Container(
                          height: 136,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: const Color(0xfff6f2ee),
                            borderRadius: AppRadius.borderLg,
                          ),
                          child: OverflowBox(
                            minWidth: 234,
                            maxWidth: 234,
                            minHeight: 156,
                            maxHeight: 156,
                            child: Image.asset(
                              message.imageAsset!,
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
