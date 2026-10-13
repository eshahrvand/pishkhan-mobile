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

class ExpiredGiftBalanceScreen extends StatefulWidget {
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
  State<ExpiredGiftBalanceScreen> createState() =>
      _ExpiredGiftBalanceScreenState();
}

class _ExpiredGiftBalanceScreenState extends State<ExpiredGiftBalanceScreen> {
  late ExpiredGiftBalanceCubit cubit = _createCubit();

  ExpiredGiftBalanceCubit _createCubit() => ExpiredGiftBalanceCubit(
    repository: widget.repository ?? MockCardServicesRepository(),
  )..load();

  @override
  void didUpdateWidget(covariant ExpiredGiftBalanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      cubit.close();
      cubit = _createCubit();
    }
  }

  void _back() {
    if (!cubit.back()) NavigationActions.back(context);
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: BlocConsumer<ExpiredGiftBalanceCubit, ExpiredGiftBalanceState>(
      bloc: cubit,
      listenWhen: (old, next) =>
          old.step != next.step ||
          old.submissionStatus != next.submissionStatus,
      listener: (context, state) {
        if (state.receipt != null) widget.onCompleted?.call(state.receipt!);
      },
      builder: (context, state) {
        final l = context.l10n;
        final selection = state.step == GiftBalanceStep.selection;
        final loading = state.submissionStatus == RequestStatus.loading;
        final empty =
            state.catalog?.gifts.isEmpty == true ||
            state.catalog?.deposits.isEmpty == true;
        final form =
            state.status == RequestStatus.success &&
            !empty &&
            state.receipt == null;
        return PopScope(
          canPop: !loading && (selection || state.receipt != null),
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
                    onTrailingPressed: _back,
                  ),
                  if (form)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: AppStepper(
                        currentStep: selection ? 1 : 2,
                        totalSteps: 2,
                        title: selection
                            ? l.giftBalanceSelection
                            : l.giftBalanceDestination,
                        supportingText: selection
                            ? l.giftBalanceNextDestination
                            : l.giftBalanceEnd,
                        semanticLabel: l.issuanceStepSemantic(
                          selection ? 1 : 2,
                          2,
                          selection
                              ? l.giftBalanceSelection
                              : l.giftBalanceDestination,
                        ),
                      ),
                    ),
                  Expanded(
                    child: form
                        ? selection
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
                            empty: empty,
                            receipt: state.receipt,
                            onRetry: cubit.load,
                          ),
                  ),
                  if (form)
                    CardServiceFooter(
                      label: selection
                          ? l.giftBalanceNext
                          : l.giftBalanceSubmit,
                      loading: loading,
                      onSubmit: selection
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
                      termsAccepted: selection ? null : state.termsAccepted,
                      onTermsChanged: state.editable ? cubit.acceptTerms : null,
                      onTermsRequested: widget.onTermsRequested,
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
