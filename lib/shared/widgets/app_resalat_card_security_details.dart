
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import 'app_resalat_card.dart';
import 'app_resalat_card_asset_action.dart';

class AppResalatCardSecurityDetails extends StatelessWidget {
  const AppResalatCardSecurityDetails({
    super.key,
    required this.cvv2,
    required this.expiry,
    required this.expiryLabel,
    required this.isVisible,
    required this.onVisibilityChanged,
    required this.size,
    required this.visibilityLabel,
  });
  final String cvv2;
  final String expiry;
  final String expiryLabel;
  final bool isVisible;
  final ValueChanged<bool>? onVisibilityChanged;
  final AppResalatCardSize size;
  final String? visibilityLabel;

  @override
  Widget build(BuildContext context) {
    Widget detail(
      String label,
      String value, {
      bool latin = false,
      bool center = false,
    }) => SizedBox(
      width: 64,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.ltr,
          children: [
            Text(
              label,
              textDirection: latin ? TextDirection.ltr : TextDirection.rtl,
              style: _detailStyle(),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              textDirection: TextDirection.ltr,
              style: _detailStyle().copyWith(
                fontWeight: _isSingle ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        detail(expiryLabel, isVisible ? expiry : '**/**'),
        detail('CVV2:', isVisible ? cvv2 : '****', latin: true, center: true),
        SizedBox(
          width: 64,
          height: 20,
          child: Align(
            alignment: Alignment.centerRight,
            child: AppResalatCardAssetAction(
              path: isVisible
                  ? AppAssets.resalatCardEye
                  : AppAssets.resalatCardEyeSlash,
              size: 20,
              label: visibilityLabel,
              onTap: onVisibilityChanged == null
                  ? null
                  : () => onVisibilityChanged!(!isVisible),
              contentKey: const Key('app_resalat_card_visibility'),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _detailStyle({double fontSize = 12, double height = 18 / 12}) =>
      AppTypography.bodySmall.copyWith(
        color: AppPalette.brand100,
        fontSize: fontSize,
        height: height,
        letterSpacing: 0,
      );
  bool get _isSingle => size == AppResalatCardSize.single;
}
