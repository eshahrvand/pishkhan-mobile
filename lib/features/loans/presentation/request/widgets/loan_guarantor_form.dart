import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/loan_application.dart';
import '../cubit/loan_request_cubit.dart';
import 'loan_guarantor_warning.dart';
import 'loan_value_row.dart';

class LoanGuarantorForm extends StatelessWidget {
  const LoanGuarantorForm({super.key, required this.state});
  final LoanRequestState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    S.current.loanRequestGuarantorId,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                      color: AppPalette.gray700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    textStyle: AppTypography.bodyMedium.copyWith(
                      letterSpacing: 0,
                    ),
                    hintText: S.current.loanRequestGuarantorIdHint,
                    value: state.guarantorNationalId,
                    suffixIcon: state.guarantor != null
                        ? Center(
                            widthFactor: 1,
                            heightFactor: 1,
                            child: SizedBox.square(
                              dimension: 20,
                              child: InkWell(
                                onTap: () {
                                  context
                                      .read<LoanRequestCubit>()
                                      .updateGuarantorNationalId('');
                                },
                                child: const AvpImage(
                                  image:
                                      '${AppConstants.baseImage}loan_request_clear.svg',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                          )
                        : null,
                    onFocusLost: context
                        .read<LoanRequestCubit>()
                        .validateGuarantorNationalId,
                    normalizeDigits: true,
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    hintTextDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    enabled: state.guarantorStatus != RequestStatus.loading,
                    errorText: state.isGuarantorIdError
                        ? S.current.authInvalidNationalId
                        : null,
                    onChanged: (value) {
                      context
                          .read<LoanRequestCubit>()
                          .updateGuarantorNationalId(value);
                    },
                  ),
                ],
              ),
            ),
            if (state.guarantor == null) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: AppButton(
                  label: S.current.loanRequestCheck,
                  size: AppButtonSize.lg,
                  isActive: state.canCheckGuarantor,
                  isLoading: state.guarantorStatus == RequestStatus.loading,
                  onPressed: context.read<LoanRequestCubit>().checkGuarantor,
                ),
              ),
            ],
          ],
        ),
        if (state.guarantor != null) ...[
          const SizedBox(height: 12),
          if (state.guarantor!.name != null)
            LoanValueRow(
              height: 44,
              label: S.current.loanRequestGuarantorName,
              value: state.guarantor!.name!,
              backgroundColor: AppPalette.gray100,
              valueFontWeight: FontWeight.w400,
              bordered: false,
              color: context.colors.textSecondary,
            ),
          if (state.guarantor!.outcome == LoanGuarantorOutcome.notCustomer)
            LoanGuarantorWarning(
              message: S.current.loanRequestGuarantorNotCustomer,
            ),
          if (state.guarantor!.outcome == LoanGuarantorOutcome.capacityExceeded)
            LoanGuarantorWarning(message: S.current.loanRequestGuarantorFull),
        ],
      ],
    );
  }
}
