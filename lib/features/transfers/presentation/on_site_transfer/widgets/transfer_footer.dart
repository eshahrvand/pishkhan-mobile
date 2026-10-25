import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';

import '../cubit/on_site_transfer_cubit.dart';

import 'package:pishkhan_mobile/shared/widgets/deposit_request_footer.dart';

class TransferFooter extends StatelessWidget {
  const TransferFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnSiteTransferCubit, OnSiteTransferState>(
      builder: (context, state) {
        if (state.catalogStatus != RequestStatus.success) {
          return const SizedBox.shrink();
        }
        if (state.step == OnSiteTransferStep.confirmation) {
          return DepositRequestFooter(
            bottomPadding: 16,
            termsAccepted: state.termsAccepted,
            onTermsChanged: state.submissionStatus != RequestStatus.loading
                ? (value) {
                    context.read<OnSiteTransferCubit>().updateTerms(value);
                  }
                : null,
            onTermsRequested: () {
              context.read<OnSiteTransferCubit>().requestUnavailable();
            },
            isLoading: state.submissionStatus == RequestStatus.loading,
            submitLabel: S.current.transferConfirmNext,

            onSubmit: state.canContinue
                ? () {
                    context.read<OnSiteTransferCubit>().submitTransfer();
                  }
                : null,
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: AppButton(
              label: state.step == OnSiteTransferStep.destinations
                  ? S.current.transferConfirmNext
                  : S.current.issuanceNext,
              size: AppButtonSize.lg,
              disabledAppearance: AppButtonDisabledAppearance.service,
              isLoading: state.submissionStatus == RequestStatus.loading,
              onPressed: state.canContinue
                  ? () {
                      context.read<OnSiteTransferCubit>().continueFlow();
                    }
                  : null,
            ),
          ),
        );
      },
    );
  }
}
