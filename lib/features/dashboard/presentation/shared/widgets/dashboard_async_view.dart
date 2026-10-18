import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

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
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              AppButton(
                onPressed: null,
                label: S.current.dashboardLoading,
                isLoading: true,
              )
            else
              Text(
                emptyMessage ?? S.current.dashboardLoadError,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              AppButton(label: S.current.dashboardRetry, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
