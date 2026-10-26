import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_address_card.dart';

import '../../shared/profile_notice.dart';
import '../../../domain/entities/personal_information.dart';
import '../cubit/addresses_cubit.dart';

class AddressesList extends StatelessWidget {
  const AddressesList({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressesCubit, AddressesState>(
      builder: (context, state) {
        if (state.addressesStatus == RequestStatus.initial ||
            state.addressesStatus == RequestStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.addressesStatus == RequestStatus.failure) {
          return Center(
            child: AppButton(
              isLoading: state.addressesStatus == RequestStatus.loading,
              label: S.current.dashboardRetry,
              onPressed: () {
                context.read<AddressesCubit>().fetchAddresses();
              },
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 76),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.addresses.isEmpty)
                Text(S.current.profileAddressesEmpty),
              for (final address in state.addresses) ...[
                AppAddressCard(
                  outlined: true,
                  type: address.address.type == DeliveryAddressType.home
                      ? AppAddressType.home
                      : AppAddressType.work,
                  titleLabel: address.address.title,
                  phoneNumber: CurrencyFormatter.toPersianDigits(
                    address.address.phoneNumber,
                  ),
                  postalCode: CurrencyFormatter.toPersianDigits(
                    address.address.postalCode,
                  ),
                  address: address.address.detail,
                  phoneLabel: S.current.profileTelephone,
                  postalLabel: S.current.profilePostalAddress,
                  residenceLabel: S.current.profileResidenceStatus,
                  reviewLabel: S.current.profileReview,
                  onMoreTap:
                      state.saveStatus != RequestStatus.loading &&
                          state.deletionStatus != RequestStatus.loading &&
                          address.status != ResidenceStatus.querying
                      ? () {
                          context.read<AddressesCubit>().requestAddressActions(
                            address,
                          );
                        }
                      : null,
                  onReviewTap:
                      state.saveStatus != RequestStatus.loading &&
                          state.deletionStatus != RequestStatus.loading &&
                          address.status == ResidenceStatus.unchecked
                      ? () {
                          context.read<AddressesCubit>().submitAddressReview(
                            address,
                          );
                        }
                      : null,
                  reviewStatus: address.status == ResidenceStatus.unchecked
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: TextDirection.ltr,
                          children: [
                            if (address.status != ResidenceStatus.querying) ...[
                              AvpImage(
                                image: address.status == ResidenceStatus.valid
                                    ? '${AppConstants.baseImage}profile_address_valid.svg'
                                    : '${AppConstants.baseImage}profile_address_missing.svg',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              residenceStatusLabel(address.status),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    height: 18 / 12,
                                    letterSpacing: 0,
                                    color: residenceStatusColor(address.status),
                                  ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 20),
              ],
              if (state.saveStatus == RequestStatus.loading ||
                  state.deletionStatus == RequestStatus.loading)
                const Center(child: CircularProgressIndicator()),

              ProfileNotice(
                message: S.current.profileResidenceNotice,
                messageSpans: [
                  TextSpan(
                    text: S.current.profileResidenceRegistry,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                      height: 18 / 12,
                      letterSpacing: 0,
                      color: AppLoginColors.noticeText,
                    ),
                  ),
                  TextSpan(text: S.current.profileResidenceRegistered),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

String residenceStatusLabel(ResidenceStatus status) => switch (status) {
  ResidenceStatus.unchecked => S.current.profileReview,
  ResidenceStatus.querying => S.current.profileQuerying,
  ResidenceStatus.valid => S.current.profileValid,
  ResidenceStatus.missing => S.current.profileMissingResidence,
};
Color residenceStatusColor(ResidenceStatus status) => switch (status) {
  ResidenceStatus.valid => AppPalette.success500,
  ResidenceStatus.missing => AppPalette.error500,
  ResidenceStatus.querying => AppPalette.warning500,
  ResidenceStatus.unchecked => AppPalette.brand600,
};
