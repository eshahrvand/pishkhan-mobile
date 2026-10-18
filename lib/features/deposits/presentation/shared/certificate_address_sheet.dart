import 'certificate_address_form.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/certificate_data.dart';

Future<CertificateAddress?> showCertificateAddressSheet(BuildContext context) =>
    showModalBottomSheet<CertificateAddress>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surfaceSubtle,
      builder: (_) => const CertificateAddressForm(),
    );
