import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../cubit/card_issuance_cubit.dart';

class IssuanceAddressForm extends StatefulWidget {
  const IssuanceAddressForm({super.key});
  @override
  State<IssuanceAddressForm> createState() => _IssuanceAddressFormState();
}

class _IssuanceAddressFormState extends State<IssuanceAddressForm> {
  final title = TextEditingController(),
      detail = TextEditingController(),
      postal = TextEditingController();
  @override
  void initState() {
    super.initState();
    context.read<CardIssuanceCubit>().resetAddressFormValidation();
  }

  @override
  void dispose() {
    title.dispose();
    detail.dispose();
    postal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardIssuanceCubit, CardIssuanceState>(
      buildWhen: (previous, current) =>
          previous.isAddressFormError != current.isAddressFormError,
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBottomSheetHeader(
                    title: S.current.issuanceAddAddress,
                    showLeftAction: false,
                    showRightIcon: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          key: const Key('issuance_new_address_title'),
                          controller: title,
                          label: S.current.issuanceAddressTitle,
                        ),
                        const SizedBox(height: 12),
                        AppTextArea(
                          key: const Key('issuance_new_address_detail'),
                          controller: detail,
                          label: S.current.issuanceAddressDetail,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          key: const Key('issuance_new_address_postal'),
                          controller: postal,
                          label: S.current.issuancePostalCode,
                          keyboardType: TextInputType.number,
                          normalizeDigits: true,
                        ),
                        if (state.isAddressFormError) ...[
                          const SizedBox(height: 8),
                          Text(
                            S.current.issuanceAddressInvalid,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        AppButton(
                          key: const Key('issuance_save_address'),
                          label: S.current.issuanceSaveAddress,
                          size: AppButtonSize.lg,
                          onPressed: () {
                            if (context.read<CardIssuanceCubit>().addAddress(
                              title: title.text,
                              detail: detail.text,
                              postalCode: postal.text,
                            )) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
