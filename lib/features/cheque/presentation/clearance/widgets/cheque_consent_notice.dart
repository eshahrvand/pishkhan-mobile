import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../cubit/cheque_clearance_cubit.dart';
import 'cheque_clearance_ui.dart';

class ChequeConsentNotice extends StatelessWidget {
  const ChequeConsentNotice({super.key, required this.isEditable});
  final bool isEditable;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppPasswordServiceColors.cameraNotice,
        borderRadius: AppRadius.borderSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AvpImage(
                image: AppAssets.passwordCameraInfo,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  S.current.chequeConsentNotes,
                  style: chequeLabelStyle(context)
                      .copyWith(color: context.colors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            S.current.chequeConsentNotice,
            style: chequeLabelStyle(context)
                .copyWith(fontWeight: FontWeight.w400),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: S.current.chequeConsentConditions,
                variant: AppButtonVariant.text,
                size: AppButtonSize.sm,
                horizontalPadding: 0,
                contentGap: 8,
                labelStyle: chequeLabelStyle(context)
                    .copyWith(color: context.colors.primary),
                trailingIcon: const AvpImage(
                  image: AppAssets.addressCardAngleLeft,
                  width: 20,
                  height: 20,
                ),
                onPressed: isEditable
                    ? context
                          .read<ChequeClearanceCubit>()
                          .requestConsentConditions
                    : null,
              ),
            ],
          ),
          const AvpImage(
            image: AppAssets.chequeClearanceAddressDivider,
            height: 1,
            fit: BoxFit.fill,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  S.current.chequeConsentSample,
                  style: chequeLabelStyle(context)
                      .copyWith(fontWeight: FontWeight.w400),
                ),
              ),
              AppButton(
                label: S.current.chequeDownloadSample,
                variant: AppButtonVariant.text,
                size: AppButtonSize.sm,
                horizontalPadding: 0,
                contentGap: 8,
                labelStyle: chequeLabelStyle(context)
                    .copyWith(color: context.colors.primary),
                trailingIcon: const AvpImage(
                  image: AppAssets.addressCardAngleLeft,
                  width: 20,
                  height: 20,
                ),
                onPressed: isEditable
                    ? context.read<ChequeClearanceCubit>().requestConsentSample
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
