import '../../../domain/entities/notification_message.dart';

import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

String getNotificationTitle(NotificationMessage message) =>
    switch (message.example) {
      null => message.title,
      NotificationExample.loan => S.current.notificationLoanTitle,
      NotificationExample.investment => S.current.notificationInvestmentTitle,
      _ => S.current.notificationSecurityTitle,
    };
String getNotificationSubtitle(NotificationMessage message) =>
    switch (message.example) {
      null => message.subtitle,
      NotificationExample.loan => S.current.notificationLoanSubtitle,
      NotificationExample.investment =>
        S.current.notificationInvestmentSubtitle,
      _ => S.current.notificationSecuritySubtitle,
    };
String getNotificationDate(NotificationMessage message) =>
    switch (message.example) {
      null => message.dateLabel,
      NotificationExample.loan => S.current.notificationToday,
      NotificationExample.investment => S.current.notificationYesterday,
      NotificationExample.securityFiveDays => S.current.notificationFiveDays,
      NotificationExample.securitySevenDays => S.current.notificationSevenDays,
      NotificationExample.securitySampleDate =>
        S.current.notificationSampleDate,
    };
bool _isSecurityExample(NotificationMessage message) =>
    switch (message.example) {
      NotificationExample.securityFiveDays ||
      NotificationExample.securitySevenDays ||
      NotificationExample.securitySampleDate => true,
      _ => false,
    };
String? getNotificationIntro(NotificationMessage message) =>
    _isSecurityExample(message)
    ? S.current.notificationSecurityIntro
    : message.intro;
String? getNotificationAdvice(NotificationMessage message) =>
    _isSecurityExample(message)
    ? S.current.notificationSecurityAdvice
    : message.advice;
String? getNotificationClosing(NotificationMessage message) =>
    _isSecurityExample(message)
    ? S.current.notificationSecurityClosing
    : message.closing;
List<String> getNotificationBullets(NotificationMessage message) =>
    _isSecurityExample(message)
    ? [
        S.current.notificationSecurityCode,
        S.current.notificationSecurityLinks,
        S.current.notificationSecurityOfficial,
      ]
    : message.bullets;
String? getNotificationImage(NotificationMessage message) =>
    _isSecurityExample(message)
    ? AppAssets.notificationSecurity
    : message.imageAsset;
