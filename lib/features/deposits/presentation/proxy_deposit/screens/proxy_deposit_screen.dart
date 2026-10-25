import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_assistant_button.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/proxy_deposit_cubit.dart';
import '../widgets/proxy_deposit_footer.dart';
import '../widgets/proxy_deposit_form.dart';
import '../widgets/proxy_deposit_receipt_dialog.dart';

class ProxyDepositScreen extends StatelessWidget {
  const ProxyDepositScreen({
    super.key,
    this.initialDepositNumber,
    this.onAssistantPressed,
  });
  final String? initialDepositNumber;
  final VoidCallback? onAssistantPressed;

  Future<void> _handleEffect(
    BuildContext context,
    ProxyDepositState state,
  ) async {
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    switch (state.effect) {
      case ProxyDepositEffect.confirmExit:
        context.read<ProxyDepositCubit>().consumeProxyDepositInteraction();
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<ProxyDepositCubit>().applyExitConfirmation(confirmed);
        }
      case ProxyDepositEffect.back:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case ProxyDepositEffect.home:
        NavigationActions.returnHome(context);
      case ProxyDepositEffect.assistant:
        context.read<ProxyDepositCubit>().consumeProxyDepositInteraction();
        NavigationActions.returnHome(context);
        onAssistantPressed?.call();
      case ProxyDepositEffect.termsUnavailable:
        context.read<ProxyDepositCubit>().consumeProxyDepositInteraction();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.issuanceTermsUnavailable)),
        );
      case null:
        break;
    }
  }

  Future<void> _handleReceipt(
    BuildContext context,
    ProxyDepositState state,
  ) async {
    await showProxyDepositReceiptDialog(context, state.receipt!);
    if (context.mounted) {
      context.read<ProxyDepositCubit>().applyReceiptDismissal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProxyDepositCubit(initialDepositNumber: initialDepositNumber)
            ..fetchCatalog(),
      child: BlocListener<ProxyDepositCubit, ProxyDepositState>(
        listenWhen: (previous, current) =>
            previous.submissionStatus != current.submissionStatus &&
            current.submissionStatus == RequestStatus.success,
        listener: _handleReceipt,
        child: BlocConsumer<ProxyDepositCubit, ProxyDepositState>(
          listenWhen: (previous, current) =>
              (previous.effect != current.effect &&
                  current.effect != null) ||
              ((previous.catalogStatus != current.catalogStatus &&
                      current.catalogStatus == RequestStatus.failure) ||
                  (previous.submissionStatus != current.submissionStatus &&
                      current.submissionStatus == RequestStatus.failure)),
          listener: _handleEffect,

          builder: (context, state) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: PopScope(
                canPop:
                    (state.catalogStatus != RequestStatus.loading &&
                        state.submissionStatus != RequestStatus.loading) &&
                    (state.effect == ProxyDepositEffect.back),
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop &&
                      state.catalogStatus != RequestStatus.loading &&
                      state.submissionStatus != RequestStatus.loading) {
                    context.read<ProxyDepositCubit>().requestBack();
                  }
                },
                child: Scaffold(
                  backgroundColor: context.colors.surfaceSubtle,
                  body: SafeArea(
                    child: Column(
                      children: [
                        AppTopBar(
                          title: S.current.proxyDeposit,
                          showLeadingActions: false,
                          leadingAction: const SizedBox.shrink(),
                          trailingIcon: depositIcon(
                            '${AppConstants.baseImage}deposit_list_back.svg',
                          ),
                          trailingTooltip: S.current.backLabel,
                          onTrailingPressed:
                              (state.catalogStatus != RequestStatus.loading &&
                                  state.submissionStatus !=
                                      RequestStatus.loading)
                              ? context.read<ProxyDepositCubit>().requestBack
                              : null,
                        ),
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              const ProxyDepositForm(),
                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: AppAssistantButton(
                                  onPressed: context
                                      .read<ProxyDepositCubit>()
                                      .requestAssistant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const ProxyDepositFooter(),
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
