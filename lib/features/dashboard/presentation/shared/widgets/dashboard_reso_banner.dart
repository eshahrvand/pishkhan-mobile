import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

class DashboardResoBanner extends StatefulWidget {
  const DashboardResoBanner({
    super.key,
    this.onPromptSubmitted,
    this.focusNode,
    this.enableAnimations = true,
  });
  final ValueChanged<String>? onPromptSubmitted;
  final FocusNode? focusNode;
  final bool enableAnimations;

  @override
  State<DashboardResoBanner> createState() => _DashboardResoBannerState();
}

class _DashboardResoBannerState extends State<DashboardResoBanner>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _typingInterval = Duration(milliseconds: 90);
  static const _backgroundCycle = Duration(seconds: 9);
  final _controller = TextEditingController();
  final _ownedFocus = FocusNode();
  late final AnimationController _glow;
  FocusNode get _focus => widget.focusNode ?? _ownedFocus;
  Timer? _typingTimer;
  List<String> _phrases = [];
  String _typedHint = '';
  int _phraseIndex = 0, _position = 0, _holdTicks = 0;
  bool _erasing = false, _motionEnabled = false, _foreground = true;
  ImageStream? _textureStream;
  ImageStreamListener? _textureListener;
  ui.Image? _texture;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(vsync: this, duration: _backgroundCycle);
    _focus.addListener(_inputChanged);
    _controller.addListener(_inputChanged);
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
    _phrases = [
      context.l10n.dashboardPromptHint,
      context.l10n.dashboardPromptCertificate,
      context.l10n.dashboardPromptCard,
    ];
    _syncMotion();
    if (_textureStream != null) return;
    _textureStream = const AssetImage(AppAssets.dashboardTexture)
        .resolve(createLocalImageConfiguration(context));
    _textureListener = ImageStreamListener((info, _) {
      if (!mounted) return;
      setState(() {
        _texture?.dispose();
        _texture = info.image.clone();
      });
    });
    _textureStream!.addListener(_textureListener!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncMotion();
    if (mounted) setState(() {});
  }

  void _syncMotion() {
    if (!mounted || _phrases.isEmpty) return;
    _motionEnabled =
        widget.enableAnimations &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled &&
        _foreground;
    if (_motionEnabled) {
      if (!_glow.isAnimating) _glow.repeat();
    } else {
      _glow.stop();
      _glow.value = 0;
    }
    final canType =
        _motionEnabled && !_focus.hasFocus && _controller.text.isEmpty;
    if (canType) {
      _typingTimer ??= Timer.periodic(_typingInterval, (_) => _typeNext());
    } else {
      _typingTimer?.cancel();
      _typingTimer = null;
    }
  }

  void _inputChanged() {
    _syncMotion();
    if (mounted) setState(() {});
  }

  void _typeNext() {
    if (!mounted) return;
    if (_holdTicks > 0) {
      _holdTicks--;
      return;
    }
    final phrase = _phrases[_phraseIndex];
    final length = phrase.characters.length;
    if (_erasing) {
      _position--;
      if (_position <= 0) {
        _position = 0;
        _erasing = false;
        _phraseIndex = (_phraseIndex + 1) % _phrases.length;
        _holdTicks = 5;
      }
    } else {
      _position++;
      if (_position >= length) {
        _position = length;
        _erasing = true;
        _holdTicks = 24;
      }
    }
    setState(() => _typedHint = phrase.characters.take(_position).toString());
  }

  void _submit(String value) {
    final text = value.trim();
    if (text.isNotEmpty) widget.onPromptSubmitted?.call(text);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _typingTimer?.cancel();
    _glow.dispose();
    _focus.removeListener(_inputChanged);
    _ownedFocus.dispose();
    _textureStream?.removeListener(_textureListener!);
    _texture?.dispose();
    _controller.dispose();
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
          context.l10n.dashboardResoTitle,
          AppTypography.titleSmall.copyWith(height: 20 / 14, letterSpacing: 0),
        ) +
        6 +
        measure(
          context.l10n.dashboardResoDescription,
          AppTypography.bodySmall.copyWith(height: 18 / 12, letterSpacing: 0),
        );
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
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
              key: const Key('dashboard_reso_banner'),
              height: 194 + extra,
              child: Stack(
                children: [
                  _backdrop(context, scale),
                  Positioned(
                    key: const Key('dashboard_reso_foreground'),
                    left: -20 * scale,
                    top: 7,
                    width: 217 * scale,
                    height: 122,
                    child: Image.asset(
                      AppAssets.dashboardReso,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                  Positioned(
                    key: const Key('dashboard_reso_caption'),
                    right: 16,
                    top: 43,
                    width: 173 * scale,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.dashboardResoTitle,
                          textAlign: TextAlign.start,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppDashboardColors.heroTitle,
                            height: 20 / 14,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.dashboardResoDescription,
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
                      key: const Key('dashboard_assistant_prompt'),
                      controller: _controller,
                      textStyle: AppTypography.bodyMedium.copyWith(
                        height: 20 / 14,
                        letterSpacing: 0,
                      ),
                      onSubmitted: _submit,
                      focusNode: _focus,
                      hintText:
                          _motionEnabled &&
                              !_focus.hasFocus &&
                              _controller.text.isEmpty
                          ? _typedHint
                          : context.l10n.dashboardPromptHint,
                      focusRing: AppTextFieldFocusRing.subtle,
                      textDirection: TextDirection.rtl,
                      textInputAction: TextInputAction.send,
                      suffixIcon: InkWell(
                        key: const Key('dashboard_submit_prompt'),
                        onTap: () => _submit(_controller.text),
                        child: Semantics(
                          button: true,
                          label: context.l10n.dashboardSendPrompt,
                          child: SizedBox(
                            width: 48,
                            height: 44,
                            child: Center(
                              child: SvgPicture.asset(
                                AppAssets.dashboardPromptArrow,
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

  Widget _backdrop(BuildContext context, double scale) => Positioned.fill(
    child: RepaintBoundary(
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, _) {
          final phase = _glow.value * 2 * math.pi;
          final wave = (1 - math.cos(phase)) / 2;
          final gradient = AppGradients.fromAngle(
            angleInDegrees: 112.62564745992552,
            colors: [
              AppDashboardColors.heroHaze.withValues(alpha: .051),
              context.colors.primary.withValues(alpha: .461),
            ],
          );
          return IgnorePointer(
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    key: const Key('dashboard_reso_gradient'),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: gradient.begin,
                        end: gradient.end,
                        colors: gradient.colors,
                        stops: gradient.stops,
                        transform: _ResoGradientTranslation(
                          Offset(14 * wave * scale, 12 * wave),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_texture != null)
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(16 * wave * scale, -10 * wave),
                      child: CustomPaint(
                        painter: _ResoTexturePainter(_texture!),
                      ),
                    ),
                  ),
                Positioned(
                  key: const Key('dashboard_reso_overlay'),
                  left: (-12.9785 + 16 * wave) * scale,
                  top: -12.9785 - 10 * wave,
                  width: 368.957 * scale,
                  height: 219.957,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: .927, sigmaY: .927),
                      child: SvgPicture.asset(AppAssets.dashboardResoOverlay),
                    ),
                  ),
                ),
                Positioned(
                  key: const Key('dashboard_banner_glow_large'),
                  left: (-68.6 - 152.033 + 140 * wave) * scale,
                  top: -59.33 - 152.033 + 55 * wave,
                  width: 487.616 * scale,
                  height: 487.616 * scale,
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(
                      sigmaX: 76.0162,
                      sigmaY: 76.0162,
                    ),
                    child: SvgPicture.asset(AppAssets.dashboardGlowLarge),
                  ),
                ),
                Positioned(
                  key: const Key('dashboard_banner_glow_small'),
                  left: (218.78 - 57.4755 - 105 * wave) * scale,
                  top: 164.08 - 57.4755 - 72 * wave,
                  width: 213.216 * scale,
                  height: 213.216 * scale,
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(
                      sigmaX: 28.7378,
                      sigmaY: 28.7378,
                    ),
                    child: SvgPicture.asset(AppAssets.dashboardGlowSmall),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class _ResoTexturePainter extends CustomPainter {
  const _ResoTexturePainter(this.image);
  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(
      Offset.zero & size,
      Paint()
        ..blendMode = BlendMode.softLight
        ..imageFilter = ui.ImageFilter.blur(sigmaX: .927, sigmaY: .927),
    );
    canvas.translate(0, size.height);
    canvas.rotate(-math.pi / 2);
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, size.height, size.width),
      image: image,
      fit: BoxFit.cover,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ResoTexturePainter oldDelegate) =>
      image != oldDelegate.image;
}

/// Moves only the gradient shader; the full-card fill remains clipped in place.
class _ResoGradientTranslation extends GradientTransform {
  const _ResoGradientTranslation(this.offset);
  final Offset offset;
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(offset.dx, offset.dy, 0);
}
