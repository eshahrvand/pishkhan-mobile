import 'package:pishkhan_mobile/core/config/constant.dart';

import '../../home/cubit/home_cubit.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_reso_backdrop.dart';

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class DashboardResoBanner extends StatefulWidget {
  const DashboardResoBanner({
    super.key,
    this.focusNode,
    this.enableAnimations = true,
  });
  final FocusNode? focusNode;
  final bool enableAnimations;

  @override
  State<DashboardResoBanner> createState() => _DashboardResoBannerState();
}

class _DashboardResoBannerState extends State<DashboardResoBanner>
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
  void didUpdateWidget(covariant DashboardResoBanner oldWidget) {
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
    context.read<HomeCubit>().updateHintPhrases([
      S.current.dashboardPromptHint,
      S.current.dashboardPromptCertificate,
      S.current.dashboardPromptCard,
    ]);
    _syncMotion();
    if (_textureStream != null) return;
    _textureStream = const AssetImage(
      '${AppConstants.baseImage}dashboard_texture.png',
    ).resolve(createLocalImageConfiguration(context));
    _textureListener = ImageStreamListener((info, _) {
      if (!mounted) return;
      _texture.value?.dispose();
      _texture.value = info.image.clone();
    });
    _textureStream!.addListener(_textureListener!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<HomeCubit>().updateForeground(
      state == AppLifecycleState.resumed,
    );
    _syncMotion();
  }

  void _syncMotion() {
    if (!mounted) return;
    context.read<HomeCubit>().updateMotion(
      enabled: widget.enableAnimations,
      animationsDisabled: MediaQuery.disableAnimationsOf(context),
      tickerEnabled: TickerMode.valuesOf(context).enabled,
      hasFocus: _focus.hasFocus,
    );
    if (context.read<HomeCubit>().state.isMotionEnabled) {
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
    context.read<HomeCubit>().submitPrompt();
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
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.typedHint != current.typedHint ||
          previous.prompt != current.prompt ||
          previous.isHintTyping != current.isHintTyping,
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
                            image:
                                '${AppConstants.baseImage}dashboard_reso.png',
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
                              context.read<HomeCubit>().updatePrompt(value);
                            },
                            textStyle: AppTypography.bodyMedium.copyWith(
                              height: 20 / 14,
                              letterSpacing: 0,
                            ),
                            onSubmitted: state.canSubmitPrompt
                                ? (_) => _submit()
                                : null,
                            focusNode: _focus,
                            hintText: state.isHintTyping
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
                                      image:
                                          '${AppConstants.baseImage}dashboard_prompt_arrow.svg',
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
