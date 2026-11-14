import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/loan_application.dart';
import '../cubit/loan_request_cubit.dart';
import 'loan_request_labels.dart';
import 'loan_text_link.dart';

class LoanInquiries extends StatelessWidget {
  const LoanInquiries({super.key, required this.state});
  final LoanRequestState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          state.inquiryStatus == RequestStatus.loading
              ? S.current.loanRequestReviewing
              : S.current.loanRequestReviewed,
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        for (final inquiry in state.inquiries) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border.all(
                color: loanInquiryColor(
                  context,
                  inquiry.outcome,
                ).withValues(alpha: .3),
                width: .8,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AvpImage(
                      image: loanInquiryIcon(inquiry.outcome),
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loanInquiryLabel(inquiry.kind),
                        style: AppTypography.bodySmall.copyWith(
                          color: loanInquiryColor(context, inquiry.outcome),
                        ),
                      ),
                    ),
                    if (inquiry.outcome == LoanInquiryOutcome.rejected)
                      LoanTextLink(
                        label: S.current.dashboardRetry,
                        showArrow: false,
                        trailingIcon: const AvpImage(
                          image:
                              '${AppConstants.baseImage}loan_request_retry.svg',
                          width: 16,
                          height: 16,
                        ),
                        isActive: state.canRetryInquiries,
                        onPressed: context
                            .read<LoanRequestCubit>()
                            .fetchInquiries,
                      )
                    else
                      Text(
                        loanInquiryOutcomeLabel(inquiry.outcome),
                        style: AppTypography.labelSmall.copyWith(
                          color: loanInquiryColor(context, inquiry.outcome),
                        ),
                      ),
                  ],
                ),
                if (inquiry.outcome == LoanInquiryOutcome.rejected) ...[
                  const SizedBox(height: 10),
                  Divider(height: 1, color: context.colors.borderSubtle),
                  const SizedBox(height: 10),
                  Text(
                    S.current.loanRequestRejected,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
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

String loanInquiryOutcomeLabel(LoanInquiryOutcome outcome) => switch (outcome) {
  LoanInquiryOutcome.processing => S.current.loanRequestProcessing,
  LoanInquiryOutcome.approved => S.current.loanRequestApproved,
  LoanInquiryOutcome.rejected => S.current.loanRequestRejected,
};
String loanInquiryIcon(LoanInquiryOutcome outcome) => switch (outcome) {
  LoanInquiryOutcome.processing =>
    '${AppConstants.baseImage}loan_request_inquiry_processing.svg',
  LoanInquiryOutcome.approved =>
    '${AppConstants.baseImage}loan_request_inquiry_approved.svg',
  LoanInquiryOutcome.rejected =>
    '${AppConstants.baseImage}loan_request_inquiry_rejected.svg',
};
Color loanInquiryColor(BuildContext context, LoanInquiryOutcome outcome) =>
    switch (outcome) {
      LoanInquiryOutcome.processing => context.colors.textTertiary,
      LoanInquiryOutcome.approved => context.colors.success,
      LoanInquiryOutcome.rejected => context.colors.error,
    };
