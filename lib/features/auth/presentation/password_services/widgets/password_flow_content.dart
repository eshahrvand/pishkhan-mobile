import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_instruction_section.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_recording_section.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_selection_section.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_serial_form.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_request_status.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_styles.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/second_password_form.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

class PasswordFlowContent extends StatelessWidget {
  const PasswordFlowContent({
    super.key,
    required this.selectOperation,
    required this.video,
    required this.instructionVideoUrl,
  });
  final bool selectOperation;
  final VideoPlayerController? video;
  final String? instructionVideoUrl;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SecondPasswordCubit, SecondPasswordState>(
      buildWhen: (previous, state) =>
          previous.step != state.step ||
          previous.status != state.status ||
          previous.catalog != state.catalog ||
          previous.operation != state.operation ||
          previous.kind != state.kind ||
          previous.cardId != state.cardId ||
          previous.secondPasswordSelected != state.secondPasswordSelected ||
          previous.record != state.record ||
          previous.failure != state.failure,
      builder: (context, state) =>
          state.isChange &&
              state.record != null &&
              state.submissionStatus != RequestStatus.success
          ? SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 36, 16, 20),
              child: PasswordStatusContent(record: state.record!),
            )
          : state.record != null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              // Recreate controllers and reset scrolling when the flow step changes.
              key: ValueKey(state.step),

              padding: EdgeInsetsDirectional.fromSTEB(
                16,
                (state.step == SecondPasswordStep.password &&
                            !state.isChange) ||
                        state.step == SecondPasswordStep.serial
                    ? 14
                    : 16,
                16,
                20,
              ),
              child: PasswordFlowBody(
                state: state,
                selectOperation: selectOperation,
                video: video,
                instructionVideoUrl: instructionVideoUrl,
              ),
            ),
    );
  }
}

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
    final l = context.l10n;
    if (state.status == RequestStatus.initial ||
        state.status == RequestStatus.loading) {
      return Center(
        child: AppButton(
          onPressed: null,
          isLoading: true,
          label: l.dashboardLoading,
        ),
      );
    }
    if (state.catalog?.cards.isEmpty == true ||
        state.status == RequestStatus.failure) {
      return Column(
        children: [
          Text(
            state.catalog?.cards.isEmpty == true
                ? l.cardsEmpty
                : l.dashboardLoadError,
          ),
          const SizedBox(height: 16),
          AppButton(onPressed: cubit.load, label: l.dashboardRetry),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.failure != null) ...[
          Text(
            l.dashboardLoadError,
            style: passwordBody(context).copyWith(color: context.colors.error),
          ),
          const SizedBox(height: 12),
        ],
        switch (state.step) {
          SecondPasswordStep.selection => PasswordSelectionSection(
            state: state,
            selectOperation: selectOperation,
          ),
          SecondPasswordStep.password => const SecondPasswordForm(),
          SecondPasswordStep.serial => const PasswordSerialForm(),
          SecondPasswordStep.instruction => PasswordInstructionSection(
            video: video,
            instructionVideoUrl: instructionVideoUrl,
          ),
          SecondPasswordStep.recording => const PasswordRecordingSection(),
        },
      ],
    );
  }
}
