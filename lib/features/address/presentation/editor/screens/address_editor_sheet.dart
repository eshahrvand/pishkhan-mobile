import '../widgets/address_editor_form.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';

Future<DeliveryAddress?> showAddressEditorSheet(
  BuildContext context, {
  DeliveryAddress? initialAddress,
  bool includeContact = false,
  bool retainHomeAddress = false,
}) {
  return showModalBottomSheet<DeliveryAddress>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.surfaceSubtle,
    builder: (sheetContext) => SafeArea(
      top: false,
      // A caller inside SafeArea may already have consumed inherited padding.
      minimum: EdgeInsets.only(
        bottom: MediaQueryData.fromView(View.of(sheetContext)).padding.bottom,
      ),
      child: AddressEditorForm(
        initialAddress: initialAddress,
        includeContact: includeContact,
        retainHomeAddress: retainHomeAddress,
      ),
    ),
  );
}
