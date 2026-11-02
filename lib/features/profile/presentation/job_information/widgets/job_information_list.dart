import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_job_information_card.dart';

import '../../shared/profile_labels.dart';
import '../cubit/job_information_cubit.dart';

class JobInformationList extends StatelessWidget {
  const JobInformationList({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobInformationCubit, JobInformationState>(
      buildWhen: (previous, current) =>
          previous.jobInformation != current.jobInformation ||
          previous.jobInformationStatus != current.jobInformationStatus ||
          previous.deletionStatus != current.deletionStatus ||
          previous.submissionStatus != current.submissionStatus,
      builder: (context, state) {
        if (state.jobInformationStatus == RequestStatus.initial ||
            state.jobInformationStatus == RequestStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.jobInformationStatus == RequestStatus.failure) {
          return Center(
            child: AppButton(
              isLoading: state.jobInformationStatus == RequestStatus.loading,
              label: S.current.dashboardRetry,
              onPressed: () {
                context.read<JobInformationCubit>().fetchJobInformation();
              },
            ),
          );
        }
        if (state.jobInformation.isEmpty) {
          return Center(
            child: Text(
              S.current.profileJobInformationEmpty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.colors.textSecondary),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 76),
          children: [
            for (final jobInformation in state.jobInformation) ...[
              AppJobInformationCard(
                outlined: true,
                title: jobInformationLabel(jobInformation.kind),
                description: jobInformation.description,
                titleLabel: S.current.profileTitle,
                descriptionLabel: S.current.profileDescription,
                onMoreTap:
                    state.deletionStatus != RequestStatus.loading &&
                        state.submissionStatus != RequestStatus.loading
                    ? () {
                        context
                            .read<JobInformationCubit>()
                            .requestJobInformationActions(jobInformation);
                      }
                    : null,
              ),
              const SizedBox(height: 20),
            ],
            if (state.deletionStatus == RequestStatus.loading)
              const Center(child: CircularProgressIndicator()),
          ],
        );
      },
    );
  }
}
