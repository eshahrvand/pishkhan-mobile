import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/linked_deposit_cubit.dart';
import '../widgets/linked_deposit_form.dart';
import '../widgets/wallet_terms_sheet.dart';
import '../../shared/wallet_scaffold.dart';

class WalletLinkedDepositScreen extends StatelessWidget {
  const WalletLinkedDepositScreen({super.key});
  void _showFailure(BuildContext context, WalletLinkedDepositState state) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(state.message!)));
  }

  void _complete(BuildContext context, WalletLinkedDepositState state) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(S.current.walletDepositChanged)));
    NavigationActions.back(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletLinkedDepositCubit()..fetchCatalog(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<WalletLinkedDepositCubit, WalletLinkedDepositState>(
            listenWhen: (previous, current) =>
                previous.catalogStatus != current.catalogStatus &&
                current.catalogStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<WalletLinkedDepositCubit, WalletLinkedDepositState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus &&
                current.submissionStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<WalletLinkedDepositCubit, WalletLinkedDepositState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus &&
                current.submissionStatus == RequestStatus.success,
            listener: _complete,
          ),
        ],
        child: BlocBuilder<WalletLinkedDepositCubit, WalletLinkedDepositState>(
          builder: (context, state) {
            return WalletScaffold(
              title: S.current.walletLinkedDepositTitle,
              busy: state.submissionStatus == RequestStatus.loading,
              footer: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      AppCheckbox(
                        value: state.termsAccepted,
                        onChanged:
                            state.catalogStatus == RequestStatus.success &&
                                state.submissionStatus != RequestStatus.loading
                            ? context
                                  .read<WalletLinkedDepositCubit>()
                                  .updateTermsAcceptance
                            : null,
                      ),
                      AppButton(
                        label: S.current.walletTerms,
                        variant: AppButtonVariant.text,
                        isActive:
                            state.catalog != null &&
                            state.submissionStatus != RequestStatus.loading,
                        onPressed: () =>
                            showWalletTerms(context, state.catalog!.terms),
                      ),
                      Expanded(
                        child: Text(
                          S.current.walletTermsAcceptance,
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: S.current.walletConfirmPayment,
                      size: AppButtonSize.lg,
                      isActive: state.canSubmit,
                      isLoading:
                          state.submissionStatus == RequestStatus.loading,
                      onPressed: context
                          .read<WalletLinkedDepositCubit>()
                          .submitChange,
                    ),
                  ),
                ],
              ),
              child: switch (state.catalogStatus) {
                RequestStatus.initial || RequestStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                RequestStatus.failure => Center(
                  child: AppButton(
                    label: S.current.dashboardRetry,
                    onPressed: context
                        .read<WalletLinkedDepositCubit>()
                        .fetchCatalog,
                  ),
                ),
                RequestStatus.success => WalletLinkedDepositForm(state: state),
              },
            );
          },
        ),
      ),
    );
  }
}
