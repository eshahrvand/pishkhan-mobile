import 'dart:math' as math;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

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
  });

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
  Widget build(BuildContext context) =>
      variant == AppAddressCardVariant.delivery
      ? _delivery(context)
      : Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            key: const Key('app_address_card'),
            width: 343,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppPalette.gray50,
              borderRadius: AppRadius.borderMd,
              boxShadow: AppShadows.sm,
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
                          child: SvgPicture.asset(
                            AppAssets.iconMoreVertical20Gray700,
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _isHome ? 'خانه' : 'محل کار',
                          textAlign: TextAlign.right,
                          style: _mediumStyle(AppPalette.gray900),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Transform.rotate(
                        angle: math.pi,
                        child: Transform.flip(
                          flipY: true,
                          child: SvgPicture.asset(
                            _isHome
                                ? AppAssets.addressCardHomeHeart
                                : AppAssets.addressCardBuildings,
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
                  child: SvgPicture.asset(
                    AppAssets.dividerCardGray200,
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(height: 8),
                _detailRow(_phoneNumber, 'شماره تلفن:'),
                const SizedBox(height: 8),
                _detailRow(postalCode, 'آدرس پستی:'),
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
                        InkWell(
                          key: const Key('app_address_review'),
                          onTap: onReviewTap,
                          borderRadius: AppRadius.borderSm,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            textDirection: TextDirection.ltr,
                            children: [
                              SvgPicture.asset(
                                AppAssets.addressCardAngleLeft,
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'بررسی',
                                style: _mediumStyle(AppPalette.brand600),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'وضعیت اسکان و املاک',
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

  Widget _detailRow(String value, String label) => SizedBox(
    height: 22,
    child: Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
            style: _mediumStyle(AppPalette.gray900),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: _regularStyle(AppPalette.gray700)),
      ],
    ),
  );

  TextStyle _regularStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    height: 18 / 12,
    letterSpacing: 0,
  );

  TextStyle _mediumStyle(Color color) =>
      _regularStyle(color).copyWith(fontWeight: FontWeight.w500);

  Widget _delivery(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      key: const Key('app_address_delivery'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Semantics(
            button: true,
            label: deleteLabel,
            child: InkWell(
              onTap: onDeleteTap,
              child: SizedBox(
                width: 20,
                height: 20,
                child: deleteIcon ?? SvgPicture.asset(AppAssets.issuanceTrash),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _address,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: AppTypography.bodyMedium.copyWith(
                color: context.colors.textPrimary,
                height: 20 / 14,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
