import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/loan_application.dart';
import '../cubit/loan_request_cubit.dart';
import 'loan_request_labels.dart';
import 'loan_text_link.dart';

class LoanCollateralNotice extends StatelessWidget {
  const LoanCollateralNotice({super.key, required this.quote});
  final LoanQuote quote;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AvpImage(
            image: '${AppConstants.baseImage}loan_request_info.svg',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: S.current.loanRequestCollateralBefore),
                      TextSpan(
                        text: loanMoney(quote.collateralRial),
                        style: TextStyle(
                          color: context.colors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: S.current.loanRequestCollateralAfter),
                    ],
                  ),
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                Text(
                  quote.needsGuarantor
                      ? S.current.loanRequestGuarantorDetails
                      : S.current.loanRequestOwnDetails,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                LoanTextLink(
                  label: S.current.loanRequestIcup,
                  showArrow: false,
                  onPressed: context
                      .read<LoanRequestCubit>()
                      .requestUnavailable,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
