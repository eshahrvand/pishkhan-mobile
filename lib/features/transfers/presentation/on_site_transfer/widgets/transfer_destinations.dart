import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/on_site_transfer_cubit.dart';

import 'package:pishkhan_mobile/shared/widgets/app_transfer_destination_card.dart';
import 'package:pishkhan_mobile/shared/widgets/app_file_upload_base.dart';

import 'transfer_notice.dart';

class TransferDestinations extends StatelessWidget {
  const TransferDestinations({super.key, required this.state});
  final OnSiteTransferState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.current.transferDestinationPrompt,
          style: certificateValueStyle(context)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        if (state.destinations.isEmpty && state.attachment == null) ...[
          AppButton(
            label: S.current.transferAddManual,
            size: AppButtonSize.lg,
            leadingIcon: AvpImage(
              image: '${AppConstants.baseImage}agent_plus.svg',
              width: 20,
              height: 20,
            ),
            isLoading: state.submissionStatus == RequestStatus.loading,
            onPressed: () {
              context.read<OnSiteTransferCubit>().requestDestinationEditor();
            },
          ),
          const SizedBox(height: 20),
          AppButton(
            label: S.current.transferUploadExcel,
            size: AppButtonSize.lg,
            variant: AppButtonVariant.outline,
            leadingIcon: AvpImage(
              image: '${AppConstants.baseImage}onsite_transfer_upload.svg',
              width: 20,
              height: 20,
            ),
            isLoading: state.submissionStatus == RequestStatus.loading,
            onPressed: () {
              context.read<OnSiteTransferCubit>().requestUploadSheet();
            },
          ),
          const SizedBox(height: 20),
          TransferNotice(
            text: S.current.transferSamplePrefix,
            linkText: S.current.transferSampleLink,
            suffix: S.current.transferSampleSuffix,
            onTap: () {
              context.read<OnSiteTransferCubit>().requestUnavailable();
            },
          ),
        ],
        for (final destination in state.destinations) ...[
          AppTransferDestinationCard(
            method: AppTransferMethod.satna,
            recipientName: destination.recipientName,
            depositNumber: destination.iban,
            numberLabel: S.current.cardFeatureIban,
            wrapNumber: true,
            amount: CurrencyFormatter.format(destination.amountRial),
            amountLabel: S.current.transferAmountRial,
            methodTitle: S.current.transferSatna,
            methodLabel: S.current.transferMethodRow,
            purpose: S.current.transferSalary,
            purposeLabel: S.current.transferPurpose,
            depositIdentifier: destination.description,
            identifierLabel: S.current.transferIdentifier,
            deleteLabel: S.current.transferDeleteDestination,
            onDelete: state.submissionStatus != RequestStatus.loading
                ? () {
                    context.read<OnSiteTransferCubit>().removeDestination(
                      destination,
                    );
                  }
                : null,
          ),
          const SizedBox(height: 20),
        ],
        if (state.attachment != null) ...[
          AppFileUploadBase(
            state: AppFileUploadState.uploaded,
            progress: 1,
            fileName: state.attachment!.name,
            onDelete: state.submissionStatus != RequestStatus.loading
                ? () {
                    context.read<OnSiteTransferCubit>().removeAttachment();
                  }
                : null,
            fileSize:
                '${(state.attachment!.sizeBytes / 1024).toStringAsFixed(1)} KB',
          ),
          const SizedBox(height: 12),
          Text(
            S.current.transferFileAccepted,
            style: certificateLabelStyle(context),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: S.current.transferUploadExcel,
            variant: AppButtonVariant.outline,
            isLoading: state.submissionStatus == RequestStatus.loading,
            onPressed: () {
              context.read<OnSiteTransferCubit>().requestUploadSheet();
            },
          ),
        ],
        if (state.destinations.isNotEmpty || state.attachment != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IntrinsicWidth(
              child: AppButton(
                label: S.current.transferAddNext,
                variant: AppButtonVariant.text,
                horizontalPadding: 0,
                leadingIcon: AvpImage(
                  image: '${AppConstants.baseImage}issuance_plus.svg',
                  width: 20,
                  height: 20,
                ),
                isLoading: state.submissionStatus == RequestStatus.loading,
                onPressed: () {
                  context
                      .read<OnSiteTransferCubit>()
                      .requestDestinationEditor();
                },
              ),
            ),
          ),
      ],
    );
  }
}
