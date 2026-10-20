import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pishkhan_mobile/core/di/injection_container.dart';
import 'package:pishkhan_mobile/core/enums/request_status.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';
import 'package:pishkhan_mobile/core/result/result.dart';

import '../../../domain/entities/request_report.dart';
import '../../../domain/repositories/request_reports_repository.dart';
import '../../../domain/usecases/filter_request_reports.dart';

part 'request_reports_state.dart';
part 'request_reports_cubit.freezed.dart';

class RequestReportsCubit extends Cubit<RequestReportsState> {
  RequestReportsCubit({
    RequestReportsState initialState = const RequestReportsState.initial(),
  }) : super(initialState);

  final repository = getIt<RequestReportsRepository>();

  Future<void> fetchReports() {
    emit(
      state.copyWith(
        reportsStatus: RequestStatus.loading,
        reportsFailure: null,
      ),
    );
    return repository.fetchReports().then((result) {
      switch (result) {
        case Success(:final data):
          emit(
            state.copyWith(
              reportsStatus: RequestStatus.success,
              reports: data.reports,
              bankTime: data.bankTime,
              visibleReports: filterRequestReports(
                reports: data.reports,
                filter: state.filter,
                query: state.trackingQuery,
                bankTime: data.bankTime,
              ),
            ),
          );
        case Err(:final failure):
          emit(
            state.copyWith(
              reportsStatus: RequestStatus.failure,
              reportsFailure: failure,
            ),
          );
      }
    });
  }

  void updateTrackingQuery(String value) {
    emit(
      state.copyWith(
        trackingQuery: value,
        visibleReports: filterRequestReports(
          reports: state.reports,
          filter: state.filter,
          query: value,
          bankTime: state.bankTime!,
        ),
      ),
    );
  }

