import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/deposit_request_footer.dart';

import '../cubit/occupations_cubit.dart';

class OccupationFooter extends StatelessWidget {
  const OccupationFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OccupationsCubit, OccupationsState>(
      builder: (context, state) {
        if (state.step == OccupationStep.list) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: AppButton(
              label: S.current.profileAddOccupation,
              size: AppButtonSize.lg,
              isLoading:
                  state.deletionStatus == RequestStatus.loading ||
                  state.submissionStatus == RequestStatus.loading,
              onPressed: state.occupationsStatus == RequestStatus.success
                  ? () {
                      context.read<OccupationsCubit>().requestNewOccupation();
                    }
                  : null,
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
                  context.read<OccupationsCubit>().updateTerms(value);
                }
              : null,
          onTermsRequested: () {
            context.read<OccupationsCubit>().requestTerms();
          },
          submitLabel: S.current.profileSubmit,
          isLoading: state.submissionStatus == RequestStatus.loading,
          errorText: state.submissionStatus == RequestStatus.failure
              ? S.current.profileOperationError
              : null,
          onSubmit: state.canSubmit
              ? () {
                  context.read<OccupationsCubit>().submitOccupation();
                }
              : null,
        );
      },
    );
  }
}
