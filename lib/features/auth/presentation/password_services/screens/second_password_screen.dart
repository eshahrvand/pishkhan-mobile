import 'dart:async';

import 'package:avp_ui/avp_ui.dart';
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
import 'package:pishkhan_mobile/features/auth/presentation/password_services/widgets/second_password_view.dart';

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
  late SecondPasswordCubit cubit;
  VideoPlayerController? video;
  bool _sheetOpen = false;
  @override
  void initState() {
    super.initState();
    _createCubit();
    _createVideo();
  }

  void _createCubit() => cubit = SecondPasswordCubit(
    initialState: const SecondPasswordState(),
    repository: widget.repository ?? MockPasswordServicesRepository(),
    initialCardNumber: widget.initialCardNumber,
    selectOperation: widget.selectOperation,
  )..load();
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
    if (oldWidget.repository != widget.repository ||
        oldWidget.initialCardNumber != widget.initialCardNumber ||
        oldWidget.selectOperation != widget.selectOperation) {
      cubit.close();
      _createCubit();
    }
    if (oldWidget.instructionVideoUrl != widget.instructionVideoUrl ||
        oldWidget.videoController != widget.videoController) {
      if (oldWidget.videoController == null) video?.dispose();
      _createVideo();
    }
  }

  @override
  void dispose() {
    cubit.close();
    if (widget.videoController == null) video?.dispose();
    super.dispose();
  }

  Future<void> _back() async {
    if (cubit.state.checkStatus == RequestStatus.loading ||
        cubit.state.submissionStatus == RequestStatus.loading) {
      return;
    }
    if (_fullStatus(cubit.state)) {
      NavigationActions.back(context);
      return;
    }
    if (cubit.back()) return;
    if (cubit.state.submissionStatus != RequestStatus.success &&
        cubit.state.selectionComplete) {
      final leave = await showPasswordExitDialog(context);
      if (leave != true || !mounted) return;
    }
    if (mounted) NavigationActions.back(context);
  }

  bool _fullStatus(SecondPasswordState state) =>
      state.isChange &&
      state.record != null &&
      state.submissionStatus != RequestStatus.success;

  Future<void> _record(SecondPasswordState state) async {
    if (_fullStatus(state)) return;
    if (_sheetOpen || state.record == null || !mounted) return;
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
    if (!mounted) return;
    if (submitted) {
      NavigationActions.returnHome(context);
    } else {
      cubit.dismissRecord();
    }
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: cubit,
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<SecondPasswordCubit, SecondPasswordState>(
        listenWhen: (previous, state) =>
            previous.record != state.record ||
            previous.submissionStatus != state.submissionStatus,
        listener: (context, state) => _record(state),
        child: PopScope<void>(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _back();
          },
          child: SecondPasswordView(
            selectOperation: widget.selectOperation,
            video: video,
            instructionVideoUrl: widget.instructionVideoUrl,
            onTermsRequested: widget.onTermsRequested,
            onBack: _back,
          ),
        ),
      ),
    ),
  );
}
