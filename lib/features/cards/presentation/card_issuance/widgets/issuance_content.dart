import 'package:pishkhan_mobile/core/router/navigation_actions.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/issuance_data.dart';
import '../cubit/card_issuance_cubit.dart';
import '../widgets/issuance_sections.dart';

class IssuanceContent extends StatelessWidget {
  const IssuanceContent({
    super.key,
    required this.scroll,
    required this.onDeleteAddress,
  });
  final ScrollController scroll;
  final ValueChanged<IssuanceAddress> onDeleteAddress;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardIssuanceCubit, CardIssuanceState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.catalog != current.catalog ||
          previous.submissionStatus != current.submissionStatus ||
          previous.receipt != current.receipt ||
          previous.step != current.step ||
          previous.editable != current.editable,
      builder: (context, state) {
        if (state.status == RequestStatus.initial ||
            state.status == RequestStatus.loading) {
          return Center(
            child: AppButton(
              onPressed: null,
              isLoading: true,
              label: S.current.dashboardLoading,
            ),
          );
        }
        if (state.status == RequestStatus.failure ||
            (state.catalog?.deposits.isEmpty == true ||
                state.catalog?.types.isEmpty == true)) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (state.catalog?.deposits.isEmpty == true ||
                            state.catalog?.types.isEmpty == true)
                        ? S.current.issuanceEmpty
                        : S.current.dashboardLoadError,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    onPressed: context
                        .read<CardIssuanceCubit>()
                        .fetchIssuanceCatalog,
                    label: S.current.dashboardRetry,
                  ),
                ],
              ),
            ),
          );
        }
        if (state.submissionStatus == RequestStatus.success) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.receipt!.isMock
                        ? S.current.issuanceMockComplete
                        : S.current.issuanceComplete,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(state.receipt!.reference),
                  const SizedBox(height: 24),
                  AppButton(
                    onPressed: () => NavigationActions.returnHome(context),
                    label: S.current.issuanceDone,
                  ),
                ],
              ),
            ),
          );
        }
        return SingleChildScrollView(
          controller: scroll,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            (state.step == IssuanceStep.confirmation) ? 196 : 136,
          ),
          child: AbsorbPointer(
            absorbing: !state.editable,
            child: switch (state.step) {
              IssuanceStep.selection => IssuanceSelection(),
              IssuanceStep.delivery => IssuanceDelivery(
                onAddAddress: context
                    .read<CardIssuanceCubit>()
                    .requestAddAddress,
                onDeleteAddress: onDeleteAddress,
              ),
              IssuanceStep.confirmation => IssuanceConfirmation(),
            },
          ),
        );
      },
    );
  }
}
