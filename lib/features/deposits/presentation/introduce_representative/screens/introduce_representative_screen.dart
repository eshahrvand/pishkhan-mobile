import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/representative_cubit.dart';
import '../widgets/representative_footer.dart';
import '../widgets/representative_initial_form.dart';
import '../widgets/representative_list.dart';
import '../widgets/representative_receipt_dialog.dart';
import '../widgets/representative_sheet.dart';

class IntroduceRepresentativeScreen extends StatelessWidget {
  const IntroduceRepresentativeScreen({super.key, this.initialDepositNumber});
  final String? initialDepositNumber;

  Future<void> _handleEffect(
    BuildContext context,
    RepresentativeState state,
  ) async {
    switch (state.effect) {
      case RepresentativeEffect.addNext:
        await showRepresentativeSheet(
          context,
          context.read<RepresentativeCubit>(),
        );
      case RepresentativeEffect.confirmExit:
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<RepresentativeCubit>().applyExitConfirmation(confirmed);
        }
      case RepresentativeEffect.back:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case RepresentativeEffect.home:
        NavigationActions.returnHome(context);
      case null:
        break;
    }
  }

  Future<void> _handleReceipt(
    BuildContext context,
    RepresentativeState state,
  ) async {
    await showRepresentativeReceiptDialog(context, state.receipt!);
    if (context.mounted) {
      context.read<RepresentativeCubit>().applyReceiptDismissal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RepresentativeCubit(initialDepositNumber: initialDepositNumber)
            ..fetchDeposits(),
      child: BlocListener<RepresentativeCubit, RepresentativeState>(
        listenWhen: (previous, current) =>
            previous.submissionStatus != current.submissionStatus &&
            current.submissionStatus == RequestStatus.success,
        listener: _handleReceipt,
        child: BlocConsumer<RepresentativeCubit, RepresentativeState>(
          listenWhen: (previous, current) =>
              previous.effectId != current.effectId,
          listener: _handleEffect,
          buildWhen: (previous, current) => previous.effect != current.effect,
          builder: (context, state) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: PopScope(
                canPop: state.effect == RepresentativeEffect.back,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) {
                    context.read<RepresentativeCubit>().requestBack();
                  }
                },
                child: Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Column(
                      children: [
                        AppTopBar(
                          title: S.current.representativeTitle,
                          showLeadingActions: false,
                          leadingAction: const SizedBox.shrink(),
                          trailingIcon: depositIcon(
                            AppAssets.depositFeatureBack,
                          ),
                          trailingTooltip: S.current.backLabel,
                          onTrailingPressed: context
                              .read<RepresentativeCubit>()
                              .requestBack,
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  72,
                                ),
                                child:
                                    BlocBuilder<
                                      RepresentativeCubit,
                                      RepresentativeState
                                    >(
                                      buildWhen: (previous, current) =>
                                          previous.depositsStatus !=
                                              current.depositsStatus ||
                                          previous.deposits.isEmpty !=
                                              current.deposits.isEmpty ||
                                          previous.representatives.isEmpty !=
                                              current.representatives.isEmpty,
                                      builder: (context, state) {
                                        switch (state.depositsStatus) {
                                          case RequestStatus.initial:
                                          case RequestStatus.loading:
                                            return const IgnorePointer(
                                              child: Opacity(
                                                opacity: .45,
                                                child:
                                                    RepresentativeInitialForm(),
                                              ),
                                            );
                                          case RequestStatus.failure:
                                            return Column(
                                              children: [
                                                if (state.depositsFailure !=
                                                    null)
                                                  Text(
                                                    S
                                                        .current
                                                        .dashboardLoadError,
                                                  ),
                                                AppButton(
                                                  label:
                                                      S.current.dashboardRetry,
                                                  onPressed: context
                                                      .read<
                                                        RepresentativeCubit
                                                      >()
                                                      .fetchDeposits,
                                                ),
                                              ],
                                            );
                                          case RequestStatus.success:
                                            if (state.deposits.isEmpty) {
                                              return Text(
                                                S.current.depositsEmpty,
                                              );
                                            }
                                            return state.representatives.isEmpty
                                                ? const RepresentativeInitialForm()
                                                : const RepresentativeList();
                                        }
                                      },
                                    ),
                              ),
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: AppAssistantButton(
                                  onPressed: context
                                      .read<RepresentativeCubit>()
                                      .requestHome,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const RepresentativeFooter(),
                      ],
                    ),
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
