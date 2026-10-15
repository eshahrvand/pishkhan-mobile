import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/features/cards/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_flow_content.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_flow_footer.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

class SecondPasswordView extends StatelessWidget {
  const SecondPasswordView({
    super.key,
    required this.selectOperation,
    required this.video,
    required this.instructionVideoUrl,
    required this.onBack,
    this.onTermsRequested,
  });
  final bool selectOperation;
  final VideoPlayerController? video;
  final String? instructionVideoUrl;
  final VoidCallback onBack;
  final VoidCallback? onTermsRequested;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: BlocBuilder<SecondPasswordCubit, SecondPasswordState>(
              buildWhen: (previous, current) =>
                  previous.isChange != current.isChange ||
                  previous.step != current.step,
              builder: (context, state) => ColoredBox(
                color:
                    (state.isChange ||
                        (selectOperation &&
                            state.step == SecondPasswordStep.selection) ||
                        state.step.index >=
                            SecondPasswordStep.instruction.index)
                    ? context.colors.surface
                    : context.colors.surfaceSubtle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppTopBar(
                  title: S.current.passwordTitle,
                  showLeadingActions: false,
                  trailingIcon: SizedBox.square(
                    dimension: 24,
                    child: AvpImage(
                      image: AppAssets.cardFeaturesBack,
                      fit: BoxFit.contain,
                    ),
                  ),
                  trailingTooltip: S.current.backLabel,
                  onTrailingPressed: onBack,
                ),
                Expanded(
                  child: PasswordFlowContent(
                    selectOperation: selectOperation,
                    video: video,
                    instructionVideoUrl: instructionVideoUrl,
                  ),
                ),
                PasswordFlowFooter(
                  onTermsRequested: onTermsRequested,
                  onBack: onBack,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
