part of 'address_editor_cubit.dart';

enum AddressEditorEffect { minimumHomeNotice }

@Freezed(toStringOverride: false)
abstract class AddressEditorState with _$AddressEditorState {
  const factory AddressEditorState.initial({
    DeliveryAddress? savedAddress,
    AddressEditorEffect? effect,
    @Default('') String phoneNumber,
    @Default(DeliveryAddressType.home) DeliveryAddressType type,
    @Default(false) bool isPhoneNumberValid,
    @Default('') String title,
    @Default('') String detail,
    @Default('') String postalCode,
    @Default(false) bool isTitleValid,
    @Default(false) bool isDetailValid,
    @Default(false) bool isPostalCodeValid,
    @Default(false) bool isInvalid,
  }) = _AddressEditorState;
}
