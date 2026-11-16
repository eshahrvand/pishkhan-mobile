import '../widgets/loan_request_content.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar_action.dart';
import 'package:pishkhan_mobile/shared/widgets/app_decision_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_sheet.dart';

import '../../../domain/entities/loan_application.dart';
import '../cubit/loan_request_cubit.dart';
import '../widgets/loan_information_sheet.dart';
import '../widgets/loan_insurance_sheet.dart';
import '../widgets/loan_installments_sheet.dart';
import '../widgets/loan_contract_sheet.dart';
import '../widgets/loan_otp_sheet.dart';
import '../widgets/loan_receipt_sheet.dart';
import '../widgets/loan_request_labels.dart';

class LoanRequestScreen extends StatefulWidget {
  const LoanRequestScreen({super.key});
  @override
  State<LoanRequestScreen> createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends State<LoanRequestScreen> {
  final _scrollController = ScrollController();

  void _scrollToStepStart(BuildContext context, LoanRequestState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) _scrollController.jumpTo(0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showFailure(BuildContext context, LoanRequestState state) {
    avpSnackBar(
      context: context,
      type: AvpSnackBarType.error,
      message: state.message!,
    );
  }

  Future<void> _handleEffect(
    BuildContext context,
    LoanRequestState state,
  ) async {
    if (state.effect != LoanRequestEffect.exit) {
      context.read<LoanRequestCubit>().consumeInteraction();
    }
    switch (state.effect!) {
      case LoanRequestEffect.copyRequestNumber:
        await Clipboard.setData(
          ClipboardData(text: state.catalog!.latestRecord!.id),
        );
      case LoanRequestEffect.creditInfo:
        await showAppServiceSheet<void>(
          context,
          LoanInformationSheet(
            title: S.current.loanRequestTier,
            body: S.current.loanRequestCreditInfo,
          ),
        );
      case LoanRequestEffect.installments:
        await showAppServiceSheet<void>(
          context,
          LoanInstallmentsSheet(quote: state.quote!),
        );
      case LoanRequestEffect.insurance:
        await showAppServiceSheet<void>(
          context,
          LoanInsuranceSheet(state: state),
        );
      case LoanRequestEffect.contract:
        final result = await showAppServiceSheet<bool>(
          context,
          BlocProvider.value(
            value: context.read<LoanRequestCubit>(),
            child: const LoanContractSheet(),
          ),
        );
        if (context.mounted) {
          await context.read<LoanRequestCubit>().applyContractResult(result);
        }
      case LoanRequestEffect.otp:
        await showAppServiceSheet<void>(
          context,
          BlocProvider.value(
            value: context.read<LoanRequestCubit>(),
            child: const LoanOtpSheet(),
          ),
        );
        if (context.mounted) context.read<LoanRequestCubit>().applyOtpResult();
      case LoanRequestEffect.receipt:
        await showAppServiceSheet<void>(
          context,
          LoanReceiptSheet(record: state.receipt!),
        );
        if (context.mounted) {
          await context.read<LoanRequestCubit>().completeReceipt();
        }
      case LoanRequestEffect.confirmCancel:
        final accepted = await showAppServiceSheet<bool>(
          context,
          AppDecisionSheet(
            title: S.current.loanRequestCancel,
            message: S.current.loanRequestCancelPrompt,
            confirmLabel: S.current.loanRequestCancel,
            cancelLabel: S.current.backLabel,
            onConfirm: () {
              Navigator.of(context, rootNavigator: true).pop(true);
            },
          ),
        );
        if (context.mounted) {
          await context.read<LoanRequestCubit>().applyCancelResult(accepted);
        }
      case LoanRequestEffect.confirmExit:
        final accepted = await showFlowExitSheet(context);
        if (context.mounted) {
          await context.read<LoanRequestCubit>().applyExitResult(accepted);
        }
      case LoanRequestEffect.exit:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case LoanRequestEffect.unavailable:
        avpSnackBar(
          context: context,
          type: AvpSnackBarType.error,
          message: S.current.loanRequestUnavailable,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoanRequestCubit()..fetchCatalog(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<LoanRequestCubit, LoanRequestState>(
            listenWhen: (previous, current) => previous.step != current.step,
            listener: _scrollToStepStart,
          ),
          BlocListener<LoanRequestCubit, LoanRequestState>(
            listenWhen: (previous, current) =>
                previous.catalogStatus != current.catalogStatus &&
                current.catalogStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<LoanRequestCubit, LoanRequestState>(
            listenWhen: (previous, current) =>
                previous.quoteStatus != current.quoteStatus &&
                current.quoteStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<LoanRequestCubit, LoanRequestState>(
            listenWhen: (previous, current) =>
                previous.inquiryStatus != current.inquiryStatus &&
                current.inquiryStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<LoanRequestCubit, LoanRequestState>(
            listenWhen: (previous, current) =>
                previous.guarantorStatus != current.guarantorStatus &&
                current.guarantorStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<LoanRequestCubit, LoanRequestState>(
            listenWhen: (previous, current) =>
                previous.collateralStatus != current.collateralStatus &&
                current.collateralStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<LoanRequestCubit, LoanRequestState>(
            listenWhen: (previous, current) =>
                previous.draftStatus != current.draftStatus &&
                current.draftStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<LoanRequestCubit, LoanRequestState>(
            listenWhen: (previous, current) =>
                previous.otpStatus != current.otpStatus &&
                current.otpStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<LoanRequestCubit, LoanRequestState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus &&
                current.submissionStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<LoanRequestCubit, LoanRequestState>(
            listenWhen: (previous, current) =>
                previous.cancellationStatus != current.cancellationStatus &&
                current.cancellationStatus == RequestStatus.failure,
            listener: _showFailure,
          ),
          BlocListener<LoanRequestCubit, LoanRequestState>(
            listenWhen: (previous, current) =>
                previous.effect != current.effect && current.effect != null,
            listener: _handleEffect,
          ),
        ],
        child: BlocBuilder<LoanRequestCubit, LoanRequestState>(
          builder: (context, state) {
            return PopScope(
              canPop: state.effect == LoanRequestEffect.exit,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop &&
                    state.catalogStatus != RequestStatus.loading &&
                    state.quoteStatus != RequestStatus.loading &&
                    state.inquiryStatus != RequestStatus.loading &&
                    state.guarantorStatus != RequestStatus.loading &&
                    state.collateralStatus != RequestStatus.loading &&
                    state.draftStatus != RequestStatus.loading &&
                    state.otpStatus != RequestStatus.loading &&
                    state.submissionStatus != RequestStatus.loading &&
                    state.cancellationStatus != RequestStatus.loading) {
                  context.read<LoanRequestCubit>().requestBack();
                }
              },
              child: Scaffold(
                backgroundColor: context.colors.surfaceSubtle,
                body: SafeArea(
                  child: Column(
                    children: [
                      AppTopBar(
                        title: S.current.loanRequestTitle,
                        showLeadingActions: false,
                        leadingAction:
                            (state.step == LoanApplicationStep.introduction ||
                                (state.step == LoanApplicationStep.assessment &&
                                    state.deposit == null))
                            ? AppTopBarAction(
                                asset:
                                    '${AppConstants.baseImage}loan_request_report.svg',
                                tooltip: S.current.loanRequestReports,
                                onPressed: () {
                                  context.push<void>(AppRoutes.requestReports);
                                },
                              )
                            : null,
                        trailingIcon: const AvpImage(
                          image:
                              '${AppConstants.baseImage}deposit_list_back.svg',
                          width: 24,
                          height: 24,
                        ),
                        trailingTooltip: S.current.backLabel,
                        isTrailingActive:
                            state.catalogStatus != RequestStatus.loading &&
                            state.quoteStatus != RequestStatus.loading &&
                            state.inquiryStatus != RequestStatus.loading &&
                            state.guarantorStatus != RequestStatus.loading &&
                            state.collateralStatus != RequestStatus.loading &&
                            state.draftStatus != RequestStatus.loading &&
                            state.otpStatus != RequestStatus.loading &&
                            state.submissionStatus != RequestStatus.loading &&
                            state.cancellationStatus != RequestStatus.loading,
                        onTrailingPressed: context
                            .read<LoanRequestCubit>()
                            .requestBack,
                      ),
                      Expanded(
                        child: LoanRequestContent(
                          state: state,
                          scrollController: _scrollController,
                        ),
                      ),
                      if (state.catalogStatus == RequestStatus.success &&
                          (state.step != LoanApplicationStep.assessment ||
                              state.deposit != null))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: AppButton(
                            label: loanPrimaryActionLabel(
                              state.step,
                              state.assessment?.range,
                            ),
                            trailingIcon:
                                state.step == LoanApplicationStep.contract
                                ? null
                                : const AvpImage(
                                    image:
                                        '${AppConstants.baseImage}loan_request_next.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                            size: AppButtonSize.lg,
                            isActive: state.canContinue,
                            isLoading:
                                state.inquiryStatus == RequestStatus.loading ||
                                state.collateralStatus ==
                                    RequestStatus.loading ||
                                state.draftStatus == RequestStatus.loading ||
                                state.otpStatus == RequestStatus.loading,
                            onPressed: context
                                .read<LoanRequestCubit>()
                                .continueFlow,
                          ),
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
