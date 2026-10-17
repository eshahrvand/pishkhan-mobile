import '../../domain/entities/certificate_data.dart';

sealed class CertificateEffect {
  const CertificateEffect();
}

final class CertificateAddressRequested extends CertificateEffect {
  const CertificateAddressRequested();
}

final class CertificateAddressRemovalRequested extends CertificateEffect {
  const CertificateAddressRemovalRequested(this.address);
  final CertificateAddress address;
}

final class CertificateAgentUnavailable extends CertificateEffect {
  const CertificateAgentUnavailable();
}
