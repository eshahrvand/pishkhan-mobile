import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/cheque_cancellation_cubit.dart';
import 'cheque_cancellation_confirmation.dart';
import 'cheque_cancellation_labels.dart';
import 'cheque_cancellation_list.dart';
import 'cheque_cancellation_reasons.dart';
import 'cheque_cancellation_selection.dart';

class ChequeCancellationContent extends StatefulWidget {
  const ChequeCancellationContent({super.key});
  @override
  State<ChequeCancellationContent> createState() =>
      _ChequeCancellationContentState();
}

class _ChequeCancellationContentState extends State<ChequeCancellationContent> {
  final _scrollController = ScrollController();
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _revealStep(BuildContext context, ChequeCancellationState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChequeCancellationCubit, ChequeCancellationState>(
      listenWhen: (previous, current) => previous.step != current.step,
      listener: _revealStep,
      builder: (context, state) {
        if (state.catalogStatus == RequestStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.catalogStatus == RequestStatus.failure) {
          return Center(
            child: AppButton(
              isLoading: state.catalogStatus == RequestStatus.loading,
              label: S.current.dashboardRetry,
              onPressed: context.read<ChequeCancellationCubit>().fetchCatalog,
            ),
          );
        }
        if (state.catalog == null) return const SizedBox.shrink();
        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 76),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppStepper(
                currentStep: state.stepNumber,
                totalSteps: 4,
                title: cancellationStepTitle(state.step),
                supportingText: cancellationNextTitle(state.step),
              ),
              const SizedBox(height: 26),
              if (state.step == ChequeCancellationStep.selection)
                ChequeCancellationSelection(state: state),
              if (state.step == ChequeCancellationStep.cheques)
                ChequeCancellationList(state: state),
              if (state.step == ChequeCancellationStep.reasons)
                ChequeCancellationReasons(state: state),
              if (state.step == ChequeCancellationStep.confirmation)
                ChequeCancellationConfirmation(state: state),
            ],
          ),
        );
      },
    );
  }
}
