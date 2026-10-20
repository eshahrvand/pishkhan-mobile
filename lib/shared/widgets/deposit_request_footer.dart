import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import 'certificate_fields.dart';

class DepositRequestFooter extends StatelessWidget {
  const DepositRequestFooter({
    super.key,
    required this.termsAccepted,
    required this.onTermsChanged,
    required this.onTermsRequested,
    required this.onSubmit,
    required this.isLoading,
    this.errorText,
    this.submitLabel,
    this.bottomPadding = 20,
  });
  final bool termsAccepted;
  final ValueChanged<bool>? onTermsChanged;
  final VoidCallback onTermsRequested;
  final VoidCallback? onSubmit;
  final bool isLoading;
  final String? errorText;
  final String? submitLabel;
  final double bottomPadding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              children: [
                AppCheckbox(
                  value: termsAccepted,
                  size: AppCheckboxSize.md,
                  onChanged: onTermsChanged,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    children: [
                      InkWell(
                        onTap: onTermsRequested,
                        child: Text(
                          S.current.issuanceTerms,
                          style: certificateLabelStyle(context).copyWith(
                            color: context.colors.primaryHover,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        ' ${S.current.issuanceTermsPrompt}',
                        style: certificateLabelStyle(context).copyWith(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (errorText != null) ...[
            Text(
              errorText!,
              style: certificateLabelStyle(context)
                  .copyWith(color: context.colors.error),
            ),
            const SizedBox(height: 8),
          ],
          AppButton(
            label: submitLabel ?? S.current.issuanceSubmit,
            size: AppButtonSize.lg,
            constrainLabel: true,
            disabledAppearance: AppButtonDisabledAppearance.service,
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
