import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/on_site_transfer_cubit.dart';

import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_delivery_address.dart';

import 'transfer_date_field.dart';
import 'transfer_notice.dart';

class TransferScheduleForm extends StatelessWidget {
  const TransferScheduleForm({super.key, required this.state});
  final OnSiteTransferState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          state.step == OnSiteTransferStep.source
              ? S.current.transferSourcePrompt
              : S.current.transferVisitPrompt,
          style: certificateValueStyle(context)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        if (state.step == OnSiteTransferStep.source) ...[
          CertificateSelect<TransferDeposit>(
            label: S.current.virtualRequestDepositLabel,
            hint: S.current.issuanceDepositHint,
            value: state.deposit,
            trailing: AvpImage(
              image: state.deposit == null
                  ? '${AppConstants.baseImage}issuance_select_empty.svg'
                  : '${AppConstants.baseImage}card_features_chevron.svg',
              width: 20,
              height: 20,
            ),
            enabled: state.submissionStatus != RequestStatus.loading,
            options: [
              for (final deposit in state.catalog!.deposits)
                AppSelectOption(value: deposit, label: deposit.number),
            ],
            onChanged: (deposit) {
              context.read<OnSiteTransferCubit>().selectDeposit(deposit);
            },
          ),
          const SizedBox(height: 20),
          AvpImage(
            image: '${AppConstants.baseImage}issuance_divider.svg',
            width: double.infinity,
            height: 1,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 20),
          TransferDateField(
            label: S.current.transferDate,
            hint: S.current.transferDateHint,
            value: state.transferDateInput,
            enabled: state.submissionStatus != RequestStatus.loading,
            errorText: state.isTransferDateError
                ? S.current.transferDateError
                : null,
            onChanged: (value) {
              context.read<OnSiteTransferCubit>().updateTransferDate(value);
            },
          ),
          const SizedBox(height: 20),
          TransferNotice(text: S.current.transferHolidayNotice),
          const SizedBox(height: 16),
          TransferNotice(text: S.current.transferCutoffNotice),
        ] else ...[
          // The address section is the same shared composition used by certificates.
          // Disable edits during submission while retaining system/in-app Back.
          AbsorbPointer(
            absorbing: state.submissionStatus == RequestStatus.loading,
            child: CertificateDeliveryAddress(
              addressLabel: S.current.issuanceAddress,
              addressHint: S.current.transferAddressHint,
              trailing: AvpImage(
                image: state.address == null
                    ? '${AppConstants.baseImage}issuance_select_empty.svg'
                    : '${AppConstants.baseImage}card_features_chevron.svg',
                width: 20,
                height: 20,
              ),
              addresses: state.addresses,
              address: state.address,
              onAddress: (DeliveryAddress address) {
                context.read<OnSiteTransferCubit>().selectAddress(address);
              },
              onAddAddress: () {
                context.read<OnSiteTransferCubit>().requestAddressEditor();
              },
              onDeleteAddress: () {
                context.read<OnSiteTransferCubit>().requestAddressDeletion();
              },
            ),
          ),
          const SizedBox(height: 20),
          AvpImage(
            image: '${AppConstants.baseImage}issuance_divider.svg',
            width: double.infinity,
            height: 1,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 20),
          TransferDateField(
            label: S.current.transferVisitDate,
            hint: S.current.transferVisitDateHint,
            value: state.visitDateInput,
            enabled: state.submissionStatus != RequestStatus.loading,
            errorText: state.isVisitDateError
                ? S.current.transferVisitDateError
                : null,
            onChanged: (value) {
              context.read<OnSiteTransferCubit>().updateVisitDate(value);
            },
          ),
        ],
      ],
    );
  }
}
