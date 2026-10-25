import 'package:pishkhan_mobile/core/config/constant.dart';

import 'dart:ui';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

/// Owns the optional training controller; it never starts camera capture.
class ModernBankVideo extends StatefulWidget {
  const ModernBankVideo({
    super.key,
    required this.poster,
    this.url,
    this.isIntroduction = false,
  });
  final String poster;
  final String? url;
  final bool isIntroduction;
  @override
  State<ModernBankVideo> createState() => _ModernBankVideoState();
}

class _ModernBankVideoState extends State<ModernBankVideo> {
  VideoPlayerController? _controller;
  @override
  void initState() {
    super.initState();
    if (widget.url != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url!));
    }
  }

  @override
  void didUpdateWidget(ModernBankVideo oldWidget) {
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
            child: AvpImage(
              image: widget.poster,
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
            ),
          ),
          ColoredBox(
            color: context.colors.textSecondary.withValues(
              alpha: widget.isIntroduction ? .32 : .08,
            ),
          ),
          ColoredBox(color: context.colors.surface.withValues(alpha: .14)),
          if (widget.isIntroduction)
            Positioned(
              right: 0,
              top: 100,
              width: 160,
              height: 52,
              child: AvpImage(
                image: '${AppConstants.baseImage}modern_intro_title.svg',
              ),
            ),
          Center(
            child: SizedBox.square(
              dimension: 64,
              child: AvpImage(
                image: '${AppConstants.baseImage}modern_video_play.svg',
              ),
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
