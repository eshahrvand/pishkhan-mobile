import 'package:pishkhan_mobile/l10n/l10n.dart';
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
  static List<NotificationMessage> examples(AppLocalizations l10n) => [
    NotificationMessage(
      id: 'secured-loan',
      title: l10n.notificationLoanTitle,
      subtitle: l10n.notificationLoanSubtitle,
      dateLabel: l10n.notificationToday,
    ),
    NotificationMessage(
      id: 'gold-investment',
      title: l10n.notificationInvestmentTitle,
      subtitle: l10n.notificationInvestmentSubtitle,
      dateLabel: l10n.notificationYesterday,
    ),
    for (final date in [
      l10n.notificationFiveDays,
      l10n.notificationSevenDays,
      l10n.notificationSampleDate,
    ])
      NotificationMessage(
        id: 'security-$date',
        title: l10n.notificationSecurityTitle,
        subtitle: l10n.notificationSecuritySubtitle,
        dateLabel: date,
        isRead: true,
        intro: l10n.notificationSecurityIntro,
        advice: l10n.notificationSecurityAdvice,
        bullets: [
          l10n.notificationSecurityCode,
          l10n.notificationSecurityLinks,
          l10n.notificationSecurityOfficial,
        ],
        closing: l10n.notificationSecurityClosing,
        imageAsset: AppAssets.notificationSecurity,
      ),
  ];
}
