import 'password_flow_body.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/cubit/second_password_cubit.dart';
import 'package:pishkhan_mobile/features/cards/presentation/password_services/widgets/password_request_status.dart';

class PasswordFlowContent extends StatefulWidget {
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
  State<PasswordFlowContent> createState() => _PasswordFlowContentState();
}

class _PasswordFlowContentState extends State<PasswordFlowContent> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SecondPasswordCubit, SecondPasswordState>(
      listenWhen: (previous, current) => previous.step != current.step,
      listener: (context, state) {
        if (_scroll.hasClients) _scroll.jumpTo(0);
      },
      builder: (context, state) {
        return state.isFullStatusVisible
            ? SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 36, 16, 20),
                child: PasswordStatusContent(record: state.record!),
              )
            : state.record != null
            ? const SizedBox.shrink()
            : SingleChildScrollView(
                controller: _scroll,

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
                  selectOperation: widget.selectOperation,
                  video: widget.video,
                  instructionVideoUrl: widget.instructionVideoUrl,
                ),
              );
      },
    );
  }
}
