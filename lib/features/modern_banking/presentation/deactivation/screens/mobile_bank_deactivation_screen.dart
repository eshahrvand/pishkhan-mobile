import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/deposit_request_footer.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../../shared/modern_bank_receipt.dart';
import '../../shared/modern_bank_terms.dart';
import '../cubit/mobile_bank_deactivation_cubit.dart';
import '../widgets/mobile_bank_deactivation_form.dart';

class MobileBankDeactivationScreen extends StatelessWidget {
  const MobileBankDeactivationScreen({super.key});
  Future<void> _handleNavigation(
    BuildContext context,
    MobileBankDeactivationState state,
  ) async {
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    switch (state.navigation) {
      case FlowNavigation.confirmExit:
        context
            .read<MobileBankDeactivationCubit>()
            .consumeMobileBankDeactivationInteraction();
        final result = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<MobileBankDeactivationCubit>().applyExitConfirmation(
            result,
          );
        }
      case FlowNavigation.back:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case FlowNavigation.home:
        context.go(AppRoutes.home);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MobileBankDeactivationCubit()..fetchMobileBank(),
      child: BlocListener<MobileBankDeactivationCubit, MobileBankDeactivationState>(
        listenWhen: (previous, current) =>
            (previous.navigation != current.navigation &&
                current.navigation != null) ||
            ((previous.catalogStatus != current.catalogStatus &&
                    current.catalogStatus == RequestStatus.failure) ||
                (previous.submissionStatus != current.submissionStatus &&
                    current.submissionStatus == RequestStatus.failure)),
        listener: _handleNavigation,
        child:
            BlocBuilder<
              MobileBankDeactivationCubit,
              MobileBankDeactivationState
            >(
              builder: (context, state) {
                return PopScope(
                  canPop:
                      (state.catalogStatus != RequestStatus.loading &&
                          state.submissionStatus != RequestStatus.loading) &&
                      (state.navigation == FlowNavigation.back),
                  onPopInvokedWithResult: (didPop, _) {
                    if (!didPop &&
                        state.catalogStatus != RequestStatus.loading &&
                        state.submissionStatus != RequestStatus.loading) {
                      context.read<MobileBankDeactivationCubit>().requestBack();
                    }
                  },
                  child: Scaffold(
                    backgroundColor: context.colors.surfaceSubtle,
                    body: SafeArea(
                      child: Column(
                        children: [
                          AppTopBar(
                            title: S.current.modernDeactivationTitle,
                            showLeadingActions: false,
                            trailingIcon: SizedBox.square(
                              dimension: 24,
                              child: AvpImage(
                                image:
                                    '${AppConstants.baseImage}deposit_list_back.svg',
                              ),
                            ),
                            trailingTooltip: S.current.backLabel,
                            onTrailingPressed:
                                (state.catalogStatus != RequestStatus.loading &&
                                    state.submissionStatus !=
                                        RequestStatus.loading)
                                ? () {
                                    context
                                        .read<MobileBankDeactivationCubit>()
                                        .requestBack();
                                  }
                                : null,
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                if (state.catalogStatus ==
                                        RequestStatus.initial ||
                                    state.catalogStatus ==
                                        RequestStatus.loading)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                if (state.catalogStatus ==
                                    RequestStatus.failure)
                                  Center(
                                    child: AppButton(
                                      isLoading:
                                          state.catalogStatus ==
                                          RequestStatus.loading,
                                      label: S.current.dashboardRetry,
                                      onPressed: () {
                                        context
                                            .read<MobileBankDeactivationCubit>()
                                            .fetchMobileBank();
                                      },
                                    ),
                                  ),
                                if (state.catalogStatus ==
                                    RequestStatus.success)
                                  SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      16,
                                      16,
                                      72,
                                    ),
                                    child:
                                        state.submissionStatus ==
                                            RequestStatus.success
                                        ? ModernBankReceipt(
                                            message: S
                                                .current
                                                .modernDeactivationSaved,
                                            trackingCode:
                                                state.receipt!.trackingCode,
                                          )
                                        : MobileBankDeactivationForm(
                                            state: state,
                                          ),
                                  ),
                                Positioned(
                                  left: 16,
                                  bottom: 16,
                                  child: AppAssistantButton(
                                    onPressed: () {
                                      context
                                          .read<MobileBankDeactivationCubit>()
                                          .requestHome();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (state.catalogStatus == RequestStatus.success)
                            if (state.submissionStatus == RequestStatus.success)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: AppButton(
                                  label: S.current.passwordUnderstood,
                                  size: AppButtonSize.lg,
                                  onPressed: () {
                                    context
                                        .read<MobileBankDeactivationCubit>()
                                        .requestHome();
                                  },
                                ),
                              )
                            else
                              DepositRequestFooter(
                                submitLabel: S.current.passwordChangeSubmit,
                                termsAccepted: state.termsAccepted,
                                onTermsChanged:
                                    state.submissionStatus ==
                                        RequestStatus.loading
                                    ? null
                                    : (value) {
                                        context
                                            .read<MobileBankDeactivationCubit>()
                                            .updateTermsAccepted(value);
                                      },
                                onTermsRequested: () {
                                  showModernBankTerms(context);
                                },
                                onSubmit: state.canSubmit
                                    ? () {
                                        context
                                            .read<MobileBankDeactivationCubit>()
                                            .submitDeactivation();
                                      }
                                    : null,
                                isLoading:
                                    state.submissionStatus ==
                                    RequestStatus.loading,

                                bottomPadding: 16,
                              ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
