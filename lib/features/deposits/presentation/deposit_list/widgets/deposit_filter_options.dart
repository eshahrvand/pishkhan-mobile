import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

class DepositFilterOptions extends StatelessWidget {
  const DepositFilterOptions({
    super.key,
    required this.title,
    required this.labels,
    required this.onSelected,
  });
  final String title;
  final List<String> labels;
  final void Function(BuildContext, int) onSelected;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBottomSheetHeader(
          title: title,
          showRightIcon: false,
          showLeftAction: false,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < labels.length; i++)
                AppButton(
                  label: labels[i],
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.lg,
                  onPressed: () => onSelected(context, i),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
