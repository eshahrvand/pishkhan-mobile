import 'package:pishkhan_mobile/core/config/constant.dart';

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class DashboardResoBackdrop extends StatelessWidget {
  const DashboardResoBackdrop({
    super.key,
    required this.animation,
    required this.scale,
    required this.texture,
  });
  final Animation<double> animation;
  final double scale;
  final ui.Image? texture;
  static const _motionCycle = Duration(seconds: 45);
  static const _backgroundCycle = Duration(seconds: 9);
  static const _circleCycle = Duration(milliseconds: 7500);
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final elapsed = animation.value * _motionCycle.inMilliseconds;
            final phase =
                elapsed / _backgroundCycle.inMilliseconds * 2 * math.pi;
            final circlePhase =
                elapsed / _circleCycle.inMilliseconds * 2 * math.pi;
            final circleWave = (1 - math.cos(circlePhase)) / 2;
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
                  if (texture != null)
                    Positioned.fill(
                      child: Transform.translate(
                        offset: Offset(16 * wave * scale, -10 * wave),
                        child: CustomPaint(
                          painter: _ResoTexturePainter(texture!),
                        ),
                      ),
                    ),
                  Positioned(
                    left: (-12.9785 + 16 * wave) * scale,
                    top: -12.9785 - 10 * wave,
                    width: 368.957 * scale,
                    height: 219.957,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: .927, sigmaY: .927),
                        child: AvpImage(
                          image:
                              '${AppConstants.baseImage}dashboard_reso_overlay.svg',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (-68.6 - 152.033 + 175 * circleWave) * scale,
                    top: -59.33 - 152.033 + 55 * circleWave,
                    width: 487.616 * scale,
                    height: 487.616 * scale,
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: 76.0162,
                        sigmaY: 76.0162,
                      ),
                      child: AvpImage(
                        image:
                            '${AppConstants.baseImage}dashboard_glow_large.svg',
                      ),
                    ),
                  ),
                  Positioned(
                    left: (218.78 - 57.4755 - 105 * circleWave) * scale,
                    top: 164.08 - 57.4755 - 72 * circleWave,
                    width: 213.216 * scale,
                    height: 213.216 * scale,
                    child: ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: 28.7378,
                        sigmaY: 28.7378,
                      ),
                      child: AvpImage(
                        image:
                            '${AppConstants.baseImage}dashboard_glow_small.svg',
                      ),
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
