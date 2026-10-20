import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/deposit_request_footer.dart';

import '../cubit/change_phone_cubit.dart';

class ChangePhoneFooter extends StatelessWidget {
  const ChangePhoneFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePhoneCubit, ChangePhoneState>(
      builder: (context, state) {
        return DepositRequestFooter(
          termsAccepted: state.termsAccepted,
          bottomPadding: 16,
          onTermsChanged:
              state.submissionStatus != RequestStatus.loading &&
                  state.submissionStatus != RequestStatus.success
              ? (value) {
                  context.read<ChangePhoneCubit>().updateTerms(value);
                }
              : null,
          onTermsRequested: () {
            context.read<ChangePhoneCubit>().requestTerms();
          },
          isLoading: state.submissionStatus == RequestStatus.loading,
          onSubmit: state.canSubmit
              ? () {
                  context.read<ChangePhoneCubit>().submitPhoneChange();
                }
              : null,
          errorText: state.submissionStatus == RequestStatus.failure
              ? phoneSubmissionError(state.submissionFailure?.code)
              : null,
        );
      },
    );
  }
}

String phoneSubmissionError(String? code) => switch (code) {
  'profile.otp.invalid' => S.current.profileOtpInvalid,
  'profile.otp.expired' => S.current.profileOtpExpired,
  'profile.wallet.insufficient' => S.current.issuanceWalletInsufficient,
  _ => S.current.profileOperationError,
};
