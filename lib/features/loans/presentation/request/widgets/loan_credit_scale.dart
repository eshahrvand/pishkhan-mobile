import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';

import '../../../domain/entities/loan_application.dart';
import '../../../domain/entities/loan_credit_assessment.dart';
import 'loan_request_labels.dart';
import 'loan_money.dart';

class LoanCreditScale extends StatelessWidget {
  const LoanCreditScale({
    super.key,
    required this.assessment,
    required this.tier,
  });
  final LoanCreditAssessment assessment;
  final LoanCreditTier tier;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          Row(
            children: [
              for (final band in assessment.creditBands)
                Expanded(
                  child: Text(
                    loanAssessmentRangeLabel(tier, band),
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      color: assessment.range == band
                          ? context.colors.textPrimary
                          : context.colors.textTertiary,
                      fontWeight: assessment.range == band
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: 8,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.borderFull,
                      child: SizedBox(
                        height: 8,
                        child: Row(
                          children: [
                            for (final band in assessment.creditBands)
                              Expanded(
                                child: AvpImage(
                                  image: _loanCreditBandStyle(
                                    assessment,
                                    band,
                                  ).asset,
                                  backgroundColor: _loanCreditBandStyle(
                                    assessment,
                                    band,
                                  ).background,
                                  height: 8,
                                  fit: BoxFit.fill,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (assessment.range != LoanCreditRange.unsuitable)
                      Positioned(
                        left: (constraints.maxWidth * assessment.creditPosition)
                            .clamp(0, constraints.maxWidth - 4),
                        top: -8,
                        child: Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: context.colors.textPrimary,
                            borderRadius: AppRadius.borderFull,
                            boxShadow: AppShadows.cardList,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final boundary in assessment.creditBoundaries)
                LoanMoney(
                  amountRial: boundary,
                  fontSize: 10,
                  color: AppPalette.gray600,
                  fontWeight: FontWeight.w400,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// The source artwork is preserved. Its exact flat fill is also the loading
// background, so changing a range never flashes an empty band during SVG I/O.
({String asset, Color background}) _loanCreditBandStyle(
  LoanCreditAssessment assessment,
  LoanCreditRange band,
) {
  if (assessment.range == LoanCreditRange.unsuitable) {
    return (
      asset: '${AppConstants.baseImage}loan_request_band_error.svg',
      background: AppPalette.error100,
    );
  }
  if (assessment.range != band) {
    return (
      asset: '${AppConstants.baseImage}loan_request_band_inactive.svg',
      background: AppPalette.gray200,
    );
  }
  return switch (band) {
    LoanCreditRange.fullySuitable => (
      asset: '${AppConstants.baseImage}loan_request_band_fully.svg',
      background: AppPalette.brand400,
    ),
    LoanCreditRange.suitable => (
      asset: '${AppConstants.baseImage}loan_request_band_suitable.svg',
      background: AppPalette.brand200,
    ),
    _ => (
      asset: '${AppConstants.baseImage}loan_request_band_active.svg',
      background: AppPalette.brand600,
    ),
  };
}
