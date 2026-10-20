import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/flow/flow_navigation.dart';
import 'package:pishkhan_mobile/core/router/app_routes.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/deposit_request_footer.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../../shared/modern_bank_receipt.dart';
import '../../shared/modern_bank_terms.dart';
import '../cubit/transfer_limits_cubit.dart';
import '../widgets/mobile_bank_limits_form.dart';

class MobileBankLimitsScreen extends StatelessWidget {
  const MobileBankLimitsScreen({super.key});
  Future<void> _handleNavigation(
    BuildContext context,
    TransferLimitsState state,
  ) async {
    switch (state.navigation) {
      case FlowNavigation.confirmExit:
        final result = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<TransferLimitsCubit>().applyExitConfirmation(result);
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
      create: (_) => TransferLimitsCubit()..fetchLimits(),
      child: BlocListener<TransferLimitsCubit, TransferLimitsState>(
        listenWhen: (previous, current) =>
            previous.effectId != current.effectId,
        listener: _handleNavigation,
        child: BlocBuilder<TransferLimitsCubit, TransferLimitsState>(
          builder: (context, state) {
            return PopScope(
              canPop: state.navigation == FlowNavigation.back,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) context.read<TransferLimitsCubit>().requestBack();
              },
              child: Scaffold(
                backgroundColor: context.colors.surfaceSubtle,
                body: SafeArea(
                  child: Column(
                    children: [
                      AppTopBar(
                        title: S.current.modernLimitsTitle,
                        showLeadingActions: false,
                        trailingIcon: SizedBox.square(
                          dimension: 24,
                          child: AvpImage(image: AppAssets.depositFeatureBack),
                        ),
                        trailingTooltip: S.current.backLabel,
                        onTrailingPressed: () {
                          context.read<TransferLimitsCubit>().requestBack();
                        },
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
                                  label: S.current.dashboardRetry,
                                  onPressed: () {
                                    context
                                        .read<TransferLimitsCubit>()
                                        .fetchLimits();
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
                                child:
                                    state.submissionStatus ==
                                        RequestStatus.success
                                    ? ModernBankReceipt(
                                        message: S.current.modernLimitsSaved,
                                      )
                                    : MobileBankLimitsForm(state: state),
                              ),
                            Positioned(
                              left: 16,
                              bottom: 16,
                              child: AppAssistantButton(
                                onPressed: () {
                                  context
                                      .read<TransferLimitsCubit>()
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
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: AppButton(
                              label: S.current.passwordUnderstood,
                              size: AppButtonSize.lg,
                              onPressed: () {
                                context
                                    .read<TransferLimitsCubit>()
                                    .requestHome();
                              },
                            ),
                          )
                        else if (state.isEditing)
                          DepositRequestFooter(
                            submitLabel: S.current.passwordChangeSubmit,
                            termsAccepted: state.termsAccepted,
                            onTermsChanged:
                                state.submissionStatus == RequestStatus.loading
                                ? null
                                : (value) {
                                    context
                                        .read<TransferLimitsCubit>()
                                        .updateTermsAccepted(value);
                                  },
                            onTermsRequested: () {
                              showModernBankTerms(context);
                            },
                            onSubmit: state.canSubmit
                                ? () {
                                    context
                                        .read<TransferLimitsCubit>()
                                        .submitLimits();
                                  }
                                : null,
                            isLoading:
                                state.submissionStatus == RequestStatus.loading,
                            errorText:
                                state.submissionStatus == RequestStatus.failure
                                ? S.current.cardServiceSubmitError
                                : null,
                            bottomPadding: 16,
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: AppButton(
                              label: S.current.modernEdit,
                              size: AppButtonSize.lg,
                              onPressed: () {
                                context
                                    .read<TransferLimitsCubit>()
                                    .openEditor();
                              },
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
