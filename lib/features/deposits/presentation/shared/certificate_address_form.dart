import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/certificate_address_cubit.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

class CertificateAddressForm extends StatefulWidget {
  const CertificateAddressForm({super.key});
  @override
  State<CertificateAddressForm> createState() => _CertificateAddressFormState();
}

class _CertificateAddressFormState extends State<CertificateAddressForm> {
  final title = TextEditingController(),
      detail = TextEditingController(),
      postal = TextEditingController();
  @override
  void dispose() {
    title.dispose();
    detail.dispose();
    postal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CertificateAddressCubit>(
      create: (_) => CertificateAddressCubit(),
      child: BlocConsumer<CertificateAddressCubit, CertificateAddressState>(
        listenWhen: (previous, current) => previous.saveId != current.saveId,
        listener: (context, state) => context.pop(state.savedAddress),
        buildWhen: (previous, current) =>
            previous.isInvalid != current.isInvalid,
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
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
                      showRightIcon: false,
                      showLeftAction: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: title,
                            onChanged: (value) => context
                                .read<CertificateAddressCubit>()
                                .updateTitle(value),
                            label: S.current.issuanceAddressTitle,
                          ),
                          const SizedBox(height: 12),
                          AppTextArea(
                            controller: detail,
                            onChanged: (value) => context
                                .read<CertificateAddressCubit>()
                                .updateDetail(value),
                            label: S.current.issuanceAddressDetail,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: postal,
                            onChanged: (value) => context
                                .read<CertificateAddressCubit>()
                                .updatePostalCode(value),
                            label: S.current.issuancePostalCode,
                            keyboardType: TextInputType.number,
                            normalizeDigits: true,
                            maxLength: 10,
                          ),
                          if (state.isInvalid)
                            Text(S.current.issuanceAddressInvalid),
                          const SizedBox(height: 20),
                          AppButton(
                            label: S.current.issuanceSaveAddress,
                            size: AppButtonSize.lg,
                            onPressed: context
                                .read<CertificateAddressCubit>()
                                .submitAddress,
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
      ),
    );
  }
}
