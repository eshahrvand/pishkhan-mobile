import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../cubit/card_issuance_cubit.dart';

Future<void> showIssuanceAddressSheet(
  BuildContext context,
  CardIssuanceCubit cubit,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: context.colors.surfaceSubtle,
  builder: (_) => Directionality(
    textDirection: TextDirection.rtl,
    child: _AddressForm(cubit: cubit),
  ),
);

class _AddressForm extends StatefulWidget {
  const _AddressForm({required this.cubit});
  final CardIssuanceCubit cubit;
  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final title = TextEditingController(),
      detail = TextEditingController(),
      postal = TextEditingController();
  bool invalid = false;
  @override
  void dispose() {
    title.dispose();
    detail.dispose();
    postal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetHeader(
              title: context.l10n.issuanceAddAddress,
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
                    label: context.l10n.issuanceAddressTitle,
                  ),
                  const SizedBox(height: 12),
                  AppTextArea(
                    key: const Key('issuance_new_address_detail'),
                    controller: detail,
                    label: context.l10n.issuanceAddressDetail,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    key: const Key('issuance_new_address_postal'),
                    controller: postal,
                    label: context.l10n.issuancePostalCode,
                    keyboardType: TextInputType.number,
                    normalizeDigits: true,
                  ),
                  if (invalid) ...[
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.issuanceAddressInvalid,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  AppButton(
                    key: const Key('issuance_save_address'),
                    label: context.l10n.issuanceSaveAddress,
                    size: AppButtonSize.lg,
                    onPressed: () {
                      if (widget.cubit.addAddress(
                        title: title.text,
                        detail: detail.text,
                        postalCode: postal.text,
                      )) {
                        Navigator.of(context).pop();
                      } else {
                        setState(() => invalid = true);
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
}
