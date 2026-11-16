import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../../domain/entities/loan_application.dart';

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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              const AvpImage(
                image: '${AppConstants.baseImage}loan_request_success.svg',
                width: 64,
                height: 64,
              ),
              const SizedBox(height: 20),
              Text(
                S.current.loanRequestSuccess,
                textAlign: TextAlign.justify,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.border, width: .8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        S.current.loanRequestTracking,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppPalette.gray600,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Text(
                      record.id,
                      textDirection: TextDirection.ltr,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppPalette.gray800,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: S.current.passwordUnderstood,
                size: AppButtonSize.lg,
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
