import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../../../domain/entities/cheque_cancellation.dart';
import '../cubit/cheque_cancellation_cubit.dart';

Future<void> showChequeCancellationDeleteSheet(
  BuildContext context,
  CancellableCheque cheque,
) {
  return showAppServiceSheet<void>(
    context,
    BlocProvider.value(
      value: context.read<ChequeCancellationCubit>(),
      child: ChequeCancellationDeleteSheet(cheque: cheque),
    ),
    scrimColor: context.colors.textSecondary.withValues(alpha: .9),
  );
}

class ChequeCancellationDeleteSheet extends StatelessWidget {
  const ChequeCancellationDeleteSheet({super.key, required this.cheque});
  final CancellableCheque cheque;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppBottomSheetHeader(type: AppBottomSheetHeaderType.handleOnly),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              Text(
                S.current.chequeCancelRemovePrompt,
                style: certificateValueStyle(context)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: S.current.dashboardCancel,
                      variant: AppButtonVariant.secondaryGray,
                      size: AppButtonSize.lg,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: S.current.chequeCancelRemove,
                      isDestructive: true,
                      size: AppButtonSize.lg,
                      onPressed: () {
                        context.read<ChequeCancellationCubit>().removeCheque(
                          cheque,
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
