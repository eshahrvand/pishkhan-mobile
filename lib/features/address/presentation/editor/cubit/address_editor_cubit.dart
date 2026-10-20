import 'package:pishkhan_mobile/core/validators/required_text_validator.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:pishkhan_mobile/core/validators/telephone_number_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/validators/postal_code_validator.dart';

import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';

part 'address_editor_state.dart';
part 'address_editor_cubit.freezed.dart';

class AddressEditorCubit extends Cubit<AddressEditorState> {
  AddressEditorCubit({
    AddressEditorState initialState = const AddressEditorState.initial(),
    this.initialAddress,
    this.includeContact = false,
    this.retainHomeAddress = false,
  }) : super(initialState);

  final DeliveryAddress? initialAddress;
  final bool includeContact;
  final bool retainHomeAddress;

  void fetchAddress() {
    final address = initialAddress!;
    emit(
      state.copyWith(
        title: address.title,
        detail: address.detail,
        postalCode: address.postalCode,
        phoneNumber: address.phoneNumber,
        type: address.type,
        isTitleValid: true,
        isDetailValid: true,
        isPostalCodeValid: true,
        isPhoneNumberValid: address.phoneNumber.isNotEmpty,
      ),
    );
  }

  void selectType(DeliveryAddressType type) {
    if (retainHomeAddress && type == DeliveryAddressType.work) {
      emit(state.copyWith(minimumHomeNoticeId: state.minimumHomeNoticeId + 1));
    } else {
      emit(state.copyWith(type: type));
    }
  }

  void updatePhoneNumber(String value) {
    final normalized = DigitNormalizer.normalize(value);
    final valid = TelephoneNumberValidator.isValid(normalized);
    emit(
      state.copyWith(
        phoneNumber: normalized,
        isPhoneNumberValid: valid,
        isInvalid:
            state.isInvalid &&
            !(valid &&
                state.isTitleValid &&
                state.isDetailValid &&
                state.isPostalCodeValid),
      ),
    );
  }

  void updateTitle(String value) {
    final valid = RequiredTextValidator.isValid(value);
    emit(
      state.copyWith(
        title: value,
        isTitleValid: valid,
        isInvalid:
            state.isInvalid &&
            !(valid &&
                state.isDetailValid &&
                state.isPostalCodeValid &&
                (!includeContact || state.isPhoneNumberValid)),
      ),
    );
  }

  void updateDetail(String value) {
    final valid = RequiredTextValidator.isValid(value);
    emit(
      state.copyWith(
        detail: value,
        isDetailValid: valid,
        isInvalid:
            state.isInvalid &&
            !(state.isTitleValid &&
                valid &&
                state.isPostalCodeValid &&
                (!includeContact || state.isPhoneNumberValid)),
      ),
    );
  }

  void updatePostalCode(String value) {
    final normalized = DigitNormalizer.normalize(value).trim();
    final valid = PostalCodeValidator.isValid(normalized);
    emit(
      state.copyWith(
        postalCode: normalized,
        isPostalCodeValid: valid,
        isInvalid:
            state.isInvalid &&
            !(state.isTitleValid &&
                state.isDetailValid &&
                valid &&
                (!includeContact || state.isPhoneNumberValid)),
      ),
    );
  }

  void submitAddress() {
    if (state.isTitleValid &&
        state.isDetailValid &&
        state.isPostalCodeValid &&
        (!includeContact || state.isPhoneNumberValid)) {
      final address = DeliveryAddress(
        id:
            initialAddress?.id ??
            'local-${DateTime.now().microsecondsSinceEpoch}',
        phoneNumber: state.phoneNumber,
        type: state.type,
        title: state.title.trim(),
        detail: state.detail.trim(),
        postalCode: state.postalCode,
      );
      emit(state.copyWith(savedAddress: address, saveId: state.saveId + 1));
    } else {
      emit(state.copyWith(isInvalid: true));
    }
  }
}
