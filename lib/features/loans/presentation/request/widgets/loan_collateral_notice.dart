import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/loan_application.dart';
import '../cubit/loan_request_cubit.dart';
import 'loan_request_labels.dart';

class LoanCollateralNotice extends StatelessWidget {
  const LoanCollateralNotice({super.key, required this.quote});
  final LoanQuote quote;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: S.current.loanRequestCollateralBefore),
                  TextSpan(
                    text: loanMoney(quote.collateralRial),
                    style: AppTypography.bodySmall.copyWith(
                      color: context.colors.warning,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                  TextSpan(text: S.current.loanRequestCollateralAfter),
                  const TextSpan(text: '\n'),
                  TextSpan(text: S.current.loanRequestIcupBefore),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: InkWell(
                      onTap: context
                          .read<LoanRequestCubit>()
                          .requestUnavailable,
                      child: Text(
                        S.current.loanRequestIcup,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                          decoration: TextDecoration.underline,
                          decorationColor: context.colors.primary,
                        ),
                      ),
                    ),
                  ),
                  TextSpan(text: S.current.loanRequestIcupAfter),
                  if (quote.needsGuarantor) ...[
                    const TextSpan(text: '\n'),
                    TextSpan(text: S.current.loanRequestGuarantorDetails),
                  ],
                ],
              ),
              style: AppTypography.bodySmall.copyWith(
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
