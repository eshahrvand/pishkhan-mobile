part of 'certificate_address_cubit.dart';

@Freezed(toStringOverride: false)
abstract class CertificateAddressState with _$CertificateAddressState {
  const factory CertificateAddressState.initial({
    CertificateAddress? savedAddress,
    @Default(0) int saveId,
    @Default('') String title,
    @Default('') String detail,
    @Default('') String postalCode,
    @Default(false) bool isTitleValid,
    @Default(false) bool isDetailValid,
    @Default(false) bool isPostalCodeValid,
    @Default(false) bool isInvalid,
  }) = _CertificateAddressState;
}
