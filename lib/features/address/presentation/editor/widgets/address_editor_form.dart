import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';
import 'package:pishkhan_mobile/shared/widgets/app_decision_sheet.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

import '../cubit/address_editor_cubit.dart';

class AddressEditorForm extends StatefulWidget {
  const AddressEditorForm({
    super.key,
    this.initialAddress,
    this.includeContact = false,
    this.retainHomeAddress = false,
  });
  final DeliveryAddress? initialAddress;
  final bool includeContact;
  final bool retainHomeAddress;
  @override
  State<AddressEditorForm> createState() => _AddressEditorFormState();
}

class _AddressEditorFormState extends State<AddressEditorForm> {
  late final title = TextEditingController(text: widget.initialAddress?.title);
  late final detail = TextEditingController(
    text: widget.initialAddress?.detail,
  );
  late final postal = TextEditingController(
    text: widget.initialAddress?.postalCode,
  );
  @override
  void dispose() {
    title.dispose();
    detail.dispose();
    postal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddressEditorCubit>(
      create: (_) {
        final cubit = AddressEditorCubit(
          initialAddress: widget.initialAddress,
          includeContact: widget.includeContact,
          retainHomeAddress: widget.retainHomeAddress,
        );
        if (widget.initialAddress != null) cubit.fetchAddress();
        return cubit;
      },
      child: BlocListener<AddressEditorCubit, AddressEditorState>(
        listenWhen: (previous, current) =>
            previous.minimumHomeNoticeId != current.minimumHomeNoticeId,
        listener: (context, state) {
          showAppDecisionSheet(
            context,
            message: S.current.profileMinimumAddress,
            confirmLabel: S.current.passwordUnderstood,
            onConfirm: () {
              Navigator.of(context).pop();
            },
          );
        },
        child: BlocConsumer<AddressEditorCubit, AddressEditorState>(
          listenWhen: (previous, current) => previous.saveId != current.saveId,
          listener: (context, state) => context.pop(state.savedAddress),
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
                        title: widget.initialAddress == null
                            ? S.current.issuanceAddAddress
                            : S.current.profileEditAddress,
                        showRightIcon: false,
                        showLeftAction: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.includeContact) ...[
                              CertificateSelect<DeliveryAddressType>(
                                label: S.current.profileAddressType,
                                hint: S.current.profileAddressType,
                                value: state.type,
                                options: [
                                  AppSelectOption(
                                    value: DeliveryAddressType.home,
                                    label: S.current.profileHome,
                                  ),
                                  AppSelectOption(
                                    value: DeliveryAddressType.work,
                                    label: S.current.profileWork,
                                  ),
                                ],
                                onChanged: (value) {
                                  context.read<AddressEditorCubit>().selectType(
                                    value,
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                value: state.phoneNumber,
                                label: S.current.profileTelephone,
                                maxLength: 11,
                                normalizeDigits: true,
                                keyboardType: TextInputType.phone,
                                onChanged: (value) {
                                  context
                                      .read<AddressEditorCubit>()
                                      .updatePhoneNumber(value);
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                            AppTextField(
                              controller: title,
                              onChanged: (value) => context
                                  .read<AddressEditorCubit>()
                                  .updateTitle(value),
                              label: S.current.issuanceAddressTitle,
                            ),
                            const SizedBox(height: 12),
                            AppTextArea(
                              controller: detail,
                              onChanged: (value) => context
                                  .read<AddressEditorCubit>()
                                  .updateDetail(value),
                              label: S.current.issuanceAddressDetail,
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              controller: postal,
                              onChanged: (value) => context
                                  .read<AddressEditorCubit>()
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
                                  .read<AddressEditorCubit>()
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
      ),
    );
  }
}
