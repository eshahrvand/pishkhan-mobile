import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_invoice.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../../shared/profile_notice.dart';
import '../cubit/change_phone_cubit.dart';
import 'phone_otp_field.dart';

class ChangePhoneForm extends StatelessWidget {
  const ChangePhoneForm({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePhoneCubit, ChangePhoneState>(
      buildWhen: (previous, current) =>
          previous.settingsStatus != current.settingsStatus ||
          previous.settings != current.settings ||
          previous.phoneNumber != current.phoneNumber ||
          previous.isPhoneNumberError != current.isPhoneNumberError ||
          previous.otpRequestStatus != current.otpRequestStatus ||
          previous.submissionStatus != current.submissionStatus,
      builder: (context, state) {
        if (state.settingsStatus == RequestStatus.initial ||
            state.settingsStatus == RequestStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.settingsStatus == RequestStatus.failure) {
          return Center(
            child: AppButton(
              isLoading: state.settingsStatus == RequestStatus.loading,
              label: S.current.dashboardRetry,
              onPressed: () {
                context.read<ChangePhoneCubit>().fetchSettings();
              },
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 76),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileNotice(message: S.current.profilePhoneNotice),
              const SizedBox(height: 20),
              Text(
                S.current.profileCurrentPhone,
                style: certificateLabelStyle(context),
              ),
              const SizedBox(height: 8),
              AppTextField(
                value: CurrencyFormatter.toPersianDigits(
                  state.settings!.phoneNumber,
                ),
                readOnly: true,
                backgroundColor: context.colors.surfaceSubtle,
                textAlign: TextAlign.right,
                textStyle: certificateValueStyle(context)
                    .copyWith(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 20),
              Text(
                S.current.profileNewPhone,
                style: certificateLabelStyle(context),
              ),
              const SizedBox(height: 8),
              AppTextField(
                value: state.phoneNumber,
                hintText: S.current.profileNewPhoneHint,
                enabled:
                    state.otpRequestStatus != RequestStatus.loading &&
                    state.submissionStatus != RequestStatus.loading &&
                    state.submissionStatus != RequestStatus.success,
                maxLength: 11,
                normalizeDigits: true,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.right,
                textStyle: certificateValueStyle(context),
                hintTextDirection: TextDirection.rtl,
                errorText: state.isPhoneNumberError
                    ? S.current.authInvalidPhone
                    : null,
                onChanged: (value) {
                  context.read<ChangePhoneCubit>().updatePhoneNumber(value);
                },
                onFocusLost: () {
                  context.read<ChangePhoneCubit>().validatePhoneNumber();
                },
              ),
              const SizedBox(height: 20),
              const PhoneOtpField(),
              const SizedBox(height: 20),
              // The Figma stroke occupies zero layout height between the gaps.
              SizedBox(
                height: 0,
                child: OverflowBox(
                  minHeight: 1,
                  maxHeight: 1,
                  child: AvpImage(
                    image:
                        '${AppConstants.baseImage}certificate_certDivider.svg',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppInvoice(
                title: S.current.profileShahkarFee,
                totalAmount: CurrencyFormatter.format(state.settings!.feeRial),
                walletBalance: CurrencyFormatter.format(
                  state.settings!.walletBalanceRial,
                ),
                lines: const [],
                isExpanded: false,
                onExpandedChanged: (_) {},
                isWalletBalanceSufficient: state.walletSufficient,
                showToggle: false,
                backgroundColor: context.colors.surface,
                labelColor: AppPalette.gray500,
                walletLabel: S.current.issuanceWallet,
                walletSufficientLabel: S.current.issuanceWalletSufficient,
                walletInsufficientLabel: S.current.issuanceWalletInsufficient,
                zeroHeightDividers: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
