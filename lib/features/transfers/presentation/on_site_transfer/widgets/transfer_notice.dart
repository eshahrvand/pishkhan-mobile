import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// The existing Figma informational surface, reused by date and file guidance.
class TransferNotice extends StatelessWidget {
  const TransferNotice({
    super.key,
    required this.text,
    this.onTap,
    this.linkText,
    this.suffix,
  });
  final String text;
  final String? linkText;
  final String? suffix;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPasswordServiceColors.cameraNotice,
      borderRadius: AppRadius.borderSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              AvpImage(
                image: AppAssets.passwordCameraInfo,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: text,
                    children: [
                      if (linkText != null)
                        TextSpan(
                          text: linkText,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: context.colors.primary,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      if (suffix != null) TextSpan(text: suffix),
                    ],
                  ),
                  style: Theme.of(context).textTheme.bodySmall!
                      .copyWith(height: 18 / 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
