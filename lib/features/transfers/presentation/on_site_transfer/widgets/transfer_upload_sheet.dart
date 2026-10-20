import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/on_site_transfer_cubit.dart';

import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_file_upload_base.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';

Future<bool?> showTransferUploadSheet(BuildContext context) {
  return showAppServiceSheet<bool>(
    context,
    BlocProvider.value(
      value: context.read<OnSiteTransferCubit>(),
      child: const TransferUploadSheet(),
    ),
  );
}

class TransferUploadSheet extends StatelessWidget {
  const TransferUploadSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<OnSiteTransferCubit, OnSiteTransferState>(
          buildWhen: (previous, current) =>
              previous.uploadName != current.uploadName,
          builder: (context, state) {
            return AppBottomSheetHeader(
              type: state.uploadName.isEmpty
                  ? AppBottomSheetHeaderType.withHeader
                  : AppBottomSheetHeaderType.handleOnly,
              showTitle: false,
              showRightIcon: false,
              onLeftAction: () {
                Navigator.of(context).pop(false);
              },
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: BlocBuilder<OnSiteTransferCubit, OnSiteTransferState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppFileUploadBase(
                    state: switch (state.uploadStatus) {
                      RequestStatus.loading => AppFileUploadState.uploading,
                      RequestStatus.success => AppFileUploadState.uploaded,
                      _ => AppFileUploadState.empty,
                    },
                    fileName: state.uploadName,
                    fileSize:
                        '${(state.uploadSizeBytes / 1024).toStringAsFixed(1)} KB',
                    progress: state.uploadProgress,
                    emptyPrompt: S.current.transferUploadBefore,
                    emptyAction: S.current.transferUploadAction,
                    emptySuffix: S.current.transferUploadAfter,
                    fileRequirements: S.current.transferFileRequirements,
                    onSelect: () {
                      context.read<OnSiteTransferCubit>().requestFilePicker();
                    },
                    onDelete: () {
                      context.read<OnSiteTransferCubit>().removeUpload();
                    },
                  ),
                  if (state.uploadFailure != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      S.current.transferFileInvalid,
                      style: certificateLabelStyle(context)
                          .copyWith(color: context.colors.error),
                    ),
                  ],
                  if (state.uploadName.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        Expanded(
                          child: AppButton(
                            label: S.current.transferReview,
                            size: AppButtonSize.lg,
                            disabledAppearance:
                                AppButtonDisabledAppearance.service,
                            onPressed: state.canReviewFile
                                ? () {
                                    Navigator.of(context).pop(true);
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            label: S.current.dashboardCancel,
                            size: AppButtonSize.lg,
                            variant: AppButtonVariant.secondaryGray,
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
