import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

/// Editable Solar Hijri input. The package has no approved calendar picker yet.
/// Flutter focus is local; parsing, date eligibility and errors remain in Cubit.
class TransferDateField extends StatefulWidget {
  const TransferDateField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });
  final String label;
  final String hint;
  final String value;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final bool enabled;
  @override
  State<TransferDateField> createState() => _TransferDateFieldState();
}

class _TransferDateFieldState extends State<TransferDateField> {
  final _focus = FocusNode();
  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: certificateLabelStyle(context)),
        const SizedBox(height: 8),
        AppTextField(
          value: widget.value,
          focusNode: _focus,
          hintText: widget.hint,
          errorText: widget.errorText,
          enabled: widget.enabled,
          normalizeDigits: true,
          maxLength: 10,
          keyboardType: TextInputType.datetime,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
          ],
          textStyle: certificateValueStyle(context),
          hintTextDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          onChanged: widget.onChanged,
          suffixIcon: Material(
            color: context.colors.borderFocus,
            child: InkWell(
              onTap: widget.enabled ? _focus.requestFocus : null,
              child: SizedBox(
                width: 48,
                height: 44,
                child: Center(
                  child: AvpImage(
                    image:
                        '${AppConstants.baseImage}certificate_certCalendar.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
