import 'app_representative_card.dart';

import 'package:flutter/material.dart';

enum AppRepresentativeStatus { active, waiting, expired }

/// A representation granted to the current user.
class AppMeAsRepresentativeCard extends StatelessWidget {
  const AppMeAsRepresentativeCard({
    super.key,
    this.depositNumber = '۱.۲۳۴۵۶۷.۱',
    this.kind = 'صدور دسته چک',
    this.owner = 'بهار مبارک',
    this.validUntil = '۱۴۰۵/۰۶/۳۰',
    this.status = AppRepresentativeStatus.active,
    this.onMorePressed,
  });

  final String depositNumber;
  final String kind;
  final String owner;
  final String validUntil;
  final AppRepresentativeStatus status;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    return AppRepresentativeCard(
      key: const Key('app_me_as_representative_card'),
      title: depositNumber,
      status: status,
      onMorePressed: onMorePressed,
      rows: [
        (label: 'نوع نمایندگی', value: kind),
        (label: 'نام صاحب سپرده', value: owner),
        (label: 'تاریخ اعتبار', value: validUntil),
      ],
    );
  }
}

/// A representation the current user has granted to another person.
class AppMyRepresentativeCard extends StatelessWidget {
  const AppMyRepresentativeCard({
    super.key,
    this.name = 'بهار مبارک',
    this.identityNumber = '۰۰۸۱۲۳۴۵۶۷',
    this.kind = 'صدور دسته چک',
    this.depositNumber = '۱.۲۳۴۵۶۷.۱',
    this.validUntil = '۱۴۰۵/۰۶/۳۰',
    this.status = AppRepresentativeStatus.active,
    this.onMorePressed,
  });

  final String name;
  final String identityNumber;
  final String kind;
  final String depositNumber;
  final String validUntil;
  final AppRepresentativeStatus status;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    return AppRepresentativeCard(
      key: const Key('app_my_representative_card'),
      title: name,
      secondary: identityNumber,
      status: status,
      onMorePressed: onMorePressed,
      rows: [
        (label: 'نوع نمایندگی', value: kind),
        (label: 'سپرده', value: depositNumber),
        (label: 'تاریخ اعتبار', value: validUntil),
      ],
    );
  }
}
