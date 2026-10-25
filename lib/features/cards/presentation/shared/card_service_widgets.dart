import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../domain/entities/card_service_data.dart';

TextStyle cardServiceSmall(
  BuildContext context, {
  Color? color,
  bool medium = false,
}) => AppTypography.bodySmall.copyWith(
  height: 18 / 12,
  letterSpacing: 0,
  color: color ?? context.colors.textSecondary,
  fontWeight: medium ? FontWeight.w500 : FontWeight.w400,
);

Widget cardServiceIcon(String asset, {double size = 20}) =>
    AvpImage(image: asset, width: size, height: size);

String cardDepositLabel(CardServiceDeposit deposit) => switch (deposit.kind) {
  CardDepositKind.qarz => S.current.cardServiceQarzDeposit,
  CardDepositKind.current => S.current.cardServiceCurrentDeposit,
};

/// Shared request footer for the two card-service forms.
class CardServiceFooter extends StatelessWidget {
  const CardServiceFooter({
    super.key,
    required this.label,
    required this.onSubmit,
    required this.loading,
    this.termsAccepted,
    this.onTermsChanged,
    this.onTermsRequested,
    this.termsSpacing = 16,
  });
  final String label;
  final VoidCallback? onSubmit, onTermsRequested;
  final bool loading;
  final double termsSpacing;
  final bool? termsAccepted;
  final ValueChanged<bool>? onTermsChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surfaceSubtle,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (termsAccepted != null) ...[
            Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Semantics(
                    label: S.current.issuanceTerms,
                    child: AppCheckbox(
                      value: termsAccepted!,
                      size: AppCheckboxSize.md,
                      onChanged: loading ? null : onTermsChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 2,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap:
                              onTermsRequested ??
                              () => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    S.current.issuanceTermsUnavailable,
                                  ),
                                ),
                              ),
                          child: Text(
                            S.current.issuanceTerms,
                            style: cardServiceSmall(
                              context,
                              color: context.colors.primaryHover,
                              medium: true,
                            ).copyWith(decoration: TextDecoration.underline),
                          ),
                        ),
                        Text(
                          S.current.issuanceTermsPrompt,
                          style: cardServiceSmall(
                            context,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: termsSpacing),
          ],
          AppButton(
            size: AppButtonSize.lg,
            constrainLabel: true,
            disabledAppearance: AppButtonDisabledAppearance.service,
            label: label,
            isLoading: loading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

/// Loading, empty, failure and completion states share their request actions.
class CardServiceStatus extends StatelessWidget {
  const CardServiceStatus({
    super.key,
    required this.status,
    required this.empty,
    required this.onRetry,
    this.receipt,
  });
  final RequestStatus status;
  final bool empty;
  final VoidCallback onRetry;
  final CardServiceReceipt? receipt;
  @override
  Widget build(BuildContext context) {
    if (status == RequestStatus.initial || status == RequestStatus.loading) {
      return Center(
        child: AppButton(
          label: S.current.dashboardLoading,
          onPressed: null,
          isLoading: true,
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              receipt != null
                  ? (receipt!.isMock
                        ? S.current.cardServiceMockComplete
                        : S.current.cardServiceComplete)
                  : empty
                  ? S.current.cardServiceEmpty
                  : S.current.dashboardLoadError,
              textAlign: TextAlign.center,
            ),
            if (receipt != null) ...[
              const SizedBox(height: 16),
              Text(receipt!.reference, textDirection: TextDirection.ltr),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: receipt != null
                  ? S.current.issuanceDone
                  : S.current.dashboardRetry,
              onPressed: receipt != null
                  ? () => NavigationActions.returnHome(context)
                  : onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class CardServiceDivider extends StatelessWidget {
  const CardServiceDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 0,
      child: OverflowBox(
        minHeight: 1,
        maxHeight: 1,
        child: AvpImage(
          image: '${AppConstants.baseImage}issuance_divider.svg',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

class CardServiceRowDivider extends StatelessWidget {
  const CardServiceRowDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 0,
      child: OverflowBox(
        minHeight: .5,
        maxHeight: .5,
        child: AvpImage(
          image: '${AppConstants.baseImage}card_features_divider.svg',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
