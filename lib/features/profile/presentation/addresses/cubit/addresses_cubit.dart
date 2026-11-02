import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/personal_information.dart';
import '../../../domain/rules/profile_address_rules.dart';
import '../../../domain/usecases/personal_information_usecase.dart';

part 'addresses_state.dart';
part 'addresses_cubit.freezed.dart';

class AddressesCubit extends Cubit<AddressesState> {
  AddressesCubit({AddressesState initialState = const AddressesState.initial()})
    : super(initialState);
  final fetchProfileAddressesUseCase = getIt<FetchProfileAddressesUseCase>();
  final saveProfileAddressUseCase = getIt<SaveProfileAddressUseCase>();
  final deleteProfileAddressUseCase = getIt<DeleteProfileAddressUseCase>();
  final reviewProfileAddressUseCase = getIt<ReviewProfileAddressUseCase>();

  Future<void> fetchAddresses() async {
    emit(state.copyWith(addressesStatus: RequestStatus.loading));
    final result = await fetchProfileAddressesUseCase();
    switch (result) {
      case Success(:final data):
        emit(
          state.copyWith(
            addresses: data,
            addressesStatus: RequestStatus.success,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            addressesStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
    }
  }

  void requestAddressActions(ProfileAddress address) {
    emit(
      state.copyWith(selectedAddress: address, effect: AddressEffect.actions),
    );
  }

  void applyAddressAction(AddressAction? action) {
    switch (action) {
      case AddressAction.edit:
        emit(
          state.copyWith(
            effect: AddressEffect.editor,
            retainHomeAddress:
                state.selectedAddress!.address.type ==
                    DeliveryAddressType.home &&
                !canRemoveProfileAddress(
                  state.addresses,
                  state.selectedAddress!.address,
                ),
          ),
        );
      case AddressAction.delete:
        emit(
          state.copyWith(
            effect:
                canRemoveProfileAddress(
                  state.addresses,
                  state.selectedAddress!.address,
                )
                ? AddressEffect.confirmDeletion
                : AddressEffect.minimumAddress,
          ),
        );
      case null:
        break;
    }
  }

  void requestNewAddress() {
    emit(
      state.copyWith(
        selectedAddress: null,
        retainHomeAddress: false,
        effect: AddressEffect.editor,
      ),
    );
  }

  Future<void> applyAddressEditor(DeliveryAddress? address) async {
    if (address != null && canSaveProfileAddress(state.addresses, address)) {
      emit(state.copyWith(saveStatus: RequestStatus.loading));
      final result = await saveProfileAddressUseCase(address);
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              addresses: _addressesWithSaved(data),
              saveStatus: RequestStatus.success,
            ),
          );
        case Err(:final failure):
          emit(
            state.copyWith(
              saveStatus: RequestStatus.failure,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
      }
    } else if (address != null) {
      emit(state.copyWith(effect: AddressEffect.minimumAddress));
    }
  }

  Future<void> submitDeletion(ProfileAddress address) async {
    emit(state.copyWith(deletionStatus: RequestStatus.loading));
    final result = await deleteProfileAddressUseCase(address.address.id);
    switch (result) {
      case Success():
        emit(
          state.copyWith(
            addresses: state.addresses
                .where((item) => item.address.id != address.address.id)
                .toList(),
            deletionStatus: RequestStatus.success,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            deletionStatus: RequestStatus.failure,
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
    }
  }

  Future<void> submitAddressReview(ProfileAddress address) async {
    emit(
      state.copyWith(
        addresses: [
          for (final item in state.addresses)
            if (item.address.id == address.address.id)
              item.withStatus(ResidenceStatus.querying)
            else
              item,
        ],
        reviewStatuses: {
          ...state.reviewStatuses,
          address.address.id: RequestStatus.loading,
        },
      ),
    );
    final result = await reviewProfileAddressUseCase(address.address);
    switch (result) {
      case Success(:final data):
        emit(
          state.copyWith(
            addresses: _addressesAfterReview(address.address, data),
            reviewStatuses: {
              ...state.reviewStatuses,
              address.address.id: RequestStatus.success,
            },
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            addresses: _addressesAfterReview(
              address.address,
              ResidenceStatus.unchecked,
            ),
            reviewStatuses: {
              ...state.reviewStatuses,
              address.address.id: RequestStatus.failure,
            },
            failure: failure,
            message: getRequestErrorMessage(failure),
          ),
        );
    }
  }

  List<ProfileAddress> _addressesWithSaved(ProfileAddress saved) {
    return [
      for (final item in state.addresses)
        if (_hasAddressId(item, saved.address.id)) saved else item,
      if (!state.addresses.any((item) => _hasAddressId(item, saved.address.id)))
        saved,
    ];
  }

  bool _hasAddressId(ProfileAddress item, String id) => item.address.id == id;

  List<ProfileAddress> _addressesAfterReview(
    DeliveryAddress address,
    ResidenceStatus status,
  ) {
    return [
      for (final item in state.addresses)
        if (item.address == address) item.withStatus(status) else item,
    ];
  }

  void requestBack() {
    emit(state.copyWith(effect: AddressEffect.back));
  }

  void requestAssistant() {
    emit(state.copyWith(effect: AddressEffect.assistant));
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeAddressesInteraction() {
    emit(state.copyWith(effect: null));
  }
}
