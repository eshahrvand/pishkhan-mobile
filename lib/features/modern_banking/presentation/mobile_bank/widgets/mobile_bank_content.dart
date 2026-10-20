import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../shared/modern_bank_video.dart';
import '../../../domain/entities/mobile_bank.dart';
import '../../shared/modern_bank_notice.dart';
import '../../shared/modern_bank_receipt.dart';
import '../cubit/mobile_bank_cubit.dart';
import 'mobile_bank_serial_form.dart';
import 'mobile_bank_payment.dart';
import 'mobile_bank_active.dart';
import 'mobile_bank_pending.dart';

class MobileBankContent extends StatelessWidget {
  const MobileBankContent({super.key, required this.state});
  final MobileBankState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.record?.status == MobileBankRequestStatus.rejected) ...[
          ModernBankNotice(message: S.current.modernRejected),
          const SizedBox(height: 16),
        ],
        if (state.step == MobileBankStep.serial ||
            state.step == MobileBankStep.payment ||
            state.step == MobileBankStep.instruction) ...[
          AppStepper(
            currentStep: state.stepNumber,
            totalSteps: 3,
            progress: state.progress,
            title: getMobileBankStepTitle(state.step),
            supportingText: getMobileBankNextTitle(state.step),
          ),
          const SizedBox(height: 26),
        ],
        if (state.step == MobileBankStep.introduction) ...[
          ModernBankVideo(
            poster: AppAssets.modernIntro,
            url: state.catalog!.activationVideoUrl,
            isIntroduction: true,
          ),
          const SizedBox(height: 16),
          Text(
            S.current.modernActivationIntro,
            style: Theme.of(context).textTheme.bodyMedium!
                .copyWith(height: 22 / 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          ModernBankNotice(message: S.current.modernUsernameNotice),
          const SizedBox(height: 16),
          ModernBankNotice(message: S.current.modernIdentityNotice),
        ],
        if (state.step == MobileBankStep.serial)
          MobileBankSerialForm(state: state),
        if (state.step == MobileBankStep.payment)
          MobileBankPayment(state: state),
        if (state.step == MobileBankStep.instruction) ...[
          Text(
            S.current.passwordInstructionPrompt,
            style: Theme.of(context).textTheme.bodyMedium!
                .copyWith(height: 20 / 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          ModernBankVideo(
            poster: AppAssets.modernKycInstruction,
            url: state.catalog!.identityVideoUrl,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppPasswordServiceColors.cameraNotice,
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 20,
                  child: AvpImage(image: AppAssets.passwordCameraInfo),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.current.passwordCameraNotice,
                    style: Theme.of(context).textTheme.bodySmall!
                        .copyWith(height: 18 / 12),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (state.step == MobileBankStep.preview) ...[
          Text(
            S.current.passwordRecordingPrompt,
            style: Theme.of(context).textTheme.bodyMedium!
                .copyWith(height: 20 / 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          ModernBankVideo(poster: AppAssets.modernKycPreview),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: IntrinsicWidth(
              child: AppButton(
                label: S.current.passwordRecordAgain,
                variant: AppButtonVariant.text,
                onPressed: state.submissionStatus == RequestStatus.loading
                    ? null
                    : () {
                        context.read<MobileBankCubit>().requestRecordingAgain();
                      },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.current.modernPreviewNotice,
            style: Theme.of(context).textTheme.bodySmall!
                .copyWith(color: context.colors.textTertiary),
          ),
        ],
        if (state.step == MobileBankStep.receipt)
          ModernBankReceipt(
            message: S.current.passwordSubmittedBody,
            prototypeNotice: S.current.passwordMockReceipt,
            illustrationTopSpacing:
                context.read<MobileBankCubit>().operation ==
                    MobileBankOperation.activation
                ? 124
                : 156,
            trackingCode:
                context.read<MobileBankCubit>().operation ==
                    MobileBankOperation.activation
                ? state.record!.trackingCode
                : null,
          ),
        if (state.step == MobileBankStep.pending)
          MobileBankPending(trackingCode: state.record!.trackingCode!),
        if (state.step == MobileBankStep.active) MobileBankActive(state: state),
        if (state.step == MobileBankStep.recoveryApproved)
          ModernBankReceipt(
            message: S.current.passwordApprovedBody,
            prototypeNotice: S.current.passwordMockReceipt,
            trackingCode: state.record!.trackingCode,
          ),
      ],
    );
  }
}

String getMobileBankStepTitle(MobileBankStep step) => switch (step) {
  MobileBankStep.serial => S.current.modernSerialStep,
  MobileBankStep.payment => S.current.modernPaymentStep,
  _ => S.current.modernKycStep,
};
String getMobileBankNextTitle(MobileBankStep step) => switch (step) {
  MobileBankStep.serial =>
    '${S.current.certificateNextPrefix} ${S.current.modernPaymentStep}',
  MobileBankStep.payment =>
    '${S.current.certificateNextPrefix} ${S.current.modernKycStep}',
  _ => S.current.passwordStartKyc,
};
