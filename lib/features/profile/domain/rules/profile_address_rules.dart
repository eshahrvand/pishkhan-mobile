import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';

import '../entities/personal_information.dart';

/// Removing a record must leave at least one registered home address.
bool canRemoveProfileAddress(
  List<ProfileAddress> addresses,
  DeliveryAddress address,
) {
  return addresses.any(
    (item) =>
        item.address.id != address.id &&
        item.address.type == DeliveryAddressType.home,
  );
}

/// Editing a home into a work address must not remove the last home.
bool canSaveProfileAddress(
  List<ProfileAddress> addresses,
  DeliveryAddress address,
) {
  return address.type == DeliveryAddressType.home ||
      addresses.any(
        (item) =>
            item.address.id != address.id &&
            item.address.type == DeliveryAddressType.home,
      );
}
