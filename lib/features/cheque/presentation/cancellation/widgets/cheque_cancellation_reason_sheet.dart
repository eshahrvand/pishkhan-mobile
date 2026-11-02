import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/cheque_cancellation.dart';
import '../cubit/cheque_cancellation_cubit.dart';
import 'cheque_cancellation_labels.dart';

Future<void> showChequeCancellationReasonSheet(BuildContext context) {
  final cubit = context.read<ChequeCancellationCubit>();
  return showAppSelectSheetContent<void>(
    context,
    builder: (context) {
      return BlocProvider.value(
        value: cubit,
        child: const ChequeCancellationReasonSheet(),
      );
    },
  );
}

class ChequeCancellationReasonSheet extends StatelessWidget {
  const ChequeCancellationReasonSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChequeCancellationCubit, ChequeCancellationState>(
      builder: (context, state) {
        return AppSelectSheet<ChequeCancellationReason>(
          title: state.isReasonForAll
              ? S.current.chequeCancelAllReasonsTitle
              : S.current.chequeCancelReason,
          options: [
            for (final reason in state.catalog!.reasons)
              AppSelectOption(
                value: reason,
                label: cancellationReasonLabel(reason),
              ),
          ],
          selected: state.reasonDraft,
          showSelectionIndicator: true,
          onSelected: (reason) {
            context.read<ChequeCancellationCubit>().selectReasonDraft(reason);
          },
          onClose: () {
            Navigator.of(context).pop();
          },
          footer: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: S.current.dashboardCancel,
                  variant: AppButtonVariant.secondaryGray,
                  size: AppButtonSize.lg,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: S.current.chequeCancelChoose,
                  size: AppButtonSize.lg,
                  disabledAppearance: AppButtonDisabledAppearance.service,
                  onPressed: state.reasonDraft != null
                      ? () {
                          context.read<ChequeCancellationCubit>().applyReason();
                          Navigator.of(context).pop();
                        }
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