  void requestTypeFilter() {
    if (state.filter.types != null) {
      final filter = RequestReportFilter(
        statuses: state.filter.statuses,
        period: state.filter.period,
      );
      emit(
        state.copyWith(
          filter: filter,
          visibleReports: filterRequestReports(
            reports: state.reports,
            filter: filter,
            query: state.trackingQuery,
            bankTime: state.bankTime!,
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          draftFilter: state.filter,
          typeQuery: '',
          visibleTypes: ReportRequestType.values,
          effect: RequestReportsEffect.typeFilter,
          effectId: state.effectId + 1,
        ),
      );
    }
  }

  void requestStatusFilter() {
    if (state.filter.statuses != null) {
      final filter = RequestReportFilter(
        types: state.filter.types,
        period: state.filter.period,
      );
      emit(
        state.copyWith(
          filter: filter,
          visibleReports: filterRequestReports(
            reports: state.reports,
            filter: filter,
            query: state.trackingQuery,
            bankTime: state.bankTime!,
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          draftFilter: state.filter,
          effect: RequestReportsEffect.statusFilter,
          effectId: state.effectId + 1,
        ),
      );
    }
  }

  void requestDateFilter() {
    if (state.filter.period != ReportDatePeriod.all) {
      final filter = RequestReportFilter(
        types: state.filter.types,
        statuses: state.filter.statuses,
      );
      emit(
        state.copyWith(
          filter: filter,
          visibleReports: filterRequestReports(
            reports: state.reports,
            filter: filter,
            query: state.trackingQuery,
            bankTime: state.bankTime!,
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          draftFilter: state.filter,
          effect: RequestReportsEffect.dateFilter,
          effectId: state.effectId + 1,
        ),
      );
    }
  }

  void updateTypeQuery(String value) {
    emit(
      state.copyWith(typeQuery: value, visibleTypes: searchReportTypes(value)),
    );
  }

  void toggleDraftType(ReportRequestType type) {
    final types = {...(state.draftFilter!.types ?? ReportRequestType.values)};
    if (types.contains(type)) {
      types.remove(type);
    } else {
      types.add(type);
    }
    emit(
      state.copyWith(
        draftFilter: RequestReportFilter(
          types: types.length == ReportRequestType.values.length
              ? null
              : Set.unmodifiable(types),
          statuses: state.draftFilter!.statuses,
          period: state.draftFilter!.period,
        ),
      ),
    );
  }

  void toggleAllDraftTypes() {
    emit(
      state.copyWith(
        draftFilter: RequestReportFilter(
          types: state.draftFilter!.types == null ? const {} : null,
          statuses: state.draftFilter!.statuses,
          period: state.draftFilter!.period,
        ),
      ),
    );
  }

  void toggleDraftStatus(ReportRequestStatus status) {
    final statuses = {
      ...(state.draftFilter!.statuses ?? ReportRequestStatus.values),
    };
    if (statuses.contains(status)) {
      statuses.remove(status);
    } else {
      statuses.add(status);
    }
    emit(
      state.copyWith(
        draftFilter: RequestReportFilter(
          types: state.draftFilter!.types,
          statuses: statuses.length == ReportRequestStatus.values.length
              ? null
              : Set.unmodifiable(statuses),
          period: state.draftFilter!.period,
        ),
      ),
    );
  }

  void toggleAllDraftStatuses() {
    emit(
      state.copyWith(
        draftFilter: RequestReportFilter(
          types: state.draftFilter!.types,
          statuses: state.draftFilter!.statuses == null ? const {} : null,
          period: state.draftFilter!.period,
        ),
      ),
    );
  }

  void selectDraftPeriod(ReportDatePeriod period) {
    emit(
      state.copyWith(
        draftFilter: RequestReportFilter(
          types: state.draftFilter!.types,
          statuses: state.draftFilter!.statuses,
          period: period,
        ),
      ),
    );
  }

  void applyFilter() {
    emit(
      state.copyWith(
        filter: state.draftFilter!,
        visibleReports: filterRequestReports(
          reports: state.reports,
          filter: state.draftFilter!,
          query: state.trackingQuery,
          bankTime: state.bankTime!,
        ),
      ),
    );
  }

  void cancelDraftFilter() {
    emit(state.copyWith(draftFilter: null));
  }

  void requestDetails(RequestReport report) {
    emit(
      state.copyWith(
        selectedReport: report,
        canCancelRequest: report.status == ReportRequestStatus.awaitingApproval,
        effect: RequestReportsEffect.details,
        effectId: state.effectId + 1,
      ),
    );
  }

  void applyDetailsResult(RequestDetailsAction? result) {
    switch (result) {
      case RequestDetailsAction.cancelRequest:
        emit(
          state.copyWith(
            cancellationStatus: RequestStatus.initial,
            cancellationFailure: null,
            effect: RequestReportsEffect.cancelConfirmation,
            effectId: state.effectId + 1,
          ),
        );
      case null:
        break;
    }
  }

  Future<void> submitCancellation() {
    emit(
      state.copyWith(
        cancellationStatus: RequestStatus.loading,
        cancellationFailure: null,
      ),
    );
    return repository
        .cancelRequest(
          trackingId: state.selectedReport!.trackingId,
          idempotencyKey: 'cancel:${state.selectedReport!.trackingId}',
        )
        .then((result) {
          switch (result) {
            case Success(:final data):
              final reports = [
                for (final report in state.reports)
                  if (report.trackingId == data.trackingId) data else report,
              ];
              emit(
                state.copyWith(
                  cancellationStatus: RequestStatus.success,
                  selectedReport: data,
                  canCancelRequest: false,
                  reports: reports,
                  visibleReports: filterRequestReports(
                    reports: reports,
                    filter: state.filter,
                    query: state.trackingQuery,
                    bankTime: state.bankTime!,
                  ),
                ),
              );
            case Err(:final failure):
              emit(
                state.copyWith(
                  cancellationStatus: RequestStatus.failure,
                  cancellationFailure: failure,
                ),
              );
          }
        });
  }

  void requestBack() {
    emit(
      state.copyWith(
        effect: RequestReportsEffect.back,
        effectId: state.effectId + 1,
      ),
    );
  }

  void requestAssistant() {
    emit(
      state.copyWith(
        effect: RequestReportsEffect.assistant,
        effectId: state.effectId + 1,
      ),
    );
  }
}
