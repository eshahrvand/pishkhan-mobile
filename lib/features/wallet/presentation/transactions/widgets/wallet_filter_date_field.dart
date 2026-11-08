import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:pishkhan_mobile/shared/widgets/certificate_fields.dart';

class WalletFilterDateField extends StatelessWidget {
  const WalletFilterDateField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onPressed,
  });
  final String label, hint;
  final DateTime? value;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: IgnorePointer(
        child: CertificateInput(
          label: label,
          hint: hint,
          value: value == null ? '' : JalaliDateFormatter.format(value!),
          readOnly: true,
          addonEnd: ColoredBox(
            color: context.colors.primary,
            child: const SizedBox(
              width: 44,
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
    );
  }
}
