import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

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
    SvgPicture.asset(asset, width: size, height: size);

String cardDepositLabel(BuildContext context, CardServiceDeposit deposit) =>
    switch (deposit.kind) {
      CardDepositKind.qarz => context.l10n.cardServiceQarzDeposit,
      CardDepositKind.current => context.l10n.cardServiceCurrentDeposit,
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
  Widget build(BuildContext context) => Container(
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
                  label: context.l10n.issuanceTerms,
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
                                  context.l10n.issuanceTermsUnavailable,
                                ),
                              ),
                            ),
                        child: Text(
                          context.l10n.issuanceTerms,
                          style: cardServiceSmall(
                            context,
                            color: context.colors.primaryHover,
                            medium: true,
                          ).copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                      Text(
                        context.l10n.issuanceTermsPrompt,
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
    final l = context.l10n;
    if (status == RequestStatus.initial || status == RequestStatus.loading) {
      return Center(
        child: AppButton(
          label: l.dashboardLoading,
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
                        ? l.cardServiceMockComplete
                        : l.cardServiceComplete)
                  : empty
                  ? l.cardServiceEmpty
                  : l.dashboardLoadError,
              textAlign: TextAlign.center,
            ),
            if (receipt != null) ...[
              const SizedBox(height: 16),
              Text(receipt!.reference, textDirection: TextDirection.ltr),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: receipt != null ? l.issuanceDone : l.dashboardRetry,
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
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 0,
    child: OverflowBox(
      minHeight: 1,
      maxHeight: 1,
      child: SvgPicture.asset(AppAssets.issuanceDivider, fit: BoxFit.fill),
    ),
  );
}

class CardServiceRowDivider extends StatelessWidget {
  const CardServiceRowDivider({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 0,
    child: OverflowBox(
      minHeight: .5,
      maxHeight: .5,
      child: SvgPicture.asset(AppAssets.cardFeaturesDivider, fit: BoxFit.fill),
    ),
  );
}
