import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../../domain/entities/loan_application.dart';
import 'loan_value_row.dart';

class LoanReceiptSheet extends StatelessWidget {
  const LoanReceiptSheet({super.key, required this.record});
  final LoanRecord record;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppBottomSheetHeader(type: AppBottomSheetHeaderType.handleOnly),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const AvpImage(
                image: '${AppConstants.baseImage}loan_request_success.svg',
                width: 64,
                height: 64,
              ),
              const SizedBox(height: 24),
              Text(
                S.current.loanRequestSuccess,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              LoanValueRow(
                label: S.current.loanRequestTracking,
                value: record.id,
                valueDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: S.current.passwordUnderstood,
                variant: AppButtonVariant.secondaryGray,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
