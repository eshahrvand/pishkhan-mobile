import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../widgets/password_flow_content.dart';
import '../widgets/password_flow_footer.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/features/auth/data/repositories/mock_password_repository.dart';
import 'package:pishkhan_mobile/features/auth/domain/entities/password_data.dart';
import 'package:pishkhan_mobile/features/auth/domain/repositories/password_services_repository.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/password_service_constants.dart';
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/password_sheets.dart';

class SecondPasswordScreen extends StatefulWidget {
  const SecondPasswordScreen({
    super.key,
    this.repository,
    this.initialCardNumber,
    this.selectOperation = false,
    this.instructionVideoUrl = demoVideoUrl,
    this.onTermsRequested,
    this.onSubmitted,
    this.videoController,
  });
  static const demoVideoUrl = demoInstructionVideoUrl;
  final PasswordServicesRepository? repository;
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
  bool _sheetOpen = false;
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

  Future<void> _back(BuildContext context) async {
    if (context.read<SecondPasswordCubit>().state.checkStatus ==
            RequestStatus.loading ||
        context.read<SecondPasswordCubit>().state.submissionStatus ==
            RequestStatus.loading) {
      return;
    }
    if (_fullStatus(context.read<SecondPasswordCubit>().state)) {
      NavigationActions.back(context);
      return;
    }
    if (context.read<SecondPasswordCubit>().back()) return;
    if (context.read<SecondPasswordCubit>().state.submissionStatus !=
            RequestStatus.success &&
        context.read<SecondPasswordCubit>().state.selectionComplete) {
      final leave = await showPasswordExitDialog(context);
      if (leave != true || !context.mounted) return;
    }
    if (context.mounted) NavigationActions.back(context);
  }

  bool _fullStatus(SecondPasswordState state) =>
      state.isChange &&
      state.record != null &&
      state.submissionStatus != RequestStatus.success;

  Future<void> _record(BuildContext context, SecondPasswordState state) async {
    if (_fullStatus(state)) return;
    if (_sheetOpen || state.record == null || !context.mounted) return;
    _sheetOpen = true;
    final submitted = state.submissionStatus == RequestStatus.success;
    if (submitted) widget.onSubmitted?.call(state.record!);
    await showPasswordRecord(
      context,
      state.record!,
      newlySubmitted: submitted,
      operation: state.operation!,
    );
    _sheetOpen = false;
    if (!context.mounted) return;
    if (submitted) {
      NavigationActions.returnHome(context);
    } else {
      context.read<SecondPasswordCubit>().dismissRecord();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // These existing entry parameters intentionally restart the flow when changed.
      key: ValueKey((
        widget.repository,
        widget.initialCardNumber,
        widget.selectOperation,
      )),
      create: (context) => SecondPasswordCubit(
        repository: widget.repository ?? MockPasswordServicesRepository(),
        initialCardNumber: widget.initialCardNumber,
        selectOperation: widget.selectOperation,
      )..load(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocListener<SecondPasswordCubit, SecondPasswordState>(
          listenWhen: (previous, state) =>
              previous.record != state.record ||
              previous.submissionStatus != state.submissionStatus,
          listener: (context, state) => _record(context, state),
          child: BlocBuilder<SecondPasswordCubit, SecondPasswordState>(
            buildWhen: (previous, current) =>
                previous.isChange != current.isChange ||
                previous.step != current.step,
            builder: (context, state) {
              return PopScope<void>(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) _back(context);
                },
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Stack(
                    children: [
                      Positioned.fill(
                        child:
                            BlocBuilder<
                              SecondPasswordCubit,
                              SecondPasswordState
                            >(
                              buildWhen: (previous, current) =>
                                  previous.isChange != current.isChange ||
                                  previous.step != current.step,
                              builder: (context, state) => ColoredBox(
                                color:
                                    (state.isChange ||
                                        (widget.selectOperation &&
                                            state.step ==
                                                SecondPasswordStep.selection) ||
                                        state.step.index >=
                                            SecondPasswordStep
                                                .instruction
                                                .index)
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
                              onTrailingPressed: () => _back(context),
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
                              onBack: () => _back(context),
                            ),
                          ],
                        ),
                      ),
                    ],
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
