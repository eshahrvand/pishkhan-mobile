import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/cheque_cancellation_cubit.dart';

class ChequeCancellationConfirmation extends StatelessWidget {
  const ChequeCancellationConfirmation({super.key, required this.state});
  final ChequeCancellationState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.current.chequeCancelLetterPrompt,
          style: certificateValueStyle(context)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: S.current.chequeCancelDownload,
          variant: AppButtonVariant.secondaryColor,
          size: AppButtonSize.sm,
          leadingIcon: const AvpImage(
            image: AppAssets.chequeCancelDownload,
            width: 20,
            height: 20,
          ),
          onPressed: state.isEditable
              ? context.read<ChequeCancellationCubit>().requestLetter
              : null,
        ),
        const SizedBox(height: 20),
        const AvpImage(
          image: AppAssets.issuanceDivider,
          height: 1,
          fit: BoxFit.fill,
        ),
        const SizedBox(height: 20),
        Text(
          S.current.chequeCancelMailInstruction,
          style: certificateValueStyle(context)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: state.isEditable
              ? context.read<ChequeCancellationCubit>().requestPostalOffices
              : null,
          borderRadius: AppRadius.borderSm,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border.all(color: context.colors.border),
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              children: [
                const AvpImage(
                  image: AppAssets.chequeClearanceEnvelope,
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.current.chequePostalAction,
                    style: certificateValueStyle(context),
                  ),
                ),
                const AvpImage(
                  image: AppAssets.cardFeaturesChevron,
                  width: 20,
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
