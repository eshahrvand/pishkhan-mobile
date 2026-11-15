import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/loan_request_cubit.dart';
import 'loan_value_row.dart';
import 'loan_money.dart';

class LoanCompletedRequestCard extends StatelessWidget {
  const LoanCompletedRequestCard({super.key, required this.state});
  final LoanRequestState state;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.borderSubtle),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.xs,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppPalette.warning50,
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              children: [
                const AvpImage(
                  image: '${AppConstants.baseImage}loan_request_ready.svg',
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    S.current.loanRequestReady,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppPalette.warning700,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: AppButton(
                    icon: const RotatedBox(
                      quarterTurns: 1,
                      child: AvpImage(
                        image: '${AppConstants.baseImage}loan_request_more.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                    semanticLabel: S.current.loanRequestDetails,
                    variant: AppButtonVariant.text,
                    horizontalPadding: 0,
                    onPressed: context
                        .read<LoanRequestCubit>()
                        .requestUnavailable,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          LoanValueRow(
            height: 22,
            valueFontSize: 12,
            label: S.current.loanRequestRequestDate,
            value: JalaliDateFormatter.format(
              state.catalog!.latestRecord!.createdAt,
            ),
            valueDirection: TextDirection.ltr,
            bordered: false,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const SizedBox(height: 8),
          LoanValueRow(
            height: 22,
            valueFontSize: 12,
            label: S.current.loanRequestRequestNumber,
            valueContent: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.ltr,
              children: [
                Flexible(
                  child: Text(
                    state.catalog!.latestRecord!.id,
                    textDirection: TextDirection.ltr,
                    style: AppTypography.labelMedium.copyWith(letterSpacing: 0),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: context
                      .read<LoanRequestCubit>()
                      .requestCopyRequestNumber,
                  child: const AvpImage(
                    image: '${AppConstants.baseImage}loan_request_copy.svg',
                    width: 14,
                    height: 14,
                  ),
                ),
              ],
            ),
            bordered: false,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const SizedBox(height: 8),
          LoanValueRow(
            height: 22,
            valueFontSize: 12,
            label: S.current.depositListNumber,
            value: state.catalog!.latestRecord!.depositNumber,
            valueDirection: TextDirection.ltr,
            bordered: false,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const SizedBox(height: 8),
          LoanValueRow(
            height: 22,
            valueFontSize: 12,
            label: S.current.loanRequestAmount,
            valueContent: LoanMoney(
              amountRial: state.catalog!.latestRecord!.amountRial,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            bordered: false,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ],
      ),
    );
  }
}
