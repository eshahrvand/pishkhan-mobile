import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/loan_application.dart';
import 'loan_request_labels.dart';
import 'loan_text_link.dart';

class LoanInquiryCard extends StatelessWidget {
  const LoanInquiryCard({
    super.key,
    required this.inquiry,
    required this.canRetry,
    required this.onRetry,
  });
  final LoanInquiry inquiry;
  final bool canRetry;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: .74,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: loanInquiryBackground(inquiry.outcome),
          border: Border.all(
            color: loanInquiryBorder(inquiry.outcome),
            width: .8,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
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
                      isActive: canRetry,
                      onPressed: onRetry,
                    )
                  else
                    Text(
                      loanInquiryOutcomeLabel(inquiry.outcome),
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w400,
                        color: inquiry.outcome == LoanInquiryOutcome.approved
                            ? AppPalette.success800
                            : AppPalette.gray600,
                      ),
                    ),
                ],
              ),
              if (inquiry.outcome == LoanInquiryOutcome.rejected) ...[
                const SizedBox(height: 10),
                Divider(height: 0, thickness: .8, color: AppPalette.gray200),
                const SizedBox(height: 10),
                Text(
                  S.current.loanRequestRejected,
                  textAlign: TextAlign.justify,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppPalette.gray700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
      LoanInquiryOutcome.processing => context.colors.textPrimary,
      LoanInquiryOutcome.approved => AppPalette.success600,
      LoanInquiryOutcome.rejected => AppPalette.error600,
    };

Color loanInquiryBackground(LoanInquiryOutcome outcome) => switch (outcome) {
  LoanInquiryOutcome.processing => AppPalette.gray50,
  LoanInquiryOutcome.approved => AppPalette.success25,
  LoanInquiryOutcome.rejected => AppPalette.error25,
};

Color loanInquiryBorder(LoanInquiryOutcome outcome) => switch (outcome) {
  LoanInquiryOutcome.processing => AppPalette.gray200,
  LoanInquiryOutcome.approved => AppPalette.success200,
  LoanInquiryOutcome.rejected => AppPalette.error200,
};
