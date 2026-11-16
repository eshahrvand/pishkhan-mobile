import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';

import '../../shared/deposit_request_footer.dart';
import '../cubit/deposit_mandate_cubit.dart';

class DepositMandateFooter extends StatelessWidget {
  const DepositMandateFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepositMandateCubit, DepositMandateState>(
      buildWhen: (previous, current) =>
          previous.termsAccepted != current.termsAccepted ||
          previous.isEditable != current.isEditable ||
          previous.canSubmit != current.canSubmit ||
          previous.submissionStatus != current.submissionStatus,
      builder: (context, state) {
        return DepositRequestFooter(
          termsAccepted: state.termsAccepted,
          onTermsChanged: state.isEditable
              ? context.read<DepositMandateCubit>().updateTermsAcceptance
              : null,
          onTermsRequested: context.read<DepositMandateCubit>().requestTerms,
          onSubmit: context.read<DepositMandateCubit>().submitDepositMandate,
          isActive: state.canSubmit,
          isLoading: state.submissionStatus == RequestStatus.loading,
        );
      },
    );
  }
}
