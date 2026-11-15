import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

class LoanInformationSheet extends StatelessWidget {
  const LoanInformationSheet({
    super.key,
    required this.title,
    required this.body,
  });
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppBottomSheetHeader(
          showTitle: false,
          showRightIcon: false,
          onLeftAction: () {
            Navigator.of(context).pop();
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  color: AppPalette.gray700,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                body.replaceAll('\n\n', '\n'),
                style: AppTypography.bodyMedium.copyWith(
                  height: 24 / 14,
                  color: AppPalette.gray600,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
