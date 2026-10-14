import 'package:avp_ui/avp_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/validators/postal_code_validator.dart';

import '../../../domain/entities/certificate_data.dart';

part 'certificate_address_state.dart';
part 'certificate_address_cubit.freezed.dart';

class CertificateAddressCubit extends Cubit<CertificateAddressState> {
  CertificateAddressCubit() : super(const CertificateAddressState.initial());

  void updateTitle(String value) {
    emit(state.copyWith(title: value));
  }

  void updateDetail(String value) {
    emit(state.copyWith(detail: value));
  }

  void updatePostalCode(String value) {
    emit(state.copyWith(postalCode: value));
  }

  CertificateAddress? submit() {
    final postalCode = DigitNormalizer.normalize(state.postalCode).trim();
    if (state.title.trim().isEmpty ||
        state.detail.trim().isEmpty ||
        !PostalCodeValidator.isValid(postalCode)) {
      emit(state.copyWith(isInvalid: true));
      return null;
    }
    return CertificateAddress(
      id: 'local',
      title: state.title.trim(),
      detail: state.detail.trim(),
      postalCode: postalCode,
    );
  }
}
