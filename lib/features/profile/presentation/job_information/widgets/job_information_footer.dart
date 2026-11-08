import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/deposit_request_footer.dart';

import '../cubit/job_information_cubit.dart';

class JobInformationFooter extends StatelessWidget {
  const JobInformationFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobInformationCubit, JobInformationState>(
      builder: (context, state) {
        if (state.step == JobInformationStep.list) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: AppButton(
              label: S.current.profileAddJobInformation,
              size: AppButtonSize.lg,
              isLoading:
                  state.deletionStatus == RequestStatus.loading ||
                  state.submissionStatus == RequestStatus.loading,
              onPressed: () {
                context.read<JobInformationCubit>().requestNewJobInformation();
              },
              isActive: state.jobInformationStatus == RequestStatus.success,
            ),
          );
        }
        return DepositRequestFooter(
          termsAccepted: state.termsAccepted,
          bottomPadding: 16,
          onTermsChanged:
              state.submissionStatus != RequestStatus.loading &&
                  state.submissionStatus != RequestStatus.success
              ? (value) {
                  context.read<JobInformationCubit>().updateTerms(value);
                }
              : null,
          onTermsRequested: () {
            context.read<JobInformationCubit>().requestTerms();
          },
          submitLabel: S.current.profileSubmit,
          isLoading: state.submissionStatus == RequestStatus.loading,

          onSubmit: () {
            context.read<JobInformationCubit>().submitJobInformation();
          },
          isActive: state.canSubmit,
        );
      },
    );
  }
}
