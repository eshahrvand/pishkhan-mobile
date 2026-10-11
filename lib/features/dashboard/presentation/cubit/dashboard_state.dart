import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../domain/entities/dashboard_home_data.dart';

part 'dashboard_state.freezed.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    @Default(RequestStatus.initial) RequestStatus status,
    DashboardHomeData? data,
    List<String>? draft,
    Failure? failure,
  }) = _DashboardState;
}
