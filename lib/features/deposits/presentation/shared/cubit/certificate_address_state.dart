part of 'certificate_address_cubit.dart';

@freezed
abstract class CertificateAddressState with _$CertificateAddressState {
  const factory CertificateAddressState.initial({
    @Default('') String title,
    @Default('') String detail,
    @Default('') String postalCode,
    @Default(false) bool isInvalid,
  }) = _CertificateAddressState;
}
