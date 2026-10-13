import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/password_service_constants.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class PasswordInstructionSection extends StatelessWidget {
  const PasswordInstructionSection({
    super.key,
    required this.video,
    required this.instructionVideoUrl,
  });
  final VideoPlayerController? video;
  final String? instructionVideoUrl;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.l10n.passwordInstructionPrompt,
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
                  child: Image.asset(
                    AppAssets.passwordInstruction,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          ),
        ),
        playLabel: context.l10n.passwordPlay,
        pauseLabel: context.l10n.passwordPause,
        unavailableLabel: context.l10n.passwordVideoUnavailable,
        retryLabel: context.l10n.dashboardRetry,
        seekLabel: context.l10n.passwordSeek,
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
              child: SvgPicture.asset(
                AppAssets.passwordCameraInfo,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.passwordCameraNotice,
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
          context.l10n.passwordDemoVideo,
          style: Theme.of(context).textTheme.bodySmall!
              .copyWith(color: context.colors.textTertiary, height: 18 / 12),
        ),
      ],
    ],
  );
}
