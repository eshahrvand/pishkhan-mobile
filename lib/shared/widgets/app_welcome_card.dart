import 'dart:ui';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Translucent welcome card with the two-part Figma timer.
class AppWelcomeCard extends StatelessWidget {
  const AppWelcomeCard({
    super.key,
    this.greeting = 'مانی عزیز، صبح بخیر',
    this.message = 'به پیشخوان مجازی رسالت خوش آمدید',
    this.minutes = '11',
    this.seconds = '00',
  });

  final String greeting;
  final String message;
  final String minutes;
  final String seconds;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        key: const Key('app_welcome_card'),
        width: 343,
        height: 88,
        child: ClipRRect(
          borderRadius: AppRadius.borderLg,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.surface.withValues(alpha: .6),
                borderRadius: AppRadius.borderLg,
              ),
              foregroundDecoration: BoxDecoration(
                border: Border.all(
                  color: context.colors.surface.withValues(alpha: .8),
                ),
                borderRadius: AppRadius.borderLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 20,
                    child: Text(
                      greeting,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.clip,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppPalette.gray800,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 28,
                    child: Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        _Timer(minutes: minutes, seconds: seconds),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              message,
                              maxLines: 1,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppPalette.gray600,
                                height: 18 / 12,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Timer extends StatelessWidget {
  const _Timer({required this.minutes, required this.seconds});

  final String minutes;
  final String seconds;

  @override
  Widget build(BuildContext context) => Row(
    key: const Key('app_welcome_timer'),
    mainAxisSize: MainAxisSize.min,
    textDirection: TextDirection.ltr,
    children: [
      _TimerNumber(minutes),
      const SizedBox(width: 4),
      SizedBox(
        width: 2,
        height: 6,
        child: SvgPicture.asset(
          'assets/images/welcome_card/timer_separator.svg',
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(width: 4),
      _TimerNumber(seconds),
    ],
  );
}

class _TimerNumber extends StatelessWidget {
  const _TimerNumber(this.value);
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    width: 28,
    height: 28,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: AppPalette.orange200,
      borderRadius: AppRadius.borderXs,
    ),
    child: Text(
      value,
      style: AppTypography.bodySmall.copyWith(
        color: AppPalette.gray800,
        fontWeight: FontWeight.w600,
        height: 18 / 12,
        letterSpacing: 0,
      ),
    ),
  );
}
