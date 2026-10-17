import '../../home/cubit/home_cubit.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/dashboard_reso_cubit.dart';
import 'dashboard_reso_backdrop.dart';

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class DashboardResoBannerPanel extends StatefulWidget {
  const DashboardResoBannerPanel({
    super.key,
    this.focusNode,
    this.enableAnimations = true,
  });
  final FocusNode? focusNode;
  final bool enableAnimations;

  @override
  State<DashboardResoBannerPanel> createState() =>
      _DashboardResoBannerPanelState();
}

class _DashboardResoBannerPanelState extends State<DashboardResoBannerPanel>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // Both periods divide this duration, so controller repeats stay seamless.
  static const _motionCycle = Duration(seconds: 45);
  final _ownedFocus = FocusNode();
  late final AnimationController _glow;
  FocusNode get _focus => widget.focusNode ?? _ownedFocus;
  ImageStream? _textureStream;
  ImageStreamListener? _textureListener;
  final _texture = ValueNotifier<ui.Image?>(null);

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(vsync: this, duration: _motionCycle);
    _focus.addListener(_inputChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant DashboardResoBannerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocus).removeListener(_inputChanged);
      _focus.addListener(_inputChanged);
    }
    _syncMotion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<DashboardResoCubit>().configurePhrases([
      S.current.dashboardPromptHint,
      S.current.dashboardPromptCertificate,
      S.current.dashboardPromptCard,
    ]);
    _syncMotion();
    if (_textureStream != null) return;
    _textureStream = const AssetImage(AppAssets.dashboardTexture)
        .resolve(createLocalImageConfiguration(context));
    _textureListener = ImageStreamListener((info, _) {
      if (!mounted) return;
      _texture.value?.dispose();
      _texture.value = info.image.clone();
    });
    _textureStream!.addListener(_textureListener!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<DashboardResoCubit>().updateForeground(
      state == AppLifecycleState.resumed,
    );
    _syncMotion();
  }

  void _syncMotion() {
    if (!mounted) return;
    final enabled =
        widget.enableAnimations &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    context.read<DashboardResoCubit>().updateMotion(
      enabled: enabled,
      hasFocus: _focus.hasFocus,
    );
    if (context.read<DashboardResoCubit>().state.isMotionEnabled) {
      if (!_glow.isAnimating) _glow.repeat();
    } else {
      _glow.stop();
      _glow.value = 0;
    }
  }

  void _inputChanged() {
    _syncMotion();
  }

  void _submit() {
    context.read<DashboardResoCubit>().submitPrompt();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _glow.dispose();
    _focus.removeListener(_inputChanged);
    _ownedFocus.dispose();
    _textureStream?.removeListener(_textureListener!);
    _texture.value?.dispose();
    _texture.dispose();
    super.dispose();
  }

  double _captionHeight(BuildContext context, double width) {
    double measure(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.rtl,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: width);
      final height = painter.height;
      painter.dispose();
      return height;
    }

    return measure(
          S.current.dashboardResoTitle,
          AppTypography.titleSmall.copyWith(height: 20 / 14, letterSpacing: 0),
        ) +
        6 +
        measure(
          S.current.dashboardResoDescription,
          AppTypography.bodySmall.copyWith(height: 18 / 12, letterSpacing: 0),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardResoCubit, DashboardResoState>(
      listenWhen: (previous, current) =>
          previous.submissionId != current.submissionId,
      listener: (context, state) =>
          context.read<HomeCubit>().submitPrompt(state.submittedPrompt),
      buildWhen: (previous, current) =>
          previous.typedHint != current.typedHint ||
          previous.isMotionEnabled != current.isMotionEnabled ||
          previous.hasFocus != current.hasFocus ||
          previous.hasInput != current.hasInput ||
          previous.prompt != current.prompt ||
          previous.canSubmitPrompt != current.canSubmitPrompt,
      builder: (context, state) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderLg,
            boxShadow: AppShadows.sm,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.borderLg,
            child: ColoredBox(
              color: context.colors.surface,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scale = constraints.maxWidth / 343;
                  final extra = math.max(
                    0.0,
                    _captionHeight(context, 173 * scale) - 62,
                  );
                  return SizedBox(
                    height: 194 + extra,
                    child: Stack(
                      children: [
                        ValueListenableBuilder<ui.Image?>(
                          valueListenable: _texture,
                          builder: (context, texture, child) =>
                              DashboardResoBackdrop(
                                animation: _glow,
                                scale: scale,
                                texture: texture,
                              ),
                        ),
                        Positioned(
                          left: -20 * scale,
                          top: 7,
                          width: 217 * scale,
                          height: 122,
                          child: AvpImage(
                            image: AppAssets.dashboardReso,
                            fit: BoxFit.cover,
                            excludeFromSemantics: true,
                          ),
                        ),
                        Positioned(
                          right: 16,
                          top: 43,
                          width: 173 * scale,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                S.current.dashboardResoTitle,
                                textAlign: TextAlign.start,
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppDashboardColors.heroTitle,
                                  height: 20 / 14,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                S.current.dashboardResoDescription,
                                textAlign: TextAlign.justify,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppDashboardColors.heroSupporting,
                                  height: 18 / 12,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          top: 126 + extra,
                          child: AppTextField(
                            value: state.prompt,
                            onChanged: (value) {
                              context.read<DashboardResoCubit>().updatePrompt(
                                value,
                              );
                            },
                            textStyle: AppTypography.bodyMedium.copyWith(
                              height: 20 / 14,
                              letterSpacing: 0,
                            ),
                            onSubmitted: (_) => _submit(),
                            focusNode: _focus,
                            hintText:
                                state.isMotionEnabled &&
                                    !state.hasFocus &&
                                    !state.hasInput
                                ? state.typedHint
                                : S.current.dashboardPromptHint,
                            focusRing: AppTextFieldFocusRing.subtle,
                            textDirection: TextDirection.rtl,
                            textInputAction: TextInputAction.send,
                            suffixIcon: InkWell(
                              onTap: state.canSubmitPrompt ? _submit : null,
                              child: Semantics(
                                button: true,
                                label: S.current.dashboardSendPrompt,
                                child: SizedBox(
                                  width: 48,
                                  height: 44,
                                  child: Center(
                                    child: AvpImage(
                                      image: AppAssets.dashboardPromptArrow,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
