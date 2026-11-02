import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/cheque_book_cubit.dart';
import 'cheque_book_confirmation.dart';
import 'cheque_book_delivery.dart';
import 'cheque_book_labels.dart';
import 'cheque_book_residency.dart';
import 'cheque_book_selection.dart';

class ChequeBookContent extends StatelessWidget {
  const ChequeBookContent({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChequeBookCubit, ChequeBookState>(
      builder: (context, state) {
        if (state.catalogStatus == RequestStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.catalogStatus == RequestStatus.failure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox.shrink(),
                AppButton(
                  isLoading: state.catalogStatus == RequestStatus.loading,
                  label: S.current.dashboardRetry,
                  onPressed: context.read<ChequeBookCubit>().fetchCatalog,
                ),
              ],
            ),
          );
        }
        if (state.step == ChequeBookStep.checking) {
          return Align(
            alignment: const Alignment(0, .18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.current.chequeBookChecking,
                  textAlign: TextAlign.center,
                  style: certificateValueStyle(context)
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                if (state.residencyStatus == RequestStatus.failure) ...[
                  const SizedBox.shrink(),
                  AppButton(
                    isLoading: state.residencyStatus == RequestStatus.loading,
                    label: S.current.dashboardRetry,
                    onPressed: context.read<ChequeBookCubit>().fetchResidency,
                  ),
                ] else
                  // The package indicator is determinate; this service wait is indeterminate.
                  SizedBox(
                    width: 160,
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      color: context.colors.textTertiary,
                      backgroundColor: context.colors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(2000),
                    ),
                  ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 76),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppStepper(
                currentStep: state.stepNumber,
                totalSteps: 4,
                title: chequeBookStepTitle(state.step),
                supportingText: chequeBookNextTitle(state.step),
              ),
              const SizedBox(height: 26),
              if (state.step == ChequeBookStep.selection)
                ChequeBookSelection(state: state),
              if (state.step == ChequeBookStep.residency)
                ChequeBookResidency(state: state),
              if (state.step == ChequeBookStep.delivery)
                ChequeBookDelivery(state: state),
              if (state.step == ChequeBookStep.confirmation)
                ChequeBookConfirmation(state: state),
            ],
          ),
        );
      },
    );
  }
}
