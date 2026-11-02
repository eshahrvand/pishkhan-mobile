import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../../../domain/entities/personal_information.dart';
import '../../shared/profile_labels.dart';
import '../../shared/profile_notice.dart';
import '../cubit/job_information_cubit.dart';

class JobInformationForm extends StatelessWidget {
  const JobInformationForm({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobInformationCubit, JobInformationState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 76),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileNotice(message: S.current.profileJobInformationNotice),
              const SizedBox(height: 20),
              CertificateSelect<JobInformationKind>(
                label: S.current.profileJobInformation,
                hint: S.current.profileJobInformationHint,
                value: state.kind,
                enabled:
                    state.submissionStatus != RequestStatus.loading &&
                    state.submissionStatus != RequestStatus.success,
                options: [
                  for (final kind in JobInformationKind.values)
                    AppSelectOption(
                      value: kind,
                      label: jobInformationLabel(kind),
                    ),
                ],
                onChanged: (value) {
                  context.read<JobInformationCubit>().selectKind(value);
                },
              ),
              if (state.conflictingJobInformation != null) ...[
                const SizedBox(height: 20),
                ProfileNotice(
                  message: S.current.profileJobInformationConflict(
                    jobInformationLabel(state.kind!),
                    jobInformationLabel(state.conflictingJobInformation!.kind),
                  ),
                  isError: true,
                ),
              ],
              if (state.requiresOperatorReview) ...[
                const SizedBox(height: 20),
                ProfileNotice(
                  message: S.current.profileJobInformationReview(
                    jobInformationLabel(state.selectedJobInformation!.kind),
                    jobInformationLabel(state.kind!),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              CertificateInput(
                label: S.current.profileJobInformationDescription,
                hint: S.current.profileJobInformationDescriptionHint,
                value: state.description,
                enabled:
                    state.submissionStatus != RequestStatus.loading &&
                    state.submissionStatus != RequestStatus.success,
                errorText: state.isDescriptionError
                    ? S.current.profileDescriptionRequired
                    : null,
                onChanged: (value) {
                  context.read<JobInformationCubit>().updateDescription(value);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
