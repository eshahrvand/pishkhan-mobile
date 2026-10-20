import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/request_reports_cubit.dart';

/// Shared Apply/Cancel controls for the three report filter sheets.
class ReportFilterFooter extends StatelessWidget {
  const ReportFilterFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: S.current.dashboardCancel,
              variant: AppButtonVariant.secondaryGray,
              size: AppButtonSize.lg,
              constrainLabel: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label: S.current.reportApplyFilter,
              size: AppButtonSize.lg,
              constrainLabel: true,
              onPressed: () {
                context.read<RequestReportsCubit>().applyFilter();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
