import 'app_agent_card.dart';

import 'package:flutter/material.dart';

enum AppAgentStatus { active, waiting, expired }

/// An account for which the current user acts as an agent.
class AppMeAsAgentCard extends StatelessWidget {
  const AppMeAsAgentCard({
    super.key,
    this.depositNumber = '۱.۲۳۴۵۶۷.۱',
    this.kind = 'صدور دسته چک',
    this.owner = 'بهار مبارک',
    this.validUntil = '۱۴۰۵/۰۶/۳۰',
    this.status = AppAgentStatus.active,
    this.onMorePressed,
    this.bodyColor,
    this.detailLabelColor,
    this.actionAlignment = Alignment.center,
  });

  final String depositNumber;
  final String kind;
  final String owner;
  final String validUntil;
  final AppAgentStatus status;
  final VoidCallback? onMorePressed;
  final Color? bodyColor;
  final Color? detailLabelColor;
  final AlignmentGeometry actionAlignment;

  @override
  Widget build(BuildContext context) {
    return AppAgentCard(
      key: const Key('app_me_as_agent_card'),
      title: depositNumber,
      status: status,
      onMorePressed: onMorePressed,
      bodyColor: bodyColor,
      detailLabelColor: detailLabelColor,
      actionAlignment: actionAlignment,
      rows: [
        (label: 'نوع نمایندگی', value: kind),
        (label: 'نام صاحب سپرده', value: owner),
        (label: 'تاریخ اعتبار', value: validUntil),
      ],
    );
  }
}

/// A person the current user has appointed as an agent.
class AppMyAgentCard extends StatelessWidget {
  const AppMyAgentCard({
    super.key,
    this.name = 'بهار مبارک',
    this.identityNumber = '۰۰۸۱۲۳۴۵۶۷',
    this.kind = 'صدور دسته چک',
    this.depositNumber = '۱.۲۳۴۵۶۷.۱',
    this.validUntil = '۱۴۰۵/۰۶/۳۰',
    this.status = AppAgentStatus.active,
    this.onMorePressed,
    this.bodyColor,
    this.detailLabelColor,
    this.actionAlignment = Alignment.center,
  });

  final String name;
  final String identityNumber;
  final String kind;
  final String depositNumber;
  final String validUntil;
  final AppAgentStatus status;
  final VoidCallback? onMorePressed;
  final Color? bodyColor;
  final Color? detailLabelColor;
  final AlignmentGeometry actionAlignment;

  @override
  Widget build(BuildContext context) {
    return AppAgentCard(
      key: const Key('app_my_agent_card'),
      title: name,
      secondary: identityNumber,
      status: status,
      onMorePressed: onMorePressed,
      bodyColor: bodyColor,
      detailLabelColor: detailLabelColor,
      actionAlignment: actionAlignment,
      rows: [
        (label: 'نوع نمایندگی', value: kind),
        (label: 'سپرده', value: depositNumber),
        (label: 'تاریخ اعتبار', value: validUntil),
      ],
    );
  }
}
