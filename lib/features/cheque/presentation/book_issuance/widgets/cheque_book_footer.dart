import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/cheque_book_cubit.dart';
import 'cheque_book_labels.dart';

class ChequeBookFooter extends StatelessWidget {
  const ChequeBookFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChequeBookCubit, ChequeBookState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.addressDeletionFailure != null ||
                  state.addressSaveFailure != null ||
                  state.quoteFailure != null ||
                  state.submissionFailure != null) ...[
                Text(
                  S.current.chequeSubmitFailure,
                  style: certificateLabelStyle(context)
                      .copyWith(color: context.colors.error),
                ),
                const SizedBox(height: 8),
              ],
              AppButton(
                label: chequeBookActionLabel(state.primaryAction),
                size: AppButtonSize.lg,
                disabledAppearance: AppButtonDisabledAppearance.service,
                isLoading:
                    state.quoteStatus == RequestStatus.loading ||
                    state.submissionStatus == RequestStatus.loading ||
                    state.addressDeletionStatus == RequestStatus.loading ||
                    state.addressSaveStatus == RequestStatus.loading,
                onPressed: state.canContinue
                    ? context.read<ChequeBookCubit>().continueFlow
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
