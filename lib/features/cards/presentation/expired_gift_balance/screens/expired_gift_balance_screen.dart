import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../domain/entities/card_service_data.dart';
import '../../shared/card_service_widgets.dart';
import '../cubit/expired_gift_balance_cubit.dart';
import '../widgets/gift_balance_selection.dart';
import '../widgets/gift_balance_destination.dart';
import '../widgets/gift_balance_sheets.dart';

class ExpiredGiftBalanceScreen extends StatefulWidget {
  const ExpiredGiftBalanceScreen({
    super.key,
    this.onTermsRequested,
    this.onCompleted,
  });

  final VoidCallback? onTermsRequested;
  final ValueChanged<CardServiceReceipt>? onCompleted;

  @override
  State<ExpiredGiftBalanceScreen> createState() =>
      _ExpiredGiftBalanceScreenState();
}

class _ExpiredGiftBalanceScreenState extends State<ExpiredGiftBalanceScreen> {
  Future<void> _handleNavigation(
    BuildContext context,
    ExpiredGiftBalanceState state,
  ) async {
    switch (state.navigation) {
      case FlowNavigation.confirmExit:
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<ExpiredGiftBalanceCubit>().exitConfirmationResult(
            confirmed,
          );
        }
      case FlowNavigation.back:
        // Wait for PopScope to rebuild with the authorized exit intent.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case FlowNavigation.home:
        NavigationActions.returnHome(context);
      case null:
        break;
    }
  }

  Future<void> _handleEffect(
    BuildContext context,
    ExpiredGiftBalanceState state,
  ) async {
    switch (state.effect) {
      case GiftBalanceEffect.filter:
        await showGiftBalanceFilter(
          context,
          context.read<ExpiredGiftBalanceCubit>(),
        );
        if (context.mounted) {
          context.read<ExpiredGiftBalanceCubit>().cancelFilter();
        }
      case GiftBalanceEffect.review:
        final result = await showGiftBalanceReview(
          context,
          context.read<ExpiredGiftBalanceCubit>(),
        );
        if (context.mounted) {
          context.read<ExpiredGiftBalanceCubit>().reviewResult(result);
        }
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExpiredGiftBalanceCubit>(
      create: (_) => ExpiredGiftBalanceCubit()..load(),
      child: BlocListener<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>(
        listenWhen: (previous, current) =>
            previous.navigationId != current.navigationId,
        listener: _handleNavigation,
        child: BlocListener<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>(
          listenWhen: (previous, current) =>
              previous.effectId != current.effectId,
          listener: _handleEffect,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child:
                BlocConsumer<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>(
                  listenWhen: (previous, current) =>
                      previous.step != current.step ||
                      previous.submissionStatus != current.submissionStatus,
                  listener: (context, state) {
                    if (state.receipt != null) {
                      widget.onCompleted?.call(state.receipt!);
                    }
                  },
                  builder: (context, state) {
                    return PopScope(
                      canPop: state.navigation == FlowNavigation.back,
                      onPopInvokedWithResult: (didPop, _) {
                        if (!didPop) {
                          context.read<ExpiredGiftBalanceCubit>().requestBack();
                        }
                      },
                      child: Scaffold(
                        backgroundColor: context.colors.surfaceSubtle,
                        body: SafeArea(
                          child: Column(
                            children: [
                              AppTopBar(
                                title: S.current.giftBalanceTitle,
                                showLeadingActions: false,
                                leadingAction: SizedBox.square(
                                  dimension: 40,
                                  child: AppButton(
                                    variant: AppButtonVariant.text,
                                    tooltip: S.current.giftBalanceSelectedList(
                                      state.selectedCards.length,
                                    ),
                                    onPressed: state.canContinue
                                        ? () => context
                                              .read<ExpiredGiftBalanceCubit>()
                                              .requestReview()
                                        : null,
                                    icon: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        cardServiceIcon(
                                          AppAssets.giftBalanceList,
                                          size: 24,
                                        ),
                                        if (state.selectedCards.isNotEmpty)
                                          Positioned(
                                            left: 14,
                                            bottom: 0,
                                            child: Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: context.colors.success,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                trailingIcon: cardServiceIcon(
                                  AppAssets.cardFeaturesBack,
                                  size: 24,
                                ),
                                trailingTooltip: S.current.backLabel,
                                onTrailingPressed: context
                                    .read<ExpiredGiftBalanceCubit>()
                                    .requestBack,
                              ),
                              if ((state.status == RequestStatus.success &&
                                  !state.isEmpty &&
                                  state.receipt == null))
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    10,
                                  ),
                                  child: AppStepper(
                                    currentStep: state.step.index + 1,
                                    totalSteps: 2,
                                    title:
                                        state.step == GiftBalanceStep.selection
                                        ? S.current.giftBalanceSelection
                                        : S.current.giftBalanceDestination,
                                    supportingText:
                                        state.step == GiftBalanceStep.selection
                                        ? S.current.giftBalanceNextDestination
                                        : S.current.giftBalanceEnd,
                                    semanticLabel: S.current
                                        .issuanceStepSemantic(
                                          state.step.index + 1,
                                          2,
                                          state.step ==
                                                  GiftBalanceStep.selection
                                              ? S.current.giftBalanceSelection
                                              : S
                                                    .current
                                                    .giftBalanceDestination,
                                        ),
                                  ),
                                ),
                              Expanded(
                                child:
                                    (state.status == RequestStatus.success &&
                                        !state.isEmpty &&
                                        state.receipt == null)
                                    ? state.step == GiftBalanceStep.selection
                                          ? GiftBalanceSelection(
                                              cubit: context
                                                  .read<
                                                    ExpiredGiftBalanceCubit
                                                  >(),
                                              state: state,
                                              onFilter: context
                                                  .read<
                                                    ExpiredGiftBalanceCubit
                                                  >()
                                                  .requestFilter,
                                            )
                                          : GiftBalanceDestination(
                                              cubit: context
                                                  .read<
                                                    ExpiredGiftBalanceCubit
                                                  >(),
                                              state: state,
                                            )
                                    : CardServiceStatus(
                                        status: state.status,
                                        empty: state.isEmpty,
                                        receipt: state.receipt,
                                        onRetry: context
                                            .read<ExpiredGiftBalanceCubit>()
                                            .load,
                                      ),
                              ),
                              if ((state.status == RequestStatus.success &&
                                  !state.isEmpty &&
                                  state.receipt == null))
                                CardServiceFooter(
                                  label: state.step == GiftBalanceStep.selection
                                      ? S.current.giftBalanceNext
                                      : S.current.giftBalanceSubmit,
                                  loading:
                                      state.submissionStatus ==
                                      RequestStatus.loading,
                                  onSubmit:
                                      (state.step == GiftBalanceStep.selection
                                          ? state.canContinue
                                          : state.canSubmit)
                                      ? context
                                            .read<ExpiredGiftBalanceCubit>()
                                            .continueFlow
                                      : null,
                                  termsAccepted:
                                      state.step == GiftBalanceStep.selection
                                      ? null
                                      : state.termsAccepted,
                                  onTermsChanged: state.editable
                                      ? context
                                            .read<ExpiredGiftBalanceCubit>()
                                            .acceptTerms
                                      : null,
                                  onTermsRequested: widget.onTermsRequested,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ),
      ),
    );
  }
}
