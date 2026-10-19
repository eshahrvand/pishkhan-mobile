import 'dart:ui' as ui;

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../../domain/entities/cheque_clearance.dart';
import '../cubit/cheque_clearance_cubit.dart';
import 'cheque_clearance_ui.dart';
import 'cheque_postal_results.dart';

Future<void> showChequePostalSheet(BuildContext context) {
  final cubit = context.read<ChequeClearanceCubit>();
  FocusManager.instance.primaryFocus?.unfocus();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: context.colors.textPrimary.withValues(alpha: .4),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: const ChequePostalSheet(),
      ),
    ),
  );
}

class ChequePostalSheet extends StatelessWidget {
  const ChequePostalSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChequeClearanceCubit, ChequeClearanceState>(
      buildWhen: (previous, current) =>
          previous.postalStep != current.postalStep ||
          previous.province != current.province ||
          previous.city != current.city ||
          previous.postalOfficesStatus != current.postalOfficesStatus ||
          previous.catalog != current.catalog,
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: PopScope(
            canPop: state.postalStep == ChequePostalStep.location,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                context.read<ChequeClearanceCubit>().requestPostalSearch();
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
                    if (state.postalStep == ChequePostalStep.results)
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
                                labelStyle: chequeLabelStyle(context),
                                labelSpacing: 8,
                                hintText: S.current.chequeProvinceHint,
                                textStyle: chequeValueStyle(context).copyWith(
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
                                  for (final province
                                      in state.catalog!.provinces)
                                    AppSelectOption(
                                      value: province,
                                      label: province.name,
                                    ),
                                ],
                                onChanged: context
                                    .read<ChequeClearanceCubit>()
                                    .selectProvince,
                              ),
                              const SizedBox(height: 20),
                              AppSelect<PostalCity>(
                                label: S.current.chequeCityLabel,
                                labelStyle: chequeLabelStyle(context),
                                labelSpacing: 8,
                                hintText: S.current.chequeCityHint,
                                textStyle: chequeValueStyle(context).copyWith(
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
                                          .read<ChequeClearanceCubit>()
                                          .selectCity
                                    : null,
                              ),
                              const SizedBox(height: 32),
                              if (state.postalOfficesStatus ==
                                  RequestStatus.failure) ...[
                                Text(
                                  S.current.chequePostalFailure,
                                  style: chequeLabelStyle(context)
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
                                          .read<ChequeClearanceCubit>()
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
