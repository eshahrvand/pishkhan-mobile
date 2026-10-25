import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../widgets/password_flow_content.dart';
import '../widgets/password_flow_footer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/features/cards/domain/entities/password_data.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/password_service_constants.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_sheets.dart';

class SecondPasswordScreen extends StatefulWidget {
  const SecondPasswordScreen({
    super.key,
    this.initialCardNumber,
    this.selectOperation = false,
    this.instructionVideoUrl = demoVideoUrl,
    this.onTermsRequested,
    this.onSubmitted,
    this.videoController,
  });
  static const demoVideoUrl = demoInstructionVideoUrl;
  final bool selectOperation;
  final String? initialCardNumber, instructionVideoUrl;
  final VideoPlayerController? videoController;
  final VoidCallback? onTermsRequested;
  final ValueChanged<PasswordRequestRecord>? onSubmitted;
  @override
  State<SecondPasswordScreen> createState() => _SecondPasswordScreenState();
}

class _SecondPasswordScreenState extends State<SecondPasswordScreen> {
  VideoPlayerController? video;
  @override
  void initState() {
    super.initState();
    _createVideo();
  }

  void _createVideo() => video =
      widget.videoController ??
      (widget.instructionVideoUrl == null
          ? null
          : VideoPlayerController.networkUrl(
              Uri.parse(widget.instructionVideoUrl!),
            ));
  @override
  void didUpdateWidget(SecondPasswordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.instructionVideoUrl != widget.instructionVideoUrl ||
        oldWidget.videoController != widget.videoController) {
      if (oldWidget.videoController == null) video?.dispose();
      _createVideo();
    }
  }

  @override
  void dispose() {
    if (widget.videoController == null) video?.dispose();
    super.dispose();
  }

  Future<void> _handleEffect(
    BuildContext context,
    SecondPasswordState state,
  ) async {
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    switch (state.effect) {
      case PasswordUnsupportedRequested():
        context.read<SecondPasswordCubit>().consumeSecondPasswordInteraction();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(S.current.passwordUnsupported)));
      case PasswordExitRequested():
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case PasswordHomeRequested():
        NavigationActions.returnHome(context);
      case PasswordExitConfirmationRequested():
        context.read<SecondPasswordCubit>().consumeSecondPasswordInteraction();
        final confirmed = await showPasswordExitDialog(context);
        if (context.mounted) {
          context.read<SecondPasswordCubit>().applyExitConfirmation(confirmed);
        }
      case PasswordRecordRequested(
        :final record,
        :final operation,
        :final newlySubmitted,
      ):
        context.read<SecondPasswordCubit>().consumeSecondPasswordInteraction();
        if (newlySubmitted) widget.onSubmitted?.call(record);
        if (!context.mounted) return;
        await showPasswordRecord(
          context,
          record,
          newlySubmitted: newlySubmitted,
          operation: operation,
        );
        if (context.mounted) {
          context.read<SecondPasswordCubit>().applyRecordDismissal();
        }
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SecondPasswordCubit>(
      create: (_) => SecondPasswordCubit(
        initialCardNumber: widget.initialCardNumber,
        selectOperation: widget.selectOperation,
      )..fetchCatalog(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocListener<SecondPasswordCubit, SecondPasswordState>(
          listenWhen: (previous, current) =>
              (previous.effect != current.effect &&
                  current.effect != null) ||
              ((previous.catalogStatus != current.catalogStatus &&
                      current.catalogStatus == RequestStatus.failure) ||
                  (previous.existingRequestStatus !=
                          current.existingRequestStatus &&
                      current.existingRequestStatus == RequestStatus.failure) ||
                  (previous.submissionStatus != current.submissionStatus &&
                      current.submissionStatus == RequestStatus.failure)),
          listener: _handleEffect,
          child: BlocBuilder<SecondPasswordCubit, SecondPasswordState>(
            builder: (context, state) {
              return PopScope<void>(
                canPop:
                    (state.catalogStatus != RequestStatus.loading &&
                        state.existingRequestStatus != RequestStatus.loading &&
                        state.submissionStatus != RequestStatus.loading) &&
                    (state.effect is PasswordExitRequested),
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop &&
                      state.catalogStatus != RequestStatus.loading &&
                      state.existingRequestStatus != RequestStatus.loading &&
                      state.submissionStatus != RequestStatus.loading) {
                    context.read<SecondPasswordCubit>().requestBack();
                  }
                },
                child: Scaffold(
                  backgroundColor:
                      (state.isChange ||
                          (widget.selectOperation &&
                              state.step == SecondPasswordStep.selection) ||
                          state.step.index >=
                              SecondPasswordStep.instruction.index)
                      ? context.colors.surface
                      : context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Column(
                      children: [
                        AppTopBar(
                          title: S.current.passwordTitle,
                          showLeadingActions: false,
                          trailingIcon: SizedBox.square(
                            dimension: 24,
                            child: AvpImage(
                              image:
                                  '${AppConstants.baseImage}card_features_back.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                          trailingTooltip: S.current.backLabel,
                          onTrailingPressed:
                              (state.catalogStatus != RequestStatus.loading &&
                                  state.existingRequestStatus !=
                                      RequestStatus.loading &&
                                  state.submissionStatus !=
                                      RequestStatus.loading)
                              ? () => context
                                    .read<SecondPasswordCubit>()
                                    .requestBack()
                              : null,
                        ),
                        Expanded(
                          child: PasswordFlowContent(
                            selectOperation: widget.selectOperation,
                            video: video,
                            instructionVideoUrl: widget.instructionVideoUrl,
                          ),
                        ),
                        PasswordFlowFooter(
                          onTermsRequested: widget.onTermsRequested,
                          onBack: () =>
                              context.read<SecondPasswordCubit>().requestBack(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
