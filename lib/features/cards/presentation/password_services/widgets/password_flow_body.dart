import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_instruction_section.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_recording_section.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_selection_section.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_serial_form.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/second_password_form.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class PasswordFlowBody extends StatelessWidget {
  const PasswordFlowBody({
    super.key,
    required this.state,
    required this.selectOperation,
    required this.video,
    required this.instructionVideoUrl,
  });
  final SecondPasswordState state;
  final bool selectOperation;
  final VideoPlayerController? video;
  final String? instructionVideoUrl;
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SecondPasswordCubit>();

    if (state.catalogStatus == RequestStatus.initial ||
        state.catalogStatus == RequestStatus.loading) {
      return Center(
        child: AppButton(
          onPressed: null,
          isLoading: true,
          label: S.current.dashboardLoading,
        ),
      );
    }
    if (state.catalog?.cards.isEmpty == true ||
        state.catalogStatus == RequestStatus.failure) {
      return Column(
        children: [
          Text(
            state.catalog?.cards.isEmpty == true
                ? S.current.cardsEmpty
                : S.current.dashboardLoadError,
          ),
          const SizedBox(height: 16),
          AppButton(
            onPressed: cubit.fetchCatalog,
            label: S.current.dashboardRetry,
          ),
        ],
      );
    }
    return AbsorbPointer(
      absorbing: !state.isEditable,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          switch (state.step) {
            SecondPasswordStep.selection => PasswordSelectionSection(
              state: state,
              selectOperation: selectOperation,
            ),
            SecondPasswordStep.password => SecondPasswordForm(state: state),
            SecondPasswordStep.serial => PasswordSerialForm(state: state),
            SecondPasswordStep.instruction => PasswordInstructionSection(
              video: video,
              instructionVideoUrl: instructionVideoUrl,
            ),
            SecondPasswordStep.recording => PasswordRecordingSection(
              state: state,
            ),
          },
        ],
      ),
    );
  }
}
