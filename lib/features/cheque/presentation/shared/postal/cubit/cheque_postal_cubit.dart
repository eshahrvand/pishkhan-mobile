import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../../domain/entities/cheque_clearance.dart';
import '../../../../domain/repositories/cheque_clearance_repository.dart';
import '../../../../domain/usecases/cheque_clearance.dart';
part 'cheque_postal_state.dart';
part 'cheque_postal_cubit.freezed.dart';

class ChequePostalCubit extends Cubit<ChequePostalState> {
  ChequePostalCubit({
    ChequePostalState initialState = const ChequePostalState.initial(),
  }) : super(initialState);
  final repository = getIt<ChequeClearanceRepository>();

  Future<void> fetchProvinces() {
    emit(
      state.copyWith(
        provincesStatus: RequestStatus.loading,
        provincesFailure: null,
      ),
    );
    return FetchChequeClearanceCatalog(repository)().then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              provincesStatus: RequestStatus.success,
              provinces: data.provinces,
            ),
          );
        case Err(:final failure):
          emit(
            state.copyWith(
              provincesStatus: RequestStatus.failure,
              provincesFailure: failure,
            ),
          );
      }
    });
  }

  void selectProvince(PostalProvince province) {
    emit(
      state.copyWith(
        province: province,
        cities: province.cities,
        city: null,
        canSearchPostalOffices: false,
        postalOffices: const [],
        postalOfficesStatus: RequestStatus.initial,
        postalOfficesFailure: null,
      ),
    );
  }

  void selectCity(PostalCity city) {
    emit(
      state.copyWith(
        city: city,
        canSearchPostalOffices: true,
        postalOffices: const [],
        postalOfficesStatus: RequestStatus.initial,
        postalOfficesFailure: null,
      ),
    );
  }

  Future<void> searchPostalOffices() {
    emit(
      state.copyWith(
        postalOfficesStatus: RequestStatus.loading,
        postalOfficesFailure: null,
      ),
    );
    return FetchChequePostalOffices(repository)(state.city!.id).then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              postalOfficesStatus: RequestStatus.failure,
              postalOfficesFailure: failure,
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              postalOfficesStatus: RequestStatus.success,
              postalOffices: data,
              postalStep: ChequePostalStep.results,
            ),
          );
      }
    });
  }

  void requestPostalSearch() {
    emit(state.copyWith(postalStep: ChequePostalStep.location));
  }

  void requestPostalShare() {
    final text =
        '${state.province!.name} - ${state.city!.name}\n${state.postalOffices.map((office) => '• ${office.address}').join('\n')}';
    emit(
      state.copyWith(
        postalShareText: text,
        effect: ChequePostalEffect.share,
        effectId: state.effectId + 1,
      ),
    );
  }
}
