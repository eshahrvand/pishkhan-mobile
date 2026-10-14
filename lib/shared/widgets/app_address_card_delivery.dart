
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import 'app_address_card.dart';

class AppAddressCardDelivery extends StatelessWidget {
  const AppAddressCardDelivery({
    super.key,
    required this.address,
    required this.deleteIcon,
    required this.deleteLabel,
    required this.onDeleteTap,
    required this.type,
  });
  final String? address;
  final Widget? deleteIcon;
  final String deleteLabel;
  final VoidCallback? onDeleteTap;
  final AppAddressType type;

  @override
  Widget build(BuildContext context) {
    return Directionality(
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
                  child:
                      deleteIcon ?? SvgPicture.asset(AppAssets.issuanceTrash),
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

  String get _address =>
      address ??
      (_isHome
          ? 'تهران - تجریش -  ابتدای خیابان شریعتی - کوچه پروین- پلاک ۲۰ - طبقه ۱ - واحد ۱'
          : 'تهران - خیابان آزادی - خیابان دکتر هوشیار - نبش خیابان گرانمایه - پلاک ۱ - واحد ۳ ');
  bool get _isHome => type == AppAddressType.home;
}
