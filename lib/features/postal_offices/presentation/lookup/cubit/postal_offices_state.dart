part of 'postal_offices_cubit.dart';

enum PostalOfficesStep { location, results }

enum PostalOfficesEffect { share }

@Freezed(toStringOverride: false)
abstract class PostalOfficesState with _$PostalOfficesState {
  const factory PostalOfficesState.initial({
    @Default(RequestStatus.initial) RequestStatus provincesStatus,
    Failure? failure,
    String? message,
    @Default(<PostalProvince>[]) List<PostalProvince> provinces,
    @Default(PostalOfficesStep.location) PostalOfficesStep postalStep,
    PostalProvince? province,
    PostalCity? city,
    @Default(<PostalCity>[]) List<PostalCity> cities,
    @Default(false) bool canSearchPostalOffices,
    @Default(RequestStatus.initial) RequestStatus postalOfficesStatus,

    @Default(<PostalOffice>[]) List<PostalOffice> postalOffices,
    String? postalShareText,
    PostalOfficesEffect? effect,
  }) = _PostalOfficesState;
}
