import '../widgets/virtual_card_content.dart';
import '../widgets/virtual_card_footer.dart';

import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/features/cards/domain/repositories/virtual_card_repository.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_top_bar.dart';

import '../../../domain/entities/virtual_card_data.dart';
import '../../../data/repositories/mock_virtual_card_repository.dart';
import '../cubit/virtual_card_cubit.dart';

class VirtualCardRequestScreen extends StatefulWidget {
  const VirtualCardRequestScreen({
    super.key,
    this.repository,
    this.initialDepositNumber,
    this.onTermsRequested,
    this.onSubmitted,
  });
  final VirtualCardRepository? repository;
  final String? initialDepositNumber;
  final VoidCallback? onTermsRequested;
  final ValueChanged<VirtualCardReceipt>? onSubmitted;
  @override
  State<VirtualCardRequestScreen> createState() =>
      _VirtualCardRequestScreenState();
}

class _VirtualCardRequestScreenState extends State<VirtualCardRequestScreen> {
  // This State owns the Cubit; input changes restart the flow without widget keys.
  late VirtualCardCubit _cubit;
  VirtualCardCubit _createCubit() => VirtualCardCubit(
    repository: widget.repository ?? MockVirtualCardRepository(),
    initialDepositNumber: widget.initialDepositNumber,
  )..load();

  final count = TextEditingController();
  @override
  void initState() {
    super.initState();
    _cubit = _createCubit();
  }

  @override
  void didUpdateWidget(VirtualCardRequestScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.initialDepositNumber != widget.initialDepositNumber) {
      _cubit.close();
      _cubit = _createCubit();
      count.clear();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    count.dispose();
    super.dispose();
  }

  void _back(BuildContext context) {
    if (context.read<VirtualCardCubit>().state.submissionStatus !=
        RequestStatus.loading) {
      NavigationActions.back(context);
    }
  }

  void _receipt(BuildContext context, VirtualCardReceipt receipt) {
    widget.onSubmitted?.call(receipt);
    if (!mounted) return;
    NavigationActions.returnHome(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VirtualCardCubit>.value(
      value: _cubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<VirtualCardCubit, VirtualCardState>(
          listenWhen: (a, b) =>
              a.status != b.status ||
              a.quoteStatus != b.quoteStatus ||
              a.submissionStatus != b.submissionStatus,
          listener: (context, state) {
            if (state.submissionStatus == RequestStatus.success &&
                state.receipt != null) {
              _receipt(context, state.receipt!);
            }
          },
          builder: (context, state) => PopScope<void>(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _back(context);
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
                      onTrailingPressed: () => _back(context),
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
    );
  }
}
