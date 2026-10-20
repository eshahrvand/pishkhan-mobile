import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../../../domain/entities/cheque_cancellation.dart';
import '../../../domain/entities/cheque_clearance.dart';
import '../cubit/cheque_cancellation_cubit.dart';
import 'cheque_cancellation_labels.dart';

class ChequeCancellationSelection extends StatelessWidget {
  const ChequeCancellationSelection({super.key, required this.state});
  final ChequeCancellationState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.current.chequeCancelSelectionPrompt,
          style: certificateValueStyle(context)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        AppSelect<ChequeDeposit>(
          label: S.current.issuanceDeposit,
          hintText: S.current.chequeCancelDepositHint,
          value: state.deposit,
          labelSpacing: 8,
          labelStyle: certificateLabelStyle(context),
          textStyle: certificateValueStyle(context).copyWith(
            color: state.deposit == null
                ? context.colors.textDisabled
                : context.colors.textPrimary,
          ),
          trailing: AvpImage(
            image: state.deposit == null
                ? AppAssets.issuanceSelectEmpty
                : AppAssets.cardFeaturesChevron,
            width: 20,
            height: 20,
          ),
          enabled: state.isEditable,
          options: [
            for (final deposit in state.catalog!.deposits)
              AppSelectOption(value: deposit, label: deposit.number),
          ],
          onChanged: context.read<ChequeCancellationCubit>().selectDeposit,
        ),
        const SizedBox(height: 20),
        AppSelect<CancellationChequeType>(
          label: S.current.chequeCancelType,
          hintText: S.current.chequeCancelTypeHint,
          value: state.type,
          labelSpacing: 8,
          labelStyle: certificateLabelStyle(context),
          textStyle: certificateValueStyle(context).copyWith(
            color: state.type == null
                ? context.colors.textDisabled
                : context.colors.textPrimary,
          ),
          trailing: AvpImage(
            image: state.type == null
                ? AppAssets.issuanceSelectEmpty
                : AppAssets.cardFeaturesChevron,
            width: 20,
            height: 20,
          ),
          enabled: state.isEditable,
          options: [
            for (final type in state.catalog!.types)
              AppSelectOption(value: type, label: cancellationTypeLabel(type)),
          ],
          onChanged: context.read<ChequeCancellationCubit>().selectType,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppPasswordServiceColors.cameraNotice,
            borderRadius: AppRadius.borderSm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AvpImage(
                image: AppAssets.passwordCameraInfo,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  S.current.chequeCancelSelectionNotice,
                  style: certificateLabelStyle(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
