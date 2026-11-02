import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../../../domain/entities/cheque_book.dart';
import '../cubit/cheque_book_cubit.dart';

class ChequeBookSelection extends StatelessWidget {
  const ChequeBookSelection({super.key, required this.state});
  final ChequeBookState state;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.current.chequeBookSelectionPrompt,
          style: certificateValueStyle(context)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        CertificateSelect<ChequeBookDeposit>(
          label: S.current.issuanceDeposit,
          hint: S.current.chequeBookDepositHint,
          value: state.deposit,
          enabled: state.isEditable,
          options: [
            for (final deposit in state.catalog!.deposits)
              AppSelectOption(value: deposit, label: deposit.number),
          ],
          onChanged: context.read<ChequeBookCubit>().selectDeposit,
        ),
        if (state.deposit != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppPasswordServiceColors.cameraNotice,
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox.square(
                  dimension: 20,
                  child: Center(
                    child: AvpImage(
                      image:
                          '${AppConstants.baseImage}password_camera_info.svg',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.current.chequeBookUsedLeavesNotice,
                    style: certificateLabelStyle(context)
                        .copyWith(fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        const AvpImage(
          image: '${AppConstants.baseImage}issuance_divider.svg',
          height: .5,
          fit: BoxFit.fill,
        ),
        const SizedBox(height: 20),
        CertificateSelect<int>(
          label: S.current.chequeBookLeafCount,
          hint: S.current.chequeBookLeafCountHint,
          value: state.leafCount,
          enabled: state.isEditable,
          options: [
            for (final count in state.leafCounts)
              AppSelectOption(
                value: count,
                label: CurrencyFormatter.toPersianDigits('$count'),
              ),
          ],
          onChanged: context.read<ChequeBookCubit>().selectLeafCount,
        ),
        if (state.deposit != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppPasswordServiceColors.cameraNotice,
              borderRadius: AppRadius.borderSm,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox.square(
                      dimension: 20,
                      child: Center(
                        child: AvpImage(
                          image:
                              '${AppConstants.baseImage}chequebook_opening_info.svg',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        S.current.chequeBookOpenedAt,
                        style: certificateLabelStyle(context),
                      ),
                    ),
                    Text(
                      JalaliDateFormatter.format(state.deposit!.openedAt),
                      style: certificateLabelStyle(context)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const AvpImage(
                  image: '${AppConstants.baseImage}issuance_divider.svg',
                  height: .5,
                  fit: BoxFit.fill,
                ),
                const SizedBox(height: 10),
                Text(
                  S.current.chequeBookFiftyLeavesNotice,
                  textAlign: TextAlign.center,
                  style: certificateLabelStyle(context)
                      .copyWith(fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
