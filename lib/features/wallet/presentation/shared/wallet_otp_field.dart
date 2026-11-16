import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import 'wallet_labels.dart';

class WalletOtpField extends StatelessWidget {
  const WalletOtpField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onRequest,
    required this.canRequest,
    required this.enabled,
    required this.isLoading,
    required this.remainingSeconds,
    required this.hasChallenge,
    this.codeLength = 4,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onRequest;
  final bool canRequest, enabled, isLoading, hasChallenge;
  final int remainingSeconds, codeLength;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.current.walletSecondPassword,
                style: certificateLabelStyle(context),
              ),
              const SizedBox(height: 8),
              AppTextField(
                value: value,
                hintText: S.current.walletOtpHint,
                onChanged: onChanged,
                enabled: enabled,
                normalizeDigits: true,
                maxLength: codeLength,
                keyboardType: TextInputType.number,
                autocorrect: false,
                enableSuggestions: false,
                enableIMEPersonalizedLearning: false,
                textStyle: certificateValueStyle(context),
                prefixIcon: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: AvpImage(
                      image: '${AppConstants.baseImage}profile_lock.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 35,
          child: remainingSeconds > 0
              ? SizedBox(
                  height: 44,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        walletCountdownLabel(remainingSeconds),
                        style: AppTypography.bodyMedium.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const AvpImage(
                        image: '${AppConstants.baseImage}auth_clock.svg',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                )
              : AppButton(
                  label: hasChallenge
                      ? S.current.walletResendOtp
                      : S.current.walletRequestOtp,
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.lg,
                  horizontalPadding: 0,
                  constrainLabel: true,
                  isActive: canRequest,
                  isLoading: isLoading,
                  onPressed: onRequest,
                ),
        ),
      ],
    );
  }
}
