import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/loan_request_cubit.dart';
import 'loan_inquiry_card.dart';

class LoanInquiries extends StatelessWidget {
  const LoanInquiries({super.key, required this.state});
  final LoanRequestState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                state.inquiryStatus == RequestStatus.loading
                    ? S.current.loanRequestReviewing
                    : S.current.loanRequestReviewed,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: state.inquiryStatus == RequestStatus.loading
                      ? FontWeight.w300
                      : FontWeight.w600,
                  color: state.inquiryStatus == RequestStatus.loading
                      ? AppPalette.gray400
                      : AppPalette.gray700,
                  letterSpacing: 0,
                ),
              ),
            ),
            if (state.inquiryStatus == RequestStatus.loading) ...[
              const SizedBox(width: 4),
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  // Static waveform heights from the Figma inquiry heading.
                  for (final height in const [
                    2.0,
                    2.0,
                    2.0,
                    6.0,
                    12.0,
                    4.0,
                    10.0,
                    4.0,
                    6.0,
                    2.0,
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Container(
                        width: 2,
                        height: height,
                        decoration: BoxDecoration(
                          color: AppPalette.gray400,
                          borderRadius: AppRadius.borderFull,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        for (final inquiry in state.inquiries) ...[
          LoanInquiryCard(
            inquiry: inquiry,
            canRetry: state.canRetryInquiries,
            onRetry: context.read<LoanRequestCubit>().fetchInquiries,
          ),
          const SizedBox(height: 12),
        ],
        if (state.inquiryStatus == RequestStatus.failure)
          AppButton(
            label: S.current.dashboardRetry,
            onPressed: context.read<LoanRequestCubit>().fetchInquiries,
          ),
      ],
    );
  }
}
