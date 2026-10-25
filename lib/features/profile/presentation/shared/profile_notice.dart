import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

/// Shared notice used by the three personal-information services.
class ProfileNotice extends StatelessWidget {
  const ProfileNotice({
    super.key,
    required this.message,
    this.isError = false,
    this.messageSpans = const [],
  });
  final String message;
  final bool isError;
  final List<InlineSpan> messageSpans;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isError ? AppPalette.error50 : AppPalette.blueGray100,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvpImage(
            image: isError
                ? '${AppConstants.baseImage}chequebook_warning.svg'
                : '${AppConstants.baseImage}password_camera_info.svg',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(text: message, children: messageSpans),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppLoginColors.noticeText,
                fontWeight: FontWeight.w500,
                height: 18 / 12,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
