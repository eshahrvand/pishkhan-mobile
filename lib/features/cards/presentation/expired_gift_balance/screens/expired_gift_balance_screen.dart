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
import '../widgets/gift_balance_filter_sheet.dart';
import '../widgets/gift_balance_review_sheet.dart';

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
          context.read<ExpiredGiftBalanceCubit>().applyExitConfirmation(
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
        final result = await showGiftBalanceFilter(
          context,
          context.read<ExpiredGiftBalanceCubit>(),
        );
        if (context.mounted) {
          context.read<ExpiredGiftBalanceCubit>().applyFilterResult(result);
        }
      case GiftBalanceEffect.review:
        final result = await showGiftBalanceReview(
          context,
          context.read<ExpiredGiftBalanceCubit>(),
        );
        if (context.mounted) {
          context.read<ExpiredGiftBalanceCubit>().applyReviewResult(result);
        }
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExpiredGiftBalanceCubit>(
      create: (_) => ExpiredGiftBalanceCubit()..fetchCatalog(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>(
            listenWhen: (previous, current) =>
                previous.navigationId != current.navigationId,
            listener: _handleNavigation,
          ),
          BlocListener<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>(
            listenWhen: (previous, current) =>
                previous.effectId != current.effectId,
            listener: _handleEffect,
          ),
        ],
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocConsumer<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus &&
                current.submissionStatus == RequestStatus.success,
            listener: (context, state) {
              widget.onCompleted?.call(state.receipt!);
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
                              onPressed: state.canReviewSelection
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
                        if ((state.catalogStatus == RequestStatus.success &&
                            !state.isCatalogEmpty &&
                            state.receipt == null))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                            child: AppStepper(
                              currentStep: state.stepNumber,
                              totalSteps: 2,
                              title: state.step == GiftBalanceStep.selection
                                  ? S.current.giftBalanceSelection
                                  : S.current.giftBalanceDestination,
                              supportingText:
                                  state.step == GiftBalanceStep.selection
                                  ? S.current.giftBalanceNextDestination
                                  : S.current.giftBalanceEnd,
                              semanticLabel: S.current.issuanceStepSemantic(
                                state.stepNumber,
                                2,
                                state.step == GiftBalanceStep.selection
                                    ? S.current.giftBalanceSelection
                                    : S.current.giftBalanceDestination,
                              ),
                            ),
                          ),
                        Expanded(
                          child:
                              (state.catalogStatus == RequestStatus.success &&
                                  !state.isCatalogEmpty &&
                                  state.receipt == null)
                              ? state.step == GiftBalanceStep.selection
                                    ? GiftBalanceSelection(state: state)
                                    : GiftBalanceDestination(state: state)
                              : CardServiceStatus(
                                  status: state.catalogStatus,
                                  empty: state.isCatalogEmpty,
                                  receipt: state.receipt,
                                  onRetry: context
                                      .read<ExpiredGiftBalanceCubit>()
                                      .fetchCatalog,
                                ),
                        ),
                        if ((state.catalogStatus == RequestStatus.success &&
                            !state.isCatalogEmpty &&
                            state.receipt == null))
                          CardServiceFooter(
                            label: state.step == GiftBalanceStep.selection
                                ? S.current.giftBalanceNext
                                : S.current.giftBalanceSubmit,
                            loading:
                                state.submissionStatus == RequestStatus.loading,
                            onSubmit: state.canContinue
                                ? context
                                      .read<ExpiredGiftBalanceCubit>()
                                      .submitCurrentStep
                                : null,
                            termsAccepted:
                                state.step == GiftBalanceStep.selection
                                ? null
                                : state.termsAccepted,
                            onTermsChanged: state.isEditable
                                ? context
                                      .read<ExpiredGiftBalanceCubit>()
                                      .updateTermsAcceptance
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
    );
  }
}
