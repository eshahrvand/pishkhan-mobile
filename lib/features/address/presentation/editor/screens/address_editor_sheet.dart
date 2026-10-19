import '../widgets/address_editor_form.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';

Future<DeliveryAddress?> showAddressEditorSheet(BuildContext context) =>
    showModalBottomSheet<DeliveryAddress>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surfaceSubtle,
      builder: (_) => const AddressEditorForm(),
    );
