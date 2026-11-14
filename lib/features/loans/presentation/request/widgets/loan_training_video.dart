import 'dart:ui';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class LoanTrainingVideo extends StatefulWidget {
  const LoanTrainingVideo({super.key, this.url});
  final String? url;
  @override
  State<LoanTrainingVideo> createState() {
    return _LoanTrainingVideoState();
  }
}

class _LoanTrainingVideoState extends State<LoanTrainingVideo> {
  VideoPlayerController? _controller;
  @override
  void initState() {
    super.initState();
    if (widget.url != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url!));
    }
  }

  @override
  void didUpdateWidget(LoanTrainingVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _controller?.dispose();
      _controller = widget.url == null
          ? null
          : VideoPlayerController.networkUrl(Uri.parse(widget.url!));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppVideoPlayer(
      controller: _controller,
      aspectRatio: 343 / 189,
      poster: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: const AvpImage(
              image: '${AppConstants.baseImage}loan_request_video_poster.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: const AvpImage(
              image: '${AppConstants.baseImage}modern_video_play.svg',
              width: 64,
              height: 64,
            ),
          ),
        ],
      ),
      playLabel: S.current.passwordPlay,
      pauseLabel: S.current.passwordPause,
      unavailableLabel: S.current.passwordVideoUnavailable,
      retryLabel: S.current.dashboardRetry,
      seekLabel: S.current.passwordSeek,
    );
  }
}
