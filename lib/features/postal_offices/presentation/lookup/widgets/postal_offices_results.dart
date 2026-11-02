import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../cubit/postal_offices_cubit.dart';

import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

class PostalOfficesResults extends StatelessWidget {
  const PostalOfficesResults({super.key, required this.state});
  final PostalOfficesState state;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: AppRadius.borderSm,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      S.current.chequeProvinceSummary,
                      style: certificateLabelStyle(context),
                    ),
                    const Spacer(),
                    Expanded(
                      child: Text(
                        state.province!.name,
                        style: certificateValueStyle(context),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      S.current.chequeCitySummary,
                      style: certificateLabelStyle(context),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        state.city!.name,
                        style: certificateValueStyle(context),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const AvpImage(
            image: '${AppConstants.baseImage}issuance_divider.svg',
            height: 1,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 16),
          if (state.postalOffices.isEmpty) ...[
            Text(
              S.current.chequePostalEmpty,
              style: certificateLabelStyle(context),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: S.current.chequePostalSearchAgain,
              onPressed: context.read<PostalOfficesCubit>().requestPostalSearch,
            ),
          ] else ...[
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: state.postalOffices.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) => Text(
                  '•  ${state.postalOffices[index].address}',
                  style: certificateLabelStyle(context)
                      .copyWith(fontWeight: FontWeight.w400),
                ),
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: S.current.chequePostalShare,
              leadingIcon: const AvpImage(
                image: '${AppConstants.baseImage}cheque_clearance_share.svg',
                width: 20,
                height: 20,
              ),
              size: AppButtonSize.lg,
              onPressed: context.read<PostalOfficesCubit>().requestPostalShare,
            ),
          ],
        ],
      ),
    );
  }
}
