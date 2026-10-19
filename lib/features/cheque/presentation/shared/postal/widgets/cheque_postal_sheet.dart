import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:pishkhan_mobile/core/platform/platform_share.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../../../domain/entities/cheque_clearance.dart';
import '../cubit/cheque_postal_cubit.dart';

import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import 'cheque_postal_results.dart';

Future<void> showChequePostalSheet(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: context.colors.textPrimary.withValues(alpha: .4),
    builder: (_) => BlocProvider(
      create: (_) => ChequePostalCubit()..fetchProvinces(),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: const ChequePostalSheet(),
      ),
    ),
  );
}

class ChequePostalSheet extends StatelessWidget {
  const ChequePostalSheet({super.key});
  Future<void> _handleEffect(
    BuildContext context,
    ChequePostalState state,
  ) async {
    try {
      await PlatformShare.shareText(state.postalShareText!);
    } on PlatformException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.chequeShareUnavailable)),
        );
      }
    } on MissingPluginException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.current.chequeShareUnavailable)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChequePostalCubit, ChequePostalState>(
      listenWhen: (previous, current) => previous.effectId != current.effectId,
      listener: _handleEffect,
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: PopScope(
            canPop: state.postalStep == ChequePostalStep.location,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                context.read<ChequePostalCubit>().requestPostalSearch();
              }
            },
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * .9,
              ),
              decoration: BoxDecoration(
                color: context.colors.surfaceSubtle,
                borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppBottomSheetHeader(
                      title: S.current.chequePostalTitle,
                      showRightIcon: false,
                      onLeftAction: () => Navigator.of(context).pop(),
                    ),
                    if (state.provincesStatus == RequestStatus.loading)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      )
                    else if (state.provincesStatus == RequestStatus.failure)
                      AppButton(
                        label: S.current.dashboardRetry,
                        onPressed: context
                            .read<ChequePostalCubit>()
                            .fetchProvinces,
                      )
                    else if (state.postalStep == ChequePostalStep.results)
                      Flexible(child: ChequePostalResults(state: state))
                    else
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            20,
                            20,
                            24 + MediaQuery.viewInsetsOf(context).bottom,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppSelect<PostalProvince>(
                                label: S.current.chequeProvinceLabel,
                                labelStyle: certificateLabelStyle(context),
                                labelSpacing: 8,
                                hintText: S.current.chequeProvinceHint,
                                textStyle: certificateValueStyle(context)
                                    .copyWith(
                                      color: state.province == null
                                          ? context.colors.textDisabled
                                          : context.colors.textPrimary,
                                    ),
                                trailing: AvpImage(
                                  image: state.province == null
                                      ? AppAssets.issuanceSelectEmpty
                                      : AppAssets.cardFeaturesChevron,
                                  width: 20,
                                  height: 20,
                                ),
                                value: state.province,
                                enabled:
                                    state.postalOfficesStatus !=
                                    RequestStatus.loading,
                                options: [
                                  for (final province in state.provinces)
                                    AppSelectOption(
                                      value: province,
                                      label: province.name,
                                    ),
                                ],
                                onChanged: context
                                    .read<ChequePostalCubit>()
                                    .selectProvince,
                              ),
                              const SizedBox(height: 20),
                              AppSelect<PostalCity>(
                                label: S.current.chequeCityLabel,
                                labelStyle: certificateLabelStyle(context),
                                labelSpacing: 8,
                                hintText: S.current.chequeCityHint,
                                textStyle: certificateValueStyle(context)
                                    .copyWith(
                                      color: state.city == null
                                          ? context.colors.textDisabled
                                          : context.colors.textPrimary,
                                    ),
                                trailing: AvpImage(
                                  image: state.city == null
                                      ? AppAssets.issuanceSelectEmpty
                                      : AppAssets.cardFeaturesChevron,
                                  width: 20,
                                  height: 20,
                                ),
                                value: state.city,
                                enabled:
                                    state.postalOfficesStatus !=
                                    RequestStatus.loading,
                                options: [
                                  for (final city in state.cities)
                                    AppSelectOption(
                                      value: city,
                                      label: city.name,
                                    ),
                                ],
                                onChanged: state.province != null
                                    ? context
                                          .read<ChequePostalCubit>()
                                          .selectCity
                                    : null,
                              ),
                              const SizedBox(height: 32),
                              if (state.postalOfficesStatus ==
                                  RequestStatus.failure) ...[
                                Text(
                                  S.current.chequePostalFailure,
                                  style: certificateLabelStyle(context)
                                      .copyWith(color: context.colors.error),
                                ),
                                const SizedBox(height: 12),
                              ],
                              AppButton(
                                label: S.current.chequePostalSearch,
                                size: AppButtonSize.lg,
                                disabledAppearance:
                                    AppButtonDisabledAppearance.service,
                                isLoading:
                                    state.postalOfficesStatus ==
                                    RequestStatus.loading,
                                onPressed: state.canSearchPostalOffices
                                    ? context
                                          .read<ChequePostalCubit>()
                                          .searchPostalOffices
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
