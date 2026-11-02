import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/on_site_transfer_cubit.dart';
import 'transfer_labels.dart';
import 'transfer_schedule_form.dart';
import 'transfer_destinations.dart';
import 'transfer_confirmation.dart';

class TransferForm extends StatelessWidget {
  const TransferForm({super.key, required this.controller});
  final ScrollController controller;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnSiteTransferCubit, OnSiteTransferState>(
      builder: (context, state) {
        if (state.catalogStatus == RequestStatus.failure) {
          return Center(
            child: AppButton(
              isLoading: state.catalogStatus == RequestStatus.loading,
              label: S.current.dashboardRetry,
              onPressed: () {
                context.read<OnSiteTransferCubit>().fetchCatalog();
              },
            ),
          );
        }
        if (state.catalogStatus != RequestStatus.success) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 76),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppStepper(
                currentStep: state.stepNumber,
                totalSteps: 4,
                title: transferStepTitle(state.step),
                supportingText: transferStepSupporting(state.step),
              ),
              const SizedBox(height: 26),
              if (state.step == OnSiteTransferStep.source ||
                  state.step == OnSiteTransferStep.visit)
                TransferScheduleForm(state: state),
              if (state.step == OnSiteTransferStep.destinations)
                TransferDestinations(state: state),
              if (state.step == OnSiteTransferStep.confirmation)
                TransferConfirmation(state: state),
            ],
          ),
        );
      },
    );
  }
}
