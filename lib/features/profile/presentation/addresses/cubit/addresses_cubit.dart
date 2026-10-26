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
import '../../../domain/repositories/personal_information_repository.dart';
part 'addresses_state.dart';
part 'addresses_cubit.freezed.dart';

class AddressesCubit extends Cubit<AddressesState> {
  AddressesCubit({AddressesState initialState = const AddressesState.initial()})
    : super(initialState);
  final repository = getIt<PersonalInformationRepository>();

  Future<void> fetchAddresses() {
    emit(
      state.copyWith(
        addressesStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return repository.fetchAddresses().then((result) {
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
    });
  }

  void requestAddressActions(ProfileAddress address) {
    emit(
      state.copyWith(
        selectedAddress: address,
        effect: AddressEffect.actions,
        message: null,
      ),
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
            message: null,
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
            message: null,
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
        message: null,
      ),
    );
  }

  Future<void> applyAddressEditor(DeliveryAddress? address) {
    if (address != null && canSaveProfileAddress(state.addresses, address)) {
      emit(
        state.copyWith(
          saveStatus: RequestStatus.loading,
          failure: null,
          message: null,
        ),
      );
      return repository.saveAddress(address).then((result) {
        switch (result) {
          case Success(:final data):
            emit(
              state.copyWith(
                addresses: [
                  for (final item in state.addresses)
                    if (item.address.id == data.address.id) data else item,
                  if (!state.addresses.any(
                    (item) => item.address.id == data.address.id,
                  ))
                    data,
                ],
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
      });
    } else if (address != null) {
      emit(state.copyWith(effect: AddressEffect.minimumAddress, message: null));
    }
    return Future.value();
  }

  Future<void> submitDeletion(ProfileAddress address) {
    emit(
      state.copyWith(
        deletionStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return repository.deleteAddress(address.address.id).then((result) {
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
    });
  }

  Future<void> submitAddressReview(ProfileAddress address) {
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
        failure: null,
        message: null,
      ),
    );
    return repository.reviewAddress(address.address).then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              addresses: [
                for (final item in state.addresses)
                  if (item.address == address.address)
                    item.withStatus(data)
                  else
                    item,
              ],
              reviewStatuses: {
                ...state.reviewStatuses,
                address.address.id: RequestStatus.success,
              },
            ),
          );
        case Err(:final failure):
          emit(
            state.copyWith(
              addresses: [
                for (final item in state.addresses)
                  if (item.address == address.address)
                    item.withStatus(ResidenceStatus.unchecked)
                  else
                    item,
              ],
              reviewStatuses: {
                ...state.reviewStatuses,
                address.address.id: RequestStatus.failure,
              },
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
      }
    });
  }

  void requestBack() {
    emit(state.copyWith(effect: AddressEffect.back, message: null));
  }

  void requestAssistant() {
    emit(state.copyWith(effect: AddressEffect.assistant, message: null));
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumeAddressesInteraction() {
    emit(state.copyWith(effect: null));
  }
}
