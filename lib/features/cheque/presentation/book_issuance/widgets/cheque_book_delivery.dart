import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_address_card.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_delivery_recipient.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_delivery_agent.dart';

import '../../../domain/entities/cheque_book.dart';
import '../cubit/cheque_book_cubit.dart';

class ChequeBookDelivery extends StatelessWidget {
  const ChequeBookDelivery({super.key, required this.state});
  final ChequeBookState state;
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !state.isEditable,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.catalog!.applicant == ChequeBookApplicant.legal) ...[
            Text(
              S.current.chequeBookLegalRecipientPrompt,
              style: certificateValueStyle(context)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            CertificateInput(
              label: S.current.chequeBookRecipientName,
              hint: S.current.chequeBookRecipientNameHint,
              value: state.recipientName,
              errorText: state.isRecipientNameError
                  ? S.current.chequeBookRecipientNameInvalid
                  : null,
              onChanged: context.read<ChequeBookCubit>().updateRecipientName,
            ),
            const SizedBox(height: 20),
            CertificateInput(
              label: S.current.chequeBookRecipientNationalId,
              hint: S.current.chequeBookRecipientNationalIdHint,
              value: state.recipientNationalId,
              numeric: true,
              maxLength: 10,
              errorText: state.isRecipientNationalIdError
                  ? S.current.authInvalidNationalId
                  : null,
              onChanged: context
                  .read<ChequeBookCubit>()
                  .updateRecipientNationalId,
            ),
          ] else ...[
            CertificateSelect<DeliveryAddress>(
              label: state.address == null
                  ? S.current.issuanceAddress
                  : S.current.issuanceSelectAddress,
              hint: S.current.certificateAddressHint,
              value: state.address,
              enabled: state.isEditable,
              options: [
                for (final address in state.deliveryAddresses)
                  AppSelectOption(value: address, label: address.title),
              ],
              onChanged: context.read<ChequeBookCubit>().selectAddress,
            ),
            const SizedBox(height: 12),
            if (state.address != null)
              AppAddressCard(
                variant: AppAddressCardVariant.delivery,
                address: state.address!.detail,
                deleteLabel: S.current.issuanceDeleteAddress,
                deleteIcon: const AvpImage(
                  image: '${AppConstants.baseImage}file_upload_trash.svg',
                  width: 20,
                  height: 20,
                ),
                onDeleteTap: () => context
                    .read<ChequeBookCubit>()
                    .requestDeleteAddress(state.address!),
              )
            else
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: SizedBox(
                  width: 139,
                  height: 20,
                  child: AppButton(
                    labelStyle: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 18 / 12,
                      letterSpacing: 0,
                    ),
                    contentGap: 8,
                    constrainLabel: true,
                    label: S.current.issuanceAddAddress,
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.sm,
                    horizontalPadding: 8,
                    leadingIcon: const AvpImage(
                      image: '${AppConstants.baseImage}issuance_plus.svg',
                      width: 20,
                      height: 20,
                    ),
                    onPressed: context
                        .read<ChequeBookCubit>()
                        .requestAddAddress,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const AvpImage(
              image: '${AppConstants.baseImage}issuance_divider.svg',
              height: .5,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 20),
            CertificateDeliveryRecipient(
              otherRecipient: state.isOtherRecipient,
              recipientName: state.recipientName,
              recipientNationalId: state.recipientNationalId,
              nameError: state.isRecipientNameError
                  ? S.current.chequeBookRecipientNameInvalid
                  : null,
              nationalIdError: state.isRecipientNationalIdError
                  ? S.current.authInvalidNationalId
                  : null,
              onOtherRecipient: context
                  .read<ChequeBookCubit>()
                  .updateOtherRecipient,
              onRecipientName: context
                  .read<ChequeBookCubit>()
                  .updateRecipientName,
              onRecipientNationalId: context
                  .read<ChequeBookCubit>()
                  .updateRecipientNationalId,
            ),
            const SizedBox(height: 20),
            const AvpImage(
              image: '${AppConstants.baseImage}issuance_divider.svg',
              height: .5,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 20),
            CertificateDeliveryAgent(
              includeAgent: state.isAgentIncluded,
              agentIdentifier: state.agentIdentifier,
              canCheckAgent: true,
              onIncludeAgent: context
                  .read<ChequeBookCubit>()
                  .updateAgentInclusion,
              onAgent: context.read<ChequeBookCubit>().updateAgentIdentifier,
              onAgentLookup: context
                  .read<ChequeBookCubit>()
                  .requestUnavailableContent,
            ),
          ],
        ],
      ),
    );
  }
}
