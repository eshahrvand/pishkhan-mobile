part of 'certificate_address_cubit.dart';

@freezed
abstract class CertificateAddressState with _$CertificateAddressState {
  const factory CertificateAddressState.initial({
    CertificateAddress? savedAddress,
    @Default(0) int saveId,
    @Default('') String title,
    @Default('') String detail,
    @Default('') String postalCode,
    @Default(false) bool isInvalid,
  }) = _CertificateAddressState;
}
