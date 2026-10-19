import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../cubit/cheque_clearance_cubit.dart';
import 'cheque_clearance_ui.dart';
import 'cheque_consent_notice.dart';

class ChequePostalInstructions extends StatelessWidget {
  const ChequePostalInstructions({super.key, required this.state});
  final ChequeClearanceState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppPasswordServiceColors.cameraNotice,
            borderRadius: AppRadius.borderSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AvpImage(
                    image: AppAssets.chequeClearanceDocument,
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      S.current.chequeDocumentsTitle,
                      style: chequeLabelStyle(context)
                          .copyWith(color: context.colors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 28),
                child: Text(
                  '•  ${chequeDocumentLabel(state.requiredDocument!)}',
                  style: chequeLabelStyle(context)
                      .copyWith(fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
        if (state.isConsentRequired) ...[
          const SizedBox(height: 12),
          ChequeConsentNotice(isEditable: state.isEditable),
        ],
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppRadius.borderSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AvpImage(
                    image: AppAssets.chequeClearanceEnvelopeEdit,
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      S.current.chequeMailingAddressTitle,
                      style: chequeLabelStyle(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                state.catalog!.mailingAddress,
                style: chequeLabelStyle(context).copyWith(
                  fontWeight: FontWeight.w400,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const AvpImage(
                image: AppAssets.chequeClearanceAddressDivider,
                height: 1,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 10),
              Text(
                S.current.chequeMailingInstruction,
                style: chequeLabelStyle(context)
                    .copyWith(fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Semantics(
          button: true,
          child: InkWell(
            onTap: state.isEditable
                ? context.read<ChequeClearanceCubit>().requestPostalOffices
                : null,
            borderRadius: AppRadius.borderSm,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border.all(color: context.colors.border),
                borderRadius: AppRadius.borderSm,
                boxShadow: AppShadows.xs,
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
                      style: chequeValueStyle(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const AvpImage(
                    image: AppAssets.cardFeaturesChevron,
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
