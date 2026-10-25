import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';

import '../../shared/deposit_request_footer.dart';
import '../cubit/proxy_deposit_cubit.dart';

class ProxyDepositFooter extends StatelessWidget {
  const ProxyDepositFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProxyDepositCubit, ProxyDepositState>(
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
              ? context.read<ProxyDepositCubit>().updateTermsAcceptance
              : null,
          onTermsRequested: context.read<ProxyDepositCubit>().requestTerms,
          onSubmit: state.canSubmit
              ? context.read<ProxyDepositCubit>().submitProxyDeposit
              : null,
          isLoading: state.submissionStatus == RequestStatus.loading,
        );
      },
    );
  }
}
