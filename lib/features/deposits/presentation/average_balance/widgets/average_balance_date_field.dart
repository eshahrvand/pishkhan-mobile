import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import '../../shared/certificate_fields.dart';
import '../../deposit_list/widgets/deposit_ui.dart';

class AverageBalanceDateField extends StatelessWidget {
  const AverageBalanceDateField({
    super.key,
    required this.label,
    required this.hint,
    this.value,
  });
  final String label, hint;
  final DateTime? value;
  @override
  Widget build(BuildContext context) {
    return CertificateInput(
      label: label,
      hint: hint,
      value: value == null ? '' : JalaliDateFormatter.format(value!),
      readOnly: true,
      addonEnd: ColoredBox(
        color: AppPalette.brand500,
        child: SizedBox(
          width: 48,
          height: 44,
          child: Center(
            child: depositIcon(
              '${AppConstants.baseImage}certificate_certCalendar.svg',
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
