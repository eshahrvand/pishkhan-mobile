part of 'address_editor_cubit.dart';

@Freezed(toStringOverride: false)
abstract class AddressEditorState with _$AddressEditorState {
  const factory AddressEditorState.initial({
    DeliveryAddress? savedAddress,
    @Default(0) int saveId,
    @Default('') String title,
    @Default('') String detail,
    @Default('') String postalCode,
    @Default(false) bool isTitleValid,
    @Default(false) bool isDetailValid,
    @Default(false) bool isPostalCodeValid,
    @Default(false) bool isInvalid,
  }) = _AddressEditorState;
}
