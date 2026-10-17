import 'package:pishkhan_mobile/shared/widgets/flow_exit_dialog.dart';

import '../widgets/virtual_card_content.dart';
import '../widgets/virtual_card_footer.dart';

import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
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

  void _receipt(BuildContext context, VirtualCardReceipt receipt) {
    widget.onSubmitted?.call(receipt);
    if (!mounted) return;
    context.read<VirtualCardCubit>().receiptPresentationClosed();
  }

  Future<void> _handleNavigation(
    BuildContext context,
    VirtualCardState state,
  ) async {
    switch (state.navigation) {
      case FlowNavigation.confirmExit:
        final confirmed = await showFlowExitDialog(context);
        if (context.mounted) {
          context.read<VirtualCardCubit>().exitConfirmationResult(confirmed);
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VirtualCardCubit>(
      create: (_) =>
          VirtualCardCubit(initialDepositNumber: widget.initialDepositNumber)
            ..load(),
      child: BlocListener<VirtualCardCubit, VirtualCardState>(
        listenWhen: (previous, current) =>
            previous.navigationId != current.navigationId,
        listener: _handleNavigation,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocConsumer<VirtualCardCubit, VirtualCardState>(
            listenWhen: (previous, current) =>
                previous.status != current.status ||
                previous.quoteStatus != current.quoteStatus ||
                previous.submissionStatus != current.submissionStatus,
            listener: (context, state) {
              if (state.submissionStatus == RequestStatus.success &&
                  state.receipt != null) {
                _receipt(context, state.receipt!);
              }
            },

            builder: (context, state) => PopScope<void>(
              canPop: state.navigation == FlowNavigation.back,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) context.read<VirtualCardCubit>().requestBack();
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
                          child: AvpImage(image: AppAssets.virtualRequestBack),
                        ),
                        trailingTooltip: S.current.backLabel,
                        onTrailingPressed: () =>
                            context.read<VirtualCardCubit>().requestBack(),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                          child: VirtualCardContent(count: count),
                        ),
                      ),
                      if (state.catalog != null &&
                          state.catalog?.deposits.isNotEmpty == true)
                        VirtualCardFooter(
                          onTermsRequested: widget.onTermsRequested,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
