part of 'cheque_postal_cubit.dart';

enum ChequePostalStep { location, results }

enum ChequePostalEffect { share }

@Freezed(toStringOverride: false)
abstract class ChequePostalState with _$ChequePostalState {
  const factory ChequePostalState.initial({
    @Default(RequestStatus.initial) RequestStatus provincesStatus,
    Failure? provincesFailure,
    @Default(<PostalProvince>[]) List<PostalProvince> provinces,
    @Default(ChequePostalStep.location) ChequePostalStep postalStep,
    PostalProvince? province,
    PostalCity? city,
    @Default(<PostalCity>[]) List<PostalCity> cities,
    @Default(false) bool canSearchPostalOffices,
    @Default(RequestStatus.initial) RequestStatus postalOfficesStatus,
    Failure? postalOfficesFailure,
    @Default(<PostalOffice>[]) List<PostalOffice> postalOffices,
    String? postalShareText,
    ChequePostalEffect? effect,
    @Default(0) int effectId,
  }) = _ChequePostalState;
}
