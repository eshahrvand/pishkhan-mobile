import '../../../domain/entities/issuance_data.dart';

sealed class IssuanceEffect {
  const IssuanceEffect();
}

final class IssuanceTermsRequested extends IssuanceEffect {
  const IssuanceTermsRequested();
}

final class IssuanceAddressRequested extends IssuanceEffect {
  const IssuanceAddressRequested();
}

final class IssuanceAddressRemovalRequested extends IssuanceEffect {
  const IssuanceAddressRemovalRequested(this.address);
  final IssuanceAddress address;
}
