import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../../../domain/entities/personal_information.dart';
import '../../shared/profile_labels.dart';
import '../../shared/profile_notice.dart';
import '../cubit/occupations_cubit.dart';

class OccupationForm extends StatelessWidget {
  const OccupationForm({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OccupationsCubit, OccupationsState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 76),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileNotice(message: S.current.profileOccupationNotice),
              const SizedBox(height: 20),
              CertificateSelect<OccupationKind>(
                label: S.current.profileOccupation,
                hint: S.current.profileOccupationHint,
                value: state.kind,
                enabled:
                    state.submissionStatus != RequestStatus.loading &&
                    state.submissionStatus != RequestStatus.success,
                options: [
                  for (final kind in OccupationKind.values)
                    AppSelectOption(value: kind, label: occupationLabel(kind)),
                ],
                onChanged: (value) {
                  context.read<OccupationsCubit>().selectKind(value);
                },
              ),
              if (state.conflictingOccupation != null) ...[
                const SizedBox(height: 20),
                ProfileNotice(
                  message: S.current.profileOccupationConflict(
                    occupationLabel(state.kind!),
                    occupationLabel(state.conflictingOccupation!.kind),
                  ),
                  isError: true,
                ),
              ],
              if (state.requiresOperatorReview) ...[
                const SizedBox(height: 20),
                ProfileNotice(
                  message: S.current.profileOccupationReview(
                    occupationLabel(state.selectedOccupation!.kind),
                    occupationLabel(state.kind!),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              CertificateInput(
                label: S.current.profileOccupationDescription,
                hint: S.current.profileOccupationDescriptionHint,
                value: state.description,
                enabled:
                    state.submissionStatus != RequestStatus.loading &&
                    state.submissionStatus != RequestStatus.success,
                errorText: state.isDescriptionError
                    ? S.current.profileDescriptionRequired
                    : null,
                onChanged: (value) {
                  context.read<OccupationsCubit>().updateDescription(value);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
