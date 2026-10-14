import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// Presentation data; a repository can supply messages without changing the UI.
class NotificationMessage {
  const NotificationMessage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    this.isRead = false,
    this.intro,
    this.advice,
    this.bullets = const [],
    this.closing,
    this.imageAsset,
  });

  final String id, title, subtitle, dateLabel;
  final bool isRead;
  final String? intro, advice, closing, imageAsset;
  final List<String> bullets;

  NotificationMessage markRead() => NotificationMessage(
    id: id,
    title: title,
    subtitle: subtitle,
    dateLabel: dateLabel,
    isRead: true,
    intro: intro,
    advice: advice,
    bullets: bullets,
    closing: closing,
    imageAsset: imageAsset,
  );

  /// The supplied Figma examples until a notification repository is connected.
  static List<NotificationMessage> examples() => [
    NotificationMessage(
      id: 'secured-loan',
      title: S.current.notificationLoanTitle,
      subtitle: S.current.notificationLoanSubtitle,
      dateLabel: S.current.notificationToday,
    ),
    NotificationMessage(
      id: 'gold-investment',
      title: S.current.notificationInvestmentTitle,
      subtitle: S.current.notificationInvestmentSubtitle,
      dateLabel: S.current.notificationYesterday,
    ),
    for (final date in [
      S.current.notificationFiveDays,
      S.current.notificationSevenDays,
      S.current.notificationSampleDate,
    ])
      NotificationMessage(
        id: 'security-$date',
        title: S.current.notificationSecurityTitle,
        subtitle: S.current.notificationSecuritySubtitle,
        dateLabel: date,
        isRead: true,
        intro: S.current.notificationSecurityIntro,
        advice: S.current.notificationSecurityAdvice,
        bullets: [
          S.current.notificationSecurityCode,
          S.current.notificationSecurityLinks,
          S.current.notificationSecurityOfficial,
        ],
        closing: S.current.notificationSecurityClosing,
        imageAsset: AppAssets.notificationSecurity,
      ),
  ];
}
