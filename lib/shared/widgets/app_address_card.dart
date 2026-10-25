import 'package:pishkhan_mobile/core/config/constant.dart';

import 'app_address_card_detail_row.dart';
import 'app_address_card_delivery.dart';

import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

enum AppAddressType { home, work }

enum AppAddressCardVariant { full, delivery }

/// Figma address summary card with Home and Work variants.
class AppAddressCard extends StatelessWidget {
  const AppAddressCard({
    super.key,
    this.type = AppAddressType.home,
    this.phoneNumber,
    this.postalCode = '191213456۴',
    this.address,
    this.onMoreTap,
    this.onReviewTap,
    this.variant = AppAddressCardVariant.full,
    this.onDeleteTap,
    this.deleteIcon,
    this.deleteLabel = 'حذف آدرس',
    this.titleLabel,
    this.phoneLabel = 'شماره تلفن:',
    this.postalLabel = 'آدرس پستی:',
    this.residenceLabel = 'وضعیت اسکان و املاک',
    this.reviewLabel = 'بررسی',
    this.reviewStatus,
    this.outlined = false,
  });

  final String? titleLabel;
  final String phoneLabel;
  final String postalLabel;
  final String residenceLabel;
  final String reviewLabel;
  final Widget? reviewStatus;
  final bool outlined;
  final AppAddressType type;
  final String? phoneNumber;
  final String postalCode;
  final String? address;
  final VoidCallback? onMoreTap;
  final VoidCallback? onReviewTap;
  final AppAddressCardVariant variant;
  final VoidCallback? onDeleteTap;
  final Widget? deleteIcon;
  final String deleteLabel;

  bool get _isHome => type == AppAddressType.home;

  String get _phoneNumber =>
      phoneNumber ?? (_isHome ? '۰۲۱-۲۲۲۶۱۹۱۴' : '۰۲۱-۸۸۲۶۱۹۱۴');

  String get _address =>
      address ??
      (_isHome
          ? 'تهران - تجریش -  ابتدای خیابان شریعتی - کوچه پروین- پلاک ۲۰ - طبقه ۱ - واحد ۱'
          : 'تهران - خیابان آزادی - خیابان دکتر هوشیار - نبش خیابان گرانمایه - پلاک ۱ - واحد ۳ ');

  @override
  Widget build(BuildContext context) {
    return variant == AppAddressCardVariant.delivery
        ? AppAddressCardDelivery(
            address: address,
            deleteIcon: deleteIcon,
            deleteLabel: deleteLabel,
            onDeleteTap: onDeleteTap,
            type: type,
          )
        : Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              key: const Key('app_address_card'),
              width: 343,
              padding: EdgeInsets.symmetric(
                horizontal: outlined ? 15.2 : 16,
                vertical: outlined ? 11.2 : 12,
              ),
              decoration: BoxDecoration(
                color: outlined ? context.colors.surface : AppPalette.gray50,
                borderRadius: AppRadius.borderMd,
                boxShadow: outlined ? null : AppShadows.sm,
                border: outlined
                    ? Border.all(color: AppPalette.gray200, width: .8)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 20,
                    child: Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        InkWell(
                          key: const Key('app_address_more'),
                          onTap: onMoreTap,
                          child: Transform.rotate(
                            angle: -math.pi / 2,
                            child: AvpImage(
                              image:
                                  '${AppConstants.baseImage}icon_more_vertical_20_gray700.svg',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            titleLabel ?? (_isHome ? 'خانه' : 'محل کار'),
                            textAlign: TextAlign.right,
                            style: _mediumStyle(AppPalette.gray900),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Transform.rotate(
                          angle: math.pi,
                          child: Transform.flip(
                            flipY: true,
                            child: AvpImage(
                              image: _isHome
                                  ? '${AppConstants.baseImage}address_card_home_heart.svg'
                                  : '${AppConstants.baseImage}address_card_buildings.svg',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: .5,
                    child: AvpImage(
                      image:
                          '${AppConstants.baseImage}divider_card_gray200.svg',
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppAddressCardDetailRow(
                    value: _phoneNumber,
                    label: phoneLabel,
                  ),
                  const SizedBox(height: 8),
                  AppAddressCardDetailRow(
                    value: postalCode,
                    label: postalLabel,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _address,
                    textAlign: TextAlign.right,
                    style: _mediumStyle(AppPalette.gray900),
                  ),
                  if (_isHome) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 22,
                      child: Row(
                        textDirection: TextDirection.ltr,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (reviewStatus != null)
                            reviewStatus!
                          else
                            InkWell(
                              key: const Key('app_address_review'),
                              onTap: onReviewTap,
                              borderRadius: AppRadius.borderSm,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                textDirection: TextDirection.ltr,
                                children: [
                                  AvpImage(
                                    image:
                                        '${AppConstants.baseImage}address_card_angle_left.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    reviewLabel,
                                    style: _mediumStyle(AppPalette.brand600),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: Text(
                              residenceLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: _regularStyle(AppPalette.gray700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
  }

  TextStyle _regularStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle _mediumStyle(Color color) =>
      _regularStyle(color).copyWith(fontWeight: FontWeight.w500);
}
