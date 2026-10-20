import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/on_site_transfer_cubit.dart';

import 'package:flutter/services.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_service_sheet.dart';

Future<void> showTransferDestinationSheet(BuildContext context) {
  return showAppServiceSheet<void>(
    context,
    BlocProvider.value(
      value: context.read<OnSiteTransferCubit>(),
      child: const TransferDestinationSheet(),
    ),
  );
}

class TransferDestinationSheet extends StatelessWidget {
  const TransferDestinationSheet({super.key});
  @override
  Widget build(BuildContext context) {
    // Keyboard insets keep the authored form and its actions reachable.
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBottomSheetHeader(
            title: S.current.transferAddDestination,
            showLeftAction: false,
            showRightIcon: false,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: BlocBuilder<OnSiteTransferCubit, OnSiteTransferState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CertificateInput(
                      label: S.current.transferAmount,
                      hint: S.current.transferAmountHint,
                      value: state.amountInput,
                      numeric: true,
                      maxLength: 16,
                      enabled: state.destinationStatus != RequestStatus.loading,
                      errorText: state.isAmountError
                          ? S.current.transferAmountError
                          : null,
                      addonEnd: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          S.current.rialCurrency,
                          style: certificateValueStyle(context),
                        ),
                      ),
                      onChanged: (value) {
                        context.read<OnSiteTransferCubit>().updateAmount(value);
                      },
                    ),
                    const SizedBox(height: 20),
                    CertificateSelect<TransferMethod>(
                      label: S.current.transferMethod,
                      hint: S.current.transferMethodHint,
                      value: state.method,
                      trailing: AvpImage(
                        image: state.method == null
                            ? AppAssets.issuanceSelectEmpty
                            : AppAssets.cardFeaturesChevron,
                        width: 20,
                        height: 20,
                      ),
                      enabled: state.destinationStatus != RequestStatus.loading,
                      options: [
                        AppSelectOption(
                          value: TransferMethod.satna,
                          label: S.current.transferSatna,
                        ),
                      ],
                      onChanged: (method) {
                        context.read<OnSiteTransferCubit>().selectMethod(
                          method,
                        );
                      },
                    ),
                    if (state.method != null) ...[
                      const SizedBox(height: 20),
                      AvpImage(
                        image: AppAssets.issuanceDivider,
                        height: 1,
                        width: double.infinity,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        S.current.cardFeatureIban,
                        style: certificateLabelStyle(context),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        value: state.ibanInput,
                        hintText: S.current.transferIbanHint,
                        enabled:
                            state.destinationStatus != RequestStatus.loading,
                        normalizeDigits: true,
                        maxLength: 24,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textStyle: certificateValueStyle(context),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'IR',
                            textDirection: TextDirection.ltr,
                            style: certificateValueStyle(context),
                          ),
                        ),
                        errorText: state.isIbanError
                            ? S.current.transferIbanError
                            : null,
                        onChanged: (value) {
                          context.read<OnSiteTransferCubit>().updateIban(value);
                        },
                      ),
                      const SizedBox(height: 20),
                      CertificateSelect<TransferPurpose>(
                        label: S.current.transferPurpose,
                        hint: S.current.transferPurposeHint,
                        value: state.purpose,
                        trailing: AvpImage(
                          image: state.purpose == null
                              ? AppAssets.issuanceSelectEmpty
                              : AppAssets.cardFeaturesChevron,
                          width: 20,
                          height: 20,
                        ),
                        enabled:
                            state.destinationStatus != RequestStatus.loading,
                        options: [
                          AppSelectOption(
                            value: TransferPurpose.salary,
                            label: S.current.transferSalary,
                          ),
                        ],
                        onChanged: (purpose) {
                          context.read<OnSiteTransferCubit>().selectPurpose(
                            purpose,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      CertificateInput(
                        label: S.current.transferDescription,
                        hint: S.current.transferDescriptionHint,
                        value: state.description,
                        maxLength: 200,
                        enabled:
                            state.destinationStatus != RequestStatus.loading,
                        onChanged: (value) {
                          context.read<OnSiteTransferCubit>().updateDescription(
                            value,
                          );
                        },
                      ),
                    ],
                    if (state.destinationFailure != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        S.current.dashboardLoadError,
                        style: certificateLabelStyle(context)
                            .copyWith(color: context.colors.error),
                      ),
                    ],
                    const SizedBox(height: 32),
                    Row(
                      textDirection: TextDirection.ltr,
                      children: [
                        Expanded(
                          child: AppButton(
                            label: S.current.transferSave,
                            size: AppButtonSize.lg,
                            disabledAppearance:
                                AppButtonDisabledAppearance.service,
                            isLoading:
                                state.destinationStatus ==
                                RequestStatus.loading,
                            onPressed: state.canAddDestination
                                ? () {
                                    context
                                        .read<OnSiteTransferCubit>()
                                        .submitDestination();
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
