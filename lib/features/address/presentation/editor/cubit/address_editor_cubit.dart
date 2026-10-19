import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/validators/postal_code_validator.dart';

import 'package:pishkhan_mobile/core/domain/entities/delivery_address.dart';

part 'address_editor_state.dart';
part 'address_editor_cubit.freezed.dart';

class AddressEditorCubit extends Cubit<AddressEditorState> {
  AddressEditorCubit({
    AddressEditorState initialState = const AddressEditorState.initial(),
  }) : super(initialState);

  void updateTitle(String value) {
    final valid = value.trim().isNotEmpty;
    emit(
      state.copyWith(
        title: value,
        isTitleValid: valid,
        isInvalid:
            state.isInvalid &&
            !(valid && state.isDetailValid && state.isPostalCodeValid),
      ),
    );
  }

  void updateDetail(String value) {
    final valid = value.trim().isNotEmpty;
    emit(
      state.copyWith(
        detail: value,
        isDetailValid: valid,
        isInvalid:
            state.isInvalid &&
            !(state.isTitleValid && valid && state.isPostalCodeValid),
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
            !(state.isTitleValid && state.isDetailValid && valid),
      ),
    );
  }

  void submitAddress() {
    if (state.isTitleValid && state.isDetailValid && state.isPostalCodeValid) {
      final address = DeliveryAddress(
        id: 'local',
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
