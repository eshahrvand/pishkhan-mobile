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
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/deposit_request_footer.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../../../domain/entities/mobile_bank.dart';
import '../../shared/modern_bank_terms.dart';
import '../cubit/mobile_bank_cubit.dart';
import '../widgets/mobile_bank_content.dart';

class MobileBankScreen extends StatelessWidget {
  const MobileBankScreen({
    super.key,
    this.operation = MobileBankOperation.activation,
  });
  final MobileBankOperation operation;

  Future<void> _handleEffect(
    BuildContext context,
    MobileBankState state,
  ) async {
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    if (state.destination != null) {
      context.read<MobileBankCubit>().consumeMobileBankInteraction();

      await context.push<void>(switch (state.destination!) {
        MobileBankDestination.passwordRecovery =>
          AppRoutes.mobileBankPasswordRecovery,
        MobileBankDestination.passwordGuide =>
          AppRoutes.mobileBankPasswordGuide,
        MobileBankDestination.transferLimits =>
          AppRoutes.mobileBankTransferLimits,
        MobileBankDestination.deactivation => AppRoutes.mobileBankDeactivation,
      });
      if (context.mounted) {
        context.read<MobileBankCubit>().refreshAfterService();
      }
    } else {
      switch (state.navigation) {
        case FlowNavigation.confirmExit:
          context.read<MobileBankCubit>().consumeMobileBankInteraction();
          final confirmed = await showFlowExitDialog(context);
          if (context.mounted) {
            context.read<MobileBankCubit>().applyExitConfirmation(confirmed);
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MobileBankCubit(operation: operation)..fetchMobileBank(),
      child: BlocListener<MobileBankCubit, MobileBankState>(
        listenWhen: (previous, current) =>
            (((previous.navigation != current.navigation &&
                    current.navigation != null) ||
                (previous.destination != current.destination &&
                    current.destination != null))) ||
            ((previous.catalogStatus != current.catalogStatus &&
                    current.catalogStatus == RequestStatus.failure) ||
                (previous.submissionStatus != current.submissionStatus &&
                    current.submissionStatus == RequestStatus.failure)),
        listener: _handleEffect,
        child: BlocBuilder<MobileBankCubit, MobileBankState>(
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
                  context.read<MobileBankCubit>().requestBack();
                }
              },
              child: Scaffold(
                backgroundColor: context.colors.surfaceSubtle,
                body: SafeArea(
                  child: Column(
                    children: [
                      AppTopBar(
                        title: operation == MobileBankOperation.activation
                            ? S.current.mobileBank
                            : S.current.modernRecoveryTitle,
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
                                state.submissionStatus != RequestStatus.loading)
                            ? () {
                                context.read<MobileBankCubit>().requestBack();
                              }
                            : null,
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            if (state.catalogStatus == RequestStatus.initial ||
                                state.catalogStatus == RequestStatus.loading)
                              const Center(child: CircularProgressIndicator()),
                            if (state.catalogStatus == RequestStatus.failure)
                              Center(
                                child: AppButton(
                                  isLoading:
                                      state.catalogStatus ==
                                      RequestStatus.loading,
                                  label: S.current.dashboardRetry,
                                  onPressed: () {
                                    context
                                        .read<MobileBankCubit>()
                                        .fetchMobileBank();
                                  },
                                ),
                              ),
                            if (state.catalogStatus == RequestStatus.success)
                              SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  72,
                                ),
                                child: MobileBankContent(state: state),
                              ),
                            if (state.step != MobileBankStep.pending &&
                                state.step != MobileBankStep.active)
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: AppAssistantButton(
                                  onPressed: () {
                                    context
                                        .read<MobileBankCubit>()
                                        .requestHome();
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (state.catalogStatus == RequestStatus.success &&
                          state.step != MobileBankStep.pending &&
                          state.step != MobileBankStep.active) ...[
                        if (state.step == MobileBankStep.payment)
                          DepositRequestFooter(
                            termsAccepted: state.termsAccepted,
                            onTermsChanged:
                                state.submissionStatus == RequestStatus.loading
                                ? null
                                : (value) {
                                    context
                                        .read<MobileBankCubit>()
                                        .updateTermsAccepted(value);
                                  },
                            onTermsRequested: () {
                              showModernBankTerms(context);
                            },
                            onSubmit: state.canContinue
                                ? () {
                                    context
                                        .read<MobileBankCubit>()
                                        .continueFlow();
                                  }
                                : null,
                            isLoading:
                                state.submissionStatus == RequestStatus.loading,
                            submitLabel: S.current.issuanceNext,
                            bottomPadding: 16,
                          )
                        else if (state.step == MobileBankStep.receipt ||
                            state.step == MobileBankStep.recoveryApproved)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: AppButton(
                              isLoading:
                                  state.catalogStatus ==
                                      RequestStatus.loading ||
                                  state.submissionStatus ==
                                      RequestStatus.loading,
                              label: S.current.passwordUnderstood,
                              size: AppButtonSize.lg,
                              onPressed: () {
                                context.read<MobileBankCubit>().continueFlow();
                              },
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: AppButton(
                              label: getMobileBankButtonTitle(state.step),
                              trailingIcon:
                                  state.step == MobileBankStep.introduction
                                  ? SizedBox.square(
                                      dimension: 20,
                                      child: AvpImage(
                                        image:
                                            '${AppConstants.baseImage}modern_activate_arrow.svg',
                                      ),
                                    )
                                  : null,
                              size: AppButtonSize.lg,
                              disabledAppearance:
                                  AppButtonDisabledAppearance.service,
                              isLoading:
                                  state.submissionStatus ==
                                  RequestStatus.loading,
                              onPressed: state.canContinue
                                  ? () {
                                      context
                                          .read<MobileBankCubit>()
                                          .continueFlow();
                                    }
                                  : null,
                            ),
                          ),
                      ],
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

String getMobileBankButtonTitle(MobileBankStep step) => switch (step) {
  MobileBankStep.introduction => S.current.modernActivate,
  MobileBankStep.instruction => S.current.passwordStartKyc,
  MobileBankStep.preview => S.current.passwordSubmit,
  _ => S.current.issuanceNext,
};
