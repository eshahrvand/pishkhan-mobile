import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class AppFileUploadBaseEmptyContent extends StatelessWidget {
  const AppFileUploadBaseEmptyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppPalette.gray100,
            border: Border.all(color: AppPalette.gray50, width: 6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AvpImage(
              image: AppAssets.fileUploadUploadCloud,
              width: 20,
              height: 20,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 20,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('برای', style: _bodyStyle),
                const SizedBox(width: 4),
                Text('بارگذاری فایل اینجا', style: _actionStyle),
                const SizedBox(width: 4),
                Text('را کلیک کنید.', style: _bodyStyle),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 18,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'فرمت فایل: XLS  |  حداکثر حجم: ۱۰۰ KB',
              textAlign: TextAlign.center,
              style: _supportingStyle,
            ),
          ),
        ),
      ],
    );
  }

  TextStyle get _actionStyle => _bodyStyle.copyWith(
    color: AppPalette.brand700,
    fontWeight: FontWeight.w600,
  );
  TextStyle get _bodyStyle => AppTypography.bodyMedium.copyWith(
    color: AppPalette.gray600,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0,
  );
  TextStyle get _supportingStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray600,
    height: 18 / 12,
    letterSpacing: 0,
  );
}
