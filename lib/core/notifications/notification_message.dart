import 'package:equatable/equatable.dart';

enum NotificationExample {
  loan,
  investment,
  securityFiveDays,
  securitySevenDays,
  securitySampleDate,
}

/// Presentation data; a repository can supply messages without changing the UI.
class NotificationMessage extends Equatable {
  NotificationMessage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    this.isRead = false,
    this.example,
    this.intro,
    this.advice,
    Iterable<String> bullets = const [],
    this.closing,
    this.imageAsset,
  }) : bullets = List.unmodifiable(bullets);

  final String id, title, subtitle, dateLabel;
  final bool isRead;
  final NotificationExample? example;
  final String? intro, advice, closing, imageAsset;
  final List<String> bullets;

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    dateLabel,
    isRead,
    example,
    intro,
    advice,
    bullets,
    closing,
    imageAsset,
  ];

  NotificationMessage markRead() => NotificationMessage(
    id: id,
    title: title,
    subtitle: subtitle,
    dateLabel: dateLabel,
    isRead: true,
    example: example,
    intro: intro,
    advice: advice,
    bullets: bullets,
    closing: closing,
    imageAsset: imageAsset,
  );

  /// Stable sample identities and semantic content; UI owns their translations.
  static List<NotificationMessage> examples() => List.unmodifiable([
    NotificationMessage(
      id: 'secured-loan',
      title: '',
      subtitle: '',
      dateLabel: '',
      example: NotificationExample.loan,
    ),
    NotificationMessage(
      id: 'gold-investment',
      title: '',
      subtitle: '',
      dateLabel: '',
      example: NotificationExample.investment,
    ),
    NotificationMessage(
      id: 'security-five-days',
      title: '',
      subtitle: '',
      dateLabel: '',
      isRead: true,
      example: NotificationExample.securityFiveDays,
    ),
    NotificationMessage(
      id: 'security-seven-days',
      title: '',
      subtitle: '',
      dateLabel: '',
      isRead: true,
      example: NotificationExample.securitySevenDays,
    ),
    NotificationMessage(
      id: 'security-sample-date',
      title: '',
      subtitle: '',
      dateLabel: '',
      isRead: true,
      example: NotificationExample.securitySampleDate,
    ),
  ]);
}
