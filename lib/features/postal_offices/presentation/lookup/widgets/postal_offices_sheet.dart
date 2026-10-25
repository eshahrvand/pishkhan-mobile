import 'package:pishkhan_mobile/core/config/constant.dart';

import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:pishkhan_mobile/core/platform/platform_share.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../../domain/entities/postal_office.dart';
import '../cubit/postal_offices_cubit.dart';

import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import 'postal_offices_results.dart';

Future<void> showPostalOfficesSheet(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: context.colors.textPrimary.withValues(alpha: .4),
    builder: (_) => BlocProvider(
      create: (_) => PostalOfficesCubit()..fetchProvinces(),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: const PostalOfficesSheet(),
      ),
    ),
  );
}

class PostalOfficesSheet extends StatelessWidget {
  const PostalOfficesSheet({super.key});
  Future<void> _handleEffect(
    BuildContext context,
    PostalOfficesState state,
  ) async {
    if (state.message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.message!)));
      return;
    }

    switch (state.effect) {
      case PostalOfficesEffect.share:
        context.read<PostalOfficesCubit>().consumePostalOfficesInteraction();
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

      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostalOfficesCubit, PostalOfficesState>(
      listenWhen: (previous, current) =>
          (previous.effect != current.effect && current.effect != null) ||
          ((previous.provincesStatus != current.provincesStatus &&
                  current.provincesStatus == RequestStatus.failure) ||
              (previous.postalOfficesStatus != current.postalOfficesStatus &&
                  current.postalOfficesStatus == RequestStatus.failure)),
      listener: _handleEffect,
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: PopScope(
            canPop:
                (state.provincesStatus != RequestStatus.loading &&
                    state.postalOfficesStatus != RequestStatus.loading) &&
                (state.postalStep == PostalOfficesStep.location),
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop &&
                  state.provincesStatus != RequestStatus.loading &&
                  state.postalOfficesStatus != RequestStatus.loading) {
                context.read<PostalOfficesCubit>().requestPostalSearch();
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
                      onLeftAction:
                          (state.provincesStatus != RequestStatus.loading &&
                              state.postalOfficesStatus !=
                                  RequestStatus.loading)
                          ? () => Navigator.of(context).pop()
                          : null,
                    ),
                    if (state.provincesStatus == RequestStatus.loading)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      )
                    else if (state.provincesStatus == RequestStatus.failure)
                      AppButton(
                        isLoading:
                            state.provincesStatus == RequestStatus.loading,
                        label: S.current.dashboardRetry,
                        onPressed: context
                            .read<PostalOfficesCubit>()
                            .fetchProvinces,
                      )
                    else if (state.postalStep == PostalOfficesStep.results)
                      Flexible(child: PostalOfficesResults(state: state))
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
                                      ? '${AppConstants.baseImage}issuance_select_empty.svg'
                                      : '${AppConstants.baseImage}card_features_chevron.svg',
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
                                    .read<PostalOfficesCubit>()
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
                                      ? '${AppConstants.baseImage}issuance_select_empty.svg'
                                      : '${AppConstants.baseImage}card_features_chevron.svg',
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
                                          .read<PostalOfficesCubit>()
                                          .selectCity
                                    : null,
                              ),
                              const SizedBox(height: 32),

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
                                          .read<PostalOfficesCubit>()
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
