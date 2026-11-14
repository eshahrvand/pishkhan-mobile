import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../cubit/loan_request_cubit.dart';

class LoanContractSheet extends StatelessWidget {
  const LoanContractSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoanRequestCubit, LoanRequestState>(
      buildWhen: (previous, current) =>
          previous.termsAccepted != current.termsAccepted ||
          previous.catalog != current.catalog,
      builder: (context, state) {
        return SizedBox(
          height:
              MediaQuery.sizeOf(context).height -
              MediaQuery.viewPaddingOf(context).vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBottomSheetHeader(
                title: S.current.loanRequestContract,
                showRightIcon: false,
                onLeftAction: () {
                  Navigator.of(context).pop();
                },
              ),
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.catalog!.contractText == null) ...[
                          Text(
                            S.current.loanRequestMockContract,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.warning,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        Text(
                          state.catalog!.contractText ??
                              S.current.loanRequestMockContractBody,
                          style: AppTypography.bodyMedium.copyWith(
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(height: 1, color: context.colors.borderSubtle),
              Padding(
                padding: const EdgeInsets.all(20),
                child: AppCheckbox(
                  label: S.current.loanRequestTerms,
                  value: state.termsAccepted,
                  onChanged: (value) {
                    context.read<LoanRequestCubit>().updateTermsAccepted(
                      value == true,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: S.current.loanRequestDownloadContract,
                        constrainLabel: true,
                        variant: AppButtonVariant.secondaryGray,
                        onPressed: context
                            .read<LoanRequestCubit>()
                            .requestUnavailable,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: S.current.loanRequestContractAccept,
                        constrainLabel: true,
                        isActive: state.termsAccepted,
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
