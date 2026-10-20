part of 'addresses_cubit.dart';

enum AddressEffect {
  actions,
  editor,
  confirmDeletion,
  minimumAddress,
  back,
  assistant,
}

enum AddressAction { edit, delete }

@Freezed(toStringOverride: false)
abstract class AddressesState with _$AddressesState {
  const factory AddressesState.initial({
    @Default([]) List<ProfileAddress> addresses,
    @Default(RequestStatus.initial) RequestStatus addressesStatus,
    @Default(RequestStatus.initial) RequestStatus saveStatus,
    @Default(RequestStatus.initial) RequestStatus deletionStatus,
    Failure? addressesFailure,
    Failure? saveFailure,
    Failure? deletionFailure,
    @Default({}) Map<String, Failure> reviewFailures,
    ProfileAddress? selectedAddress,
    @Default(false) bool retainHomeAddress,
    AddressEffect? effect,
    @Default(0) int effectId,
  }) = _AddressesState;
}
