import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pishkhan_mobile/l10n/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../shared/certificate_fields.dart';
import '../../deposit_list/widgets/deposit_ui.dart';
import '../cubit/financial_certificate_cubit.dart';

class FinancialLatinIdentityForm extends StatelessWidget {
  const FinancialLatinIdentityForm({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FinancialCertificateCubit, FinancialCertificateState>(
        buildWhen: (a, b) =>
            a.name != b.name ||
            a.surname != b.surname ||
            a.fatherName != b.fatherName ||
            a.passportNumber != b.passportNumber ||
            a.passportExpiryText != b.passportExpiryText ||
            a.latinAddress != b.latinAddress,
        builder: (context, state) {
          final cubit = context.read<FinancialCertificateCubit>();
          final labels = [
            context.l10n.financialLatinName,
            context.l10n.financialLatinSurname,
            context.l10n.financialLatinFather,
            context.l10n.financialLatinPassport,
            context.l10n.financialLatinExpiry,
          ];
          final hints = [
            context.l10n.financialNameHint,
            context.l10n.financialSurnameHint,
            context.l10n.financialFatherHint,
            context.l10n.financialPassportHint,
            context.l10n.financialExpiryHint,
          ];
          final values = [
            state.name,
            state.surname,
            state.fatherName,
            state.passportNumber,
            state.passportExpiryText,
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.financialPassportPrompt,
                style: certificateValueStyle(context)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < labels.length; i++) ...[
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(labels[i], style: certificateLabelStyle(context)),
                      const SizedBox(height: 8),
                      AppTextField(
                        value: values[i],
                        hintText: hints[i],
                        textDirection: TextDirection.ltr,
                        hintTextDirection: TextDirection.rtl,
                        textAlign: TextAlign.left,
                        normalizeDigits: i >= 3,
                        autocorrect: false,
                        enableSuggestions: false,
                        enableIMEPersonalizedLearning: false,
                        textStyle: certificateValueStyle(context).copyWith(
                          fontFamily: values[i].isEmpty
                              ? AppTypography.defaultFontFamily
                              : 'CertificateLatin',
                          fontSize: i >= 3 && values[i].isNotEmpty ? 16 : 14,
                        ),
                        onChanged: (value) {
                          switch (i) {
                            case 0:
                              cubit.latinChanged(name: value);
                            case 1:
                              cubit.latinChanged(surname: value);
                            case 2:
                              cubit.latinChanged(fatherName: value);
                            case 3:
                              cubit.latinChanged(passportNumber: value);
                            case 4:
                              cubit.latinChanged(expiry: value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const DepositDivider(asset: AppAssets.certificateDivider),
              const SizedBox(height: 20),
              Text(
                context.l10n.financialLatinAddressPrompt,
                style: certificateValueStyle(context)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.l10n.financialLatinAddress,
                      style: certificateValueStyle(context),
                    ),
                    const SizedBox(height: 8),
                    _LatinAddressField(
                      value: state.latinAddress,
                      onChanged: (value) => cubit.latinChanged(address: value),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
}

/// The package textarea has a 130px minimum. This instance needs 90px and
/// Latin numerals, while retaining its own controller across Cubit rebuilds.
class _LatinAddressField extends StatefulWidget {
  const _LatinAddressField({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;
  @override
  State<_LatinAddressField> createState() => _LatinAddressFieldState();
}

class _LatinAddressFieldState extends State<_LatinAddressField> {
  late final controller = TextEditingController(text: widget.value);
  @override
  void didUpdateWidget(covariant _LatinAddressField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (controller.text != widget.value) controller.text = widget.value;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: AppRadius.borderSm,
      borderSide: BorderSide(color: context.colors.border),
    );
    return SizedBox(
      height: 90 * MediaQuery.textScalerOf(context).scale(1),
      child: TextField(
        controller: controller,
        onChanged: widget.onChanged,
        expands: true,
        minLines: null,
        maxLines: null,
        textAlignVertical: TextAlignVertical.top,
        textDirection: TextDirection.ltr,
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        style: certificateValueStyle(context).copyWith(
          fontFamily: 'CertificateLatin',
          fontSize: 16,
          height: 24 / 16,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: context.colors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          hintText: context.l10n.financialLatinAddressHint,
          hintTextDirection: TextDirection.ltr,
          hintStyle: certificateValueStyle(context).copyWith(
            fontFamily: 'CertificateLatin',
            fontSize: 16,
            height: 24 / 16,
            color: context.colors.textDisabled,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: context.colors.borderFocus),
          ),
        ),
      ),
    );
  }
}
