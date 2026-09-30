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
  });
  final ValueChanged<String>? onPromptSubmitted;
  final FocusNode? focusNode;

  @override
  State<DashboardResoBanner> createState() => _DashboardResoBannerState();
}

class _DashboardResoBannerState extends State<DashboardResoBanner> {
  final _controller = TextEditingController();
  ImageStream? _textureStream;
  ImageStreamListener? _textureListener;
  ui.Image? _texture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_textureStream != null) {
      return;
    }
    _textureStream = const AssetImage(AppAssets.dashboardTexture)
        .resolve(createLocalImageConfiguration(context));
    _textureListener = ImageStreamListener((info, _) {
      if (!mounted) {
        return;
      }
      setState(() {
        _texture?.dispose();
        _texture = info.image.clone();
      });
    });
    _textureStream!.addListener(_textureListener!);
  }

  void _submit(String value) {
    final text = value.trim();
    if (text.isNotEmpty) {
      widget.onPromptSubmitted?.call(text);
    }
  }

  @override
  void dispose() {
    _textureStream?.removeListener(_textureListener!);
    _texture?.dispose();
    _controller.dispose();
    super.dispose();
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
        child: SizedBox(
          key: const Key('dashboard_reso_banner'),
          height: 194,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final scale = constraints.maxWidth / 343;
              return Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppPalette.brand200.withValues(alpha: .051),
                            context.colors.primary.withValues(alpha: .461),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_texture != null)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ResoTexturePainter(_texture!),
                      ),
                    ),
                  Positioned(
                    left: (-68.6 - 152.033) * scale,
                    top: -59.33 - 152.033,
                    width: 487.616 * scale,
                    height: 487.616,
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: 76.0162,
                        sigmaY: 76.0162,
                      ),
                      child: SvgPicture.asset(AppAssets.dashboardGlowLarge),
                    ),
                  ),
                  Positioned(
                    left: (218.78 - 57.4755) * scale,
                    top: 164.08 - 57.4755,
                    width: 213.216 * scale,
                    height: 213.216,
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: 28.7378,
                        sigmaY: 28.7378,
                      ),
                      child: SvgPicture.asset(AppAssets.dashboardGlowSmall),
                    ),
                  ),
                  Positioned.fill(
                    child: ColoredBox(
                      color: context.colors.surface.withValues(alpha: .01),
                    ),
                  ),
                  Positioned(
                    left: -20 * scale,
                    top: 7,
                    width: 217 * scale,
                    height: 122,
                    child: Image.asset(
                      AppAssets.dashboardReso,
                      fit: BoxFit.cover,
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
                          context.l10n.dashboardResoTitle,
                          textAlign: TextAlign.start,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppPalette.brand900,
                            height: 20 / 14,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.dashboardResoDescription,
                          textAlign: TextAlign.justify,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppPalette.gray600,
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
                    top: 126,
                    child: AppTextField(
                      key: const Key('dashboard_assistant_prompt'),
                      controller: _controller,
                      textStyle: AppTypography.bodyMedium.copyWith(
                        height: 20 / 14,
                        letterSpacing: 0,
                      ),
                      onSubmitted: _submit,
                      focusNode: widget.focusNode,
                      hintText: context.l10n.dashboardPromptHint,
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
                              child: SizedBox.square(
                                dimension: 20,
                                child: SvgPicture.asset(
                                  AppAssets.dashboardPromptArrow,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
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
