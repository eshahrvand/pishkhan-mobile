import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_occupation_card.dart';

import '../../shared/profile_labels.dart';
import '../cubit/occupations_cubit.dart';

class OccupationsList extends StatelessWidget {
  const OccupationsList({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OccupationsCubit, OccupationsState>(
      buildWhen: (previous, current) =>
          previous.occupations != current.occupations ||
          previous.occupationsStatus != current.occupationsStatus ||
          previous.deletionStatus != current.deletionStatus ||
          previous.submissionStatus != current.submissionStatus,
      builder: (context, state) {
        if (state.occupationsStatus == RequestStatus.initial ||
            state.occupationsStatus == RequestStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.occupationsStatus == RequestStatus.failure) {
          return Center(
            child: AppButton(
              label: S.current.dashboardRetry,
              onPressed: () {
                context.read<OccupationsCubit>().fetchOccupations();
              },
            ),
          );
        }
        if (state.occupations.isEmpty) {
          return Center(
            child: Text(
              S.current.profileOccupationsEmpty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.colors.textSecondary),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 76),
          children: [
            for (final occupation in state.occupations) ...[
              AppOccupationCard(
                outlined: true,
                title: occupationLabel(occupation.kind),
                description: occupation.description,
                titleLabel: S.current.profileTitle,
                descriptionLabel: S.current.profileDescription,
                onMoreTap:
                    state.deletionStatus != RequestStatus.loading &&
                        state.submissionStatus != RequestStatus.loading
                    ? () {
                        context
                            .read<OccupationsCubit>()
                            .requestOccupationActions(occupation);
                      }
                    : null,
              ),
              const SizedBox(height: 20),
            ],
            if (state.deletionStatus == RequestStatus.loading)
              const Center(child: CircularProgressIndicator()),
            if (state.deletionStatus == RequestStatus.failure)
              Text(
                S.current.profileOperationError,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: context.colors.error),
              ),
          ],
        );
      },
    );
  }
}
