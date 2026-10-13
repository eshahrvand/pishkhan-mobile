import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/core/validators/postal_code_validator.dart';
import 'package:pishkhan_mobile/shared/widgets/app_bottom_sheet_header.dart';

import '../../domain/entities/certificate_data.dart';

Future<CertificateAddress?> showCertificateAddressSheet(BuildContext context) =>
    showModalBottomSheet<CertificateAddress>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surfaceSubtle,
      builder: (_) => const _CertificateAddressForm(),
    );

class _CertificateAddressForm extends StatefulWidget {
  const _CertificateAddressForm();
  @override
  State<_CertificateAddressForm> createState() =>
      _CertificateAddressFormState();
}

class _CertificateAddressFormState extends State<_CertificateAddressForm> {
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
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBottomSheetHeader(
              title: context.l10n.issuanceAddAddress,
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
                    label: context.l10n.issuanceAddressTitle,
                  ),
                  const SizedBox(height: 12),
                  AppTextArea(
                    controller: detail,
                    label: context.l10n.issuanceAddressDetail,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: postal,
                    label: context.l10n.issuancePostalCode,
                    keyboardType: TextInputType.number,
                    normalizeDigits: true,
                    maxLength: 10,
                  ),
                  if (invalid) Text(context.l10n.issuanceAddressInvalid),
                  const SizedBox(height: 20),
                  AppButton(
                    label: context.l10n.issuanceSaveAddress,
                    size: AppButtonSize.lg,
                    onPressed: () {
                      final normalized = DigitNormalizer.normalize(postal.text)
                          .trim();
                      if (title.text.trim().isEmpty ||
                          detail.text.trim().isEmpty ||
                          !PostalCodeValidator.isValid(normalized)) {
                        setState(() => invalid = true);
                        return;
                      }
                      context.pop(
                        CertificateAddress(
                          id: 'local',
                          title: title.text.trim(),
                          detail: detail.text.trim(),
                          postalCode: normalized,
                        ),
                      );
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
