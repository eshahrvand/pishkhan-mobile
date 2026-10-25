import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../widgets/virtual_card_content.dart';
import '../widgets/virtual_card_footer.dart';

import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../domain/entities/virtual_card_data.dart';
import '../cubit/virtual_card_cubit.dart';

class VirtualCardRequestScreen extends StatefulWidget {
  const VirtualCardRequestScreen({
    super.key,
    this.initialDepositNumber,
    this.onTermsRequested,
    this.onSubmitted,
  });
  final String? initialDepositNumber;
  final VoidCallback? onTermsRequested;
  final ValueChanged<VirtualCardReceipt>? onSubmitted;
  @override
  State<VirtualCardRequestScreen> createState() =>
      _VirtualCardRequestScreenState();
}

class _VirtualCardRequestScreenState extends State<VirtualCardRequestScreen> {
  final count = TextEditingController();
  @override
  void dispose() {
    count.dispose();
    super.dispose();
  }

  Future<void> _handleNavigation(
    BuildContext context,
    VirtualCardState state,
  ) async {
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    switch (state.navigation) {
      case FlowNavigation.confirmExit:
        context.read<VirtualCardCubit>().consumeVirtualCardInteraction();
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<VirtualCardCubit>().applyExitConfirmation(confirmed);
        }
      case FlowNavigation.back:
        // Wait for PopScope to rebuild with the authorized exit intent.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) NavigationActions.back(context);
        });
      case FlowNavigation.home:
        widget.onSubmitted?.call(state.receipt!);
        if (context.mounted) NavigationActions.returnHome(context);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VirtualCardCubit>(
      create: (_) =>
          VirtualCardCubit(initialDepositNumber: widget.initialDepositNumber)
            ..fetchCatalog(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<VirtualCardCubit, VirtualCardState>(
          listenWhen: (previous, current) =>
              (previous.navigation != current.navigation &&
                  current.navigation != null) ||
              ((previous.catalogStatus != current.catalogStatus &&
                      current.catalogStatus == RequestStatus.failure) ||
                  (previous.quoteStatus != current.quoteStatus &&
                      current.quoteStatus == RequestStatus.failure) ||
                  (previous.submissionStatus != current.submissionStatus &&
                      current.submissionStatus == RequestStatus.failure)),
          listener: _handleNavigation,
          builder: (context, state) {
            return PopScope<void>(
              canPop:
                  (state.catalogStatus != RequestStatus.loading &&
                      state.quoteStatus != RequestStatus.loading &&
                      state.submissionStatus != RequestStatus.loading) &&
                  (state.navigation == FlowNavigation.back),
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop &&
                    state.catalogStatus != RequestStatus.loading &&
                    state.quoteStatus != RequestStatus.loading &&
                    state.submissionStatus != RequestStatus.loading) {
                  context.read<VirtualCardCubit>().requestBack();
                }
              },
              child: Scaffold(
                backgroundColor: context.colors.surfaceSubtle,
                body: SafeArea(
                  child: Column(
                    children: [
                      AppTopBar(
                        title: S.current.virtualRequestTitle,
                        showLeadingActions: false,
                        trailingIcon: SizedBox.square(
                          dimension: 24,
                          child: AvpImage(
                            image:
                                '${AppConstants.baseImage}virtual_request_back.svg',
                          ),
                        ),
                        trailingTooltip: S.current.backLabel,
                        onTrailingPressed:
                            (state.catalogStatus != RequestStatus.loading &&
                                state.quoteStatus != RequestStatus.loading &&
                                state.submissionStatus != RequestStatus.loading)
                            ? () =>
                                  context.read<VirtualCardCubit>().requestBack()
                            : null,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                          child: VirtualCardContent(count: count, state: state),
                        ),
                      ),
                      if (state.catalog != null &&
                          state.catalog?.deposits.isNotEmpty == true)
                        VirtualCardFooter(
                          state: state,
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
    );
  }
}
