import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/cheque_book_cubit.dart';
import 'cheque_book_residence_card.dart';

class ChequeBookResidency extends StatelessWidget {
  const ChequeBookResidency({super.key, required this.state});
  final ChequeBookState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.colors.errorSubtle,
            borderRadius: AppRadius.borderSm,
          ),
          child: Row(
            children: [
              const AvpImage(
                image: '${AppConstants.baseImage}chequebook_warning.svg',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: S.current.chequeBookResidencyWarningStart),
                      TextSpan(
                        text: S.current.chequeBookRegistryName,
                        style: certificateLabelStyle(context)
                            .copyWith(color: context.colors.error),
                      ),
                      TextSpan(text: S.current.chequeBookResidencyWarningEnd),
                    ],
                  ),
                  style: certificateLabelStyle(context)
                      .copyWith(fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          state.isAddressDeletionAvailable && !state.hasRegisteredResidence
              ? S.current.chequeBookMultipleMissingNotice
              : S.current.chequeBookMissingNotice,
          style: certificateLabelStyle(context)
              .copyWith(fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppRadius.borderSm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  S.current.chequeBookRegistryUrlLabel,
                  style: certificateLabelStyle(context)
                      .copyWith(fontWeight: FontWeight.w400),
                ),
              ),
              InkWell(
                onTap: context.read<ChequeBookCubit>().requestRegistry,
                child: Text(
                  S.current.chequeBookRegistryHost,
                  textDirection: TextDirection.ltr,
                  style: certificateLabelStyle(context).copyWith(
                    color: context.colors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: S.current.chequeBookAddressesNoticeStart),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: InkWell(
                  onTap: context
                      .read<ChequeBookCubit>()
                      .requestUnavailableContent,
                  child: Text(
                    S.current.chequeBookMyAddresses,
                    style: certificateLabelStyle(context)
                        .copyWith(color: context.colors.primary),
                  ),
                ),
              ),
              TextSpan(text: S.current.chequeBookAddressesNoticeEnd),
            ],
          ),
          style: certificateLabelStyle(context)
              .copyWith(fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 20),
        const AvpImage(
          image: '${AppConstants.baseImage}issuance_divider.svg',
          height: .5,
          fit: BoxFit.fill,
        ),
        const SizedBox(height: 20),
        Text(
          state.isAddressDeletionAvailable
              ? S.current.chequeBookResidences
              : S.current.chequeBookResidence,
          style: certificateLabelStyle(context)
              .copyWith(fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 12),
        for (final residence in state.residency!.residences) ...[
          ChequeBookResidenceCard(
            residence: residence,
            canDelete: state.isAddressDeletionAvailable && state.isEditable,
            onDelete: () => context
                .read<ChequeBookCubit>()
                .requestDeleteAddress(residence.address),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
