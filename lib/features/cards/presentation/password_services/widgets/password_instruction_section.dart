import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/password_service_constants.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class PasswordInstructionSection extends StatelessWidget {
  const PasswordInstructionSection({
    super.key,
    required this.video,
    required this.instructionVideoUrl,
  });
  final VideoPlayerController? video;
  final String? instructionVideoUrl;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.current.passwordInstructionPrompt,
          style: passwordBody(context).copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        AppVideoPlayer(
          controller: video,
          poster: LayoutBuilder(
            builder: (context, constraints) => ClipRect(
              child: Stack(
                children: [
                  Positioned(
                    left: -constraints.maxWidth * .0016,
                    top: -constraints.maxHeight * .1162,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight * 1.4286,
                    child: AvpImage(
                      image:
                          '${AppConstants.baseImage}password_instruction.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
          ),
          playLabel: S.current.passwordPlay,
          pauseLabel: S.current.passwordPause,
          unavailableLabel: S.current.passwordVideoUnavailable,
          retryLabel: S.current.dashboardRetry,
          seekLabel: S.current.passwordSeek,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppPasswordServiceColors.cameraNotice,
            borderRadius: AppRadius.borderSm,
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 20,
                child: AvpImage(
                  image: '${AppConstants.baseImage}password_camera_info.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  S.current.passwordCameraNotice,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    height: 18 / 12,
                    fontWeight: FontWeight.w500,
                    color: AppPasswordServiceColors.body,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (instructionVideoUrl == demoInstructionVideoUrl) ...[
          const SizedBox(height: 12),
          Text(
            S.current.passwordDemoVideo,
            style: Theme.of(context).textTheme.bodySmall!
                .copyWith(color: context.colors.textTertiary, height: 18 / 12),
          ),
        ],
      ],
    );
  }
}
