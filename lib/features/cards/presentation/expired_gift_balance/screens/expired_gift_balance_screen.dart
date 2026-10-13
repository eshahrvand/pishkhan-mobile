import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../data/repositories/mock_card_services_repository.dart';
import '../../../domain/entities/card_service_data.dart';
import '../../../domain/repositories/card_services_repository.dart';
import '../../shared/card_service_widgets.dart';
import '../cubit/expired_gift_balance_cubit.dart';
import '../widgets/gift_balance_selection.dart';
import '../widgets/gift_balance_destination.dart';
import '../widgets/gift_balance_sheets.dart';

class ExpiredGiftBalanceScreen extends StatelessWidget {
  const ExpiredGiftBalanceScreen({
    super.key,
    this.repository,
    this.onTermsRequested,
    this.onCompleted,
  });

  final CardServicesRepository? repository;
  final VoidCallback? onTermsRequested;
  final ValueChanged<CardServiceReceipt>? onCompleted;

  @override
  Widget build(BuildContext context) => BlocProvider<ExpiredGiftBalanceCubit>(
    // A changed adapter starts a new flow; ordinary rebuilds retain it.
    key: ValueKey(repository),
    lazy: false,
    create: (_) => ExpiredGiftBalanceCubit(
      initialState: const ExpiredGiftBalanceState(),
      repository: repository ?? MockCardServicesRepository(),
    )..load(),
    child: _ExpiredGiftBalanceView(
      onTermsRequested: onTermsRequested,
      onCompleted: onCompleted,
    ),
  );
}

class _ExpiredGiftBalanceView extends StatelessWidget {
  const _ExpiredGiftBalanceView({this.onTermsRequested, this.onCompleted});
  final VoidCallback? onTermsRequested;
  final ValueChanged<CardServiceReceipt>? onCompleted;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: BlocConsumer<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>(
      listenWhen: (old, next) =>
          old.step != next.step ||
          old.submissionStatus != next.submissionStatus,
      listener: (context, state) {
        if (state.receipt != null) onCompleted?.call(state.receipt!);
      },
      builder: (context, state) {
        final cubit = context.read<ExpiredGiftBalanceCubit>();
        final l = context.l10n;
        return PopScope(
          canPop:
              state.submissionStatus != RequestStatus.loading &&
              (state.step == GiftBalanceStep.selection ||
                  state.receipt != null),
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) cubit.back();
          },
          child: Scaffold(
            backgroundColor: context.colors.surfaceSubtle,
            body: SafeArea(
              child: Column(
                children: [
                  AppTopBar(
                    title: l.giftBalanceTitle,
                    showLeadingActions: false,
                    leadingAction: SizedBox.square(
                      dimension: 40,
                      child: AppButton(
                        variant: AppButtonVariant.text,
                        tooltip: l.giftBalanceSelectedList(
                          state.selectedCards.length,
                        ),
                        onPressed: state.canContinue
                            ? () => showGiftBalanceReview(context, cubit)
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
                    trailingTooltip: l.backLabel,
                    onTrailingPressed: () {
                      if (!cubit.back()) NavigationActions.back(context);
                    },
                  ),
                  if ((state.status == RequestStatus.success &&
                      !state.isEmpty &&
                      state.receipt == null))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: AppStepper(
                        currentStep: state.step.index + 1,
                        totalSteps: 2,
                        title: state.step == GiftBalanceStep.selection
                            ? l.giftBalanceSelection
                            : l.giftBalanceDestination,
                        supportingText: state.step == GiftBalanceStep.selection
                            ? l.giftBalanceNextDestination
                            : l.giftBalanceEnd,
                        semanticLabel: l.issuanceStepSemantic(
                          state.step.index + 1,
                          2,
                          state.step == GiftBalanceStep.selection
                              ? l.giftBalanceSelection
                              : l.giftBalanceDestination,
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
                                  cubit: cubit,
                                  state: state,
                                  onFilter: () =>
                                      showGiftBalanceFilter(context, cubit),
                                )
                              : GiftBalanceDestination(
                                  cubit: cubit,
                                  state: state,
                                )
                        : CardServiceStatus(
                            status: state.status,
                            empty: state.isEmpty,
                            receipt: state.receipt,
                            onRetry: cubit.load,
                          ),
                  ),
                  if ((state.status == RequestStatus.success &&
                      !state.isEmpty &&
                      state.receipt == null))
                    CardServiceFooter(
                      label: state.step == GiftBalanceStep.selection
                          ? l.giftBalanceNext
                          : l.giftBalanceSubmit,
                      loading: state.submissionStatus == RequestStatus.loading,
                      onSubmit: state.step == GiftBalanceStep.selection
                          ? state.canContinue
                                ? () => showGiftBalanceReview(
                                    context,
                                    cubit,
                                    advance: true,
                                  )
                                : null
                          : state.canSubmit
                          ? cubit.submit
                          : null,
                      termsAccepted: state.step == GiftBalanceStep.selection
                          ? null
                          : state.termsAccepted,
                      onTermsChanged: state.editable ? cubit.acceptTerms : null,
                      onTermsRequested: onTermsRequested,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
