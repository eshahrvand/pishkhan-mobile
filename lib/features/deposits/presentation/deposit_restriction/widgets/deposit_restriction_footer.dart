import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';

import '../../shared/deposit_request_footer.dart';
import '../cubit/deposit_restriction_cubit.dart';

class DepositRestrictionFooter extends StatelessWidget {
  const DepositRestrictionFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepositRestrictionCubit, DepositRestrictionState>(
      buildWhen: (previous, current) =>
          previous.termsAccepted != current.termsAccepted ||
          previous.isEditable != current.isEditable ||
          previous.canSubmit != current.canSubmit ||
          previous.submissionStatus != current.submissionStatus ||
          previous.failure != current.failure,
      builder: (context, state) {
        return DepositRequestFooter(
          termsAccepted: state.termsAccepted,
          onTermsChanged: state.isEditable
              ? context.read<DepositRestrictionCubit>().updateTermsAcceptance
              : null,
          onTermsRequested: context
              .read<DepositRestrictionCubit>()
              .requestTerms,
          onSubmit: state.canSubmit
              ? context.read<DepositRestrictionCubit>().submitRestriction
              : null,
          isLoading: state.submissionStatus == RequestStatus.loading,
        );
      },
    );
  }
}
