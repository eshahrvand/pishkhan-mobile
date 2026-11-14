import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';

import '../../../domain/entities/loan_application.dart';
import '../cubit/loan_request_cubit.dart';
import 'loan_assessment.dart';
import 'loan_introduction.dart';
import 'loan_inquiries.dart';
import 'loan_collateral_form.dart';
import 'loan_contract_summary.dart';
import 'loan_request_labels.dart';

/// Scrollable step content, loading/retry surfaces and the floating assistant.
class LoanRequestContent extends StatelessWidget {
  const LoanRequestContent({
    super.key,
    required this.state,
    required this.scrollController,
  });
  final LoanRequestState state;
  final ScrollController scrollController;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (state.catalogStatus == RequestStatus.initial ||
            state.catalogStatus == RequestStatus.loading)
          const Center(child: CircularProgressIndicator()),
        if (state.catalogStatus == RequestStatus.failure)
          Center(
            child: AppButton(
              label: S.current.dashboardRetry,
              onPressed: context.read<LoanRequestCubit>().fetchCatalog,
            ),
          ),
        if (state.catalogStatus == RequestStatus.success)
          AbsorbPointer(
            absorbing:
                state.inquiryStatus == RequestStatus.loading ||
                state.guarantorStatus == RequestStatus.loading ||
                state.collateralStatus == RequestStatus.loading ||
                state.draftStatus == RequestStatus.loading ||
                state.otpStatus == RequestStatus.loading ||
                state.submissionStatus == RequestStatus.loading ||
                state.cancellationStatus == RequestStatus.loading,
            child: Column(
              children: [
                if (state.step != LoanApplicationStep.introduction)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: AppStepper(
                      currentStep: state.stepNumber,
                      totalSteps: 4,
                      title: loanStepLabel(state.step),
                      supportingText: loanNextLabel(state.step),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Parent supplies State; sections do not subscribe to the same data again.
                        if (state.step == LoanApplicationStep.introduction)
                          LoanIntroduction(state: state),
                        if (state.step == LoanApplicationStep.assessment)
                          LoanAssessment(state: state),
                        if (state.step == LoanApplicationStep.inquiries)
                          LoanInquiries(state: state),
                        if (state.step == LoanApplicationStep.collateral)
                          LoanCollateralForm(state: state),
                        if (state.step == LoanApplicationStep.contract)
                          LoanContractSummary(state: state),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        Positioned(
          left: 16,
          bottom: 16,
          child: AppAssistantButton(
            onPressed: context.read<LoanRequestCubit>().requestUnavailable,
          ),
        ),
      ],
    );
  }
}
