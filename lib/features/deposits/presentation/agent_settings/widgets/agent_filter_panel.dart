import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

/// Shared layout for the three option lists; the owning Cubit keeps the draft.
class AgentFilterPanel extends StatelessWidget {
  const AgentFilterPanel({
    super.key,
    required this.title,
    required this.options,
  });

  final String title;
  final List<Widget> options;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBottomSheetHeader(
          title: title,
          showLeftAction: false,
          showRightIcon: false,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: options),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: S.current.dashboardCancel,
                  variant: AppButtonVariant.secondaryGray,
                  size: AppButtonSize.lg,
                  onPressed: () => context.pop(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: S.current.cardFeatureApplyFilter,
                  size: AppButtonSize.lg,
                  onPressed: () => context.pop(true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
