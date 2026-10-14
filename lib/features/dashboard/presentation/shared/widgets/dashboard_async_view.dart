import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';

/// Feature composition of public primitives for asynchronous dashboard states.
class DashboardAsyncView extends StatelessWidget {
  const DashboardAsyncView({
    super.key,
    this.loading = false,
    this.emptyMessage,
    this.onRetry,
  });
  final bool loading;
  final String? emptyMessage;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            AppButton(
              onPressed: null,
              label: context.l10n.dashboardLoading,
              isLoading: true,
            )
          else
            Text(
              emptyMessage ?? context.l10n.dashboardLoadError,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            AppButton(
              key: const Key('dashboard_retry'),
              label: context.l10n.dashboardRetry,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    ),
  );
}
