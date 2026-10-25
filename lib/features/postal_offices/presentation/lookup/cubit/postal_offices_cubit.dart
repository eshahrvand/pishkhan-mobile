import 'package:pishkhan_mobile/core/presentation/mappers/request_error_message_mapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/postal_office.dart';
import '../../../domain/repositories/postal_offices_repository.dart';
import '../../../domain/usecases/lookup.dart';
part 'postal_offices_state.dart';
part 'postal_offices_cubit.freezed.dart';

class PostalOfficesCubit extends Cubit<PostalOfficesState> {
  PostalOfficesCubit({
    PostalOfficesState initialState = const PostalOfficesState.initial(),
  }) : super(initialState);
  final repository = getIt<PostalOfficesRepository>();

  Future<void> fetchProvinces() {
    emit(
      state.copyWith(
        provincesStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return FetchPostalProvinces(repository)().then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              provincesStatus: RequestStatus.success,
              provinces: data,
            ),
          );
        case Err(:final failure):
          emit(
            state.copyWith(
              provincesStatus: RequestStatus.failure,
              failure: failure,
              message: getRequestErrorMessage(failure),
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
        failure: null,
        message: null,
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
        failure: null,
        message: null,
      ),
    );
  }

  Future<void> searchPostalOffices() {
    emit(
      state.copyWith(
        postalOfficesStatus: RequestStatus.loading,
        failure: null,
        message: null,
      ),
    );
    return FetchPostalOffices(repository)(state.city!.id).then((result) {
      switch (result) {
        case Err(:final failure):
          emit(
            state.copyWith(
              postalOfficesStatus: RequestStatus.failure,
              failure: failure,
              message: getRequestErrorMessage(failure),
            ),
          );
        case Success(:final data):
          emit(
            state.copyWith(
              postalOfficesStatus: RequestStatus.success,
              postalOffices: data,
              postalStep: PostalOfficesStep.results,
            ),
          );
      }
    });
  }

  void requestPostalSearch() {
    emit(state.copyWith(postalStep: PostalOfficesStep.location));
  }

  void requestPostalShare() {
    final text =
        '${state.province!.name} - ${state.city!.name}\n${state.postalOffices.map((office) => '• ${office.address}').join('\n')}';
    emit(
      state.copyWith(
        postalShareText: text,
        effect: PostalOfficesEffect.share,
        message: null,
      ),
    );
  }

  /// UI has accepted the pending interaction; data and request statuses stay intact.
  void consumePostalOfficesInteraction() {
    emit(state.copyWith(effect: null));
  }
}
