import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../dashboard_services.dart';
import '../dashboard_service_group.dart';

part 'dashboard_services_sheet_state.dart';
part 'dashboard_services_sheet_cubit.freezed.dart';

class DashboardServicesSheetCubit extends Cubit<DashboardServicesSheetState> {
  DashboardServicesSheetCubit({
    DashboardServicesSheetState initialState =
        const DashboardServicesSheetState.initial(),
    Iterable<String> excluded = const [],
    List<DashboardService>? category,
  }) : _excluded = Set.unmodifiable(excluded),
       _allowed = category == null ? null : Set.unmodifiable(category),
       super(initialState);

  final Set<String> _excluded;
  final Set<DashboardService>? _allowed;
  Map<DashboardService, String> _searchLabels = const {};

  void loadServices(Map<DashboardService, String> searchLabels) {
    _searchLabels = Map.unmodifiable(searchLabels);
    emit(
      state.copyWith(
        groups: filterGroups(state.query, state.collapsedCategories),
        isSearching: normalizeQuery(state.query).isNotEmpty,
      ),
    );
  }

  void updateQuery(String value) {
    emit(
      state.copyWith(
        query: value,
        isSearching: normalizeQuery(value).isNotEmpty,
        groups: filterGroups(value, state.collapsedCategories),
      ),
    );
  }

  void toggleCategory(DashboardCategory category) {
    if (state.isSearching || category != DashboardCategory.cards) return;
    final collapsed = Set<DashboardCategory>.of(state.collapsedCategories);
    if (!collapsed.remove(category)) collapsed.add(category);
    emit(
      state.copyWith(
        collapsedCategories: collapsed,
        groups: filterGroups(state.query, collapsed),
      ),
    );
  }

  DashboardService? selectService(DashboardService service) {
    if (isClosed || _excluded.contains(service.id)) return null;
    for (final group in state.groups) {
      if (group.choices.any((choice) => choice.service == service)) {
        emit(
          state.copyWith(
            selectedService: service,
            selectionId: state.selectionId + 1,
          ),
        );
        return service;
      }
    }
    return null;
  }

  List<DashboardServiceGroup> filterGroups(
    String query,
    Set<DashboardCategory> collapsed,
  ) {
    final normalized = normalizeQuery(query);
    final groups = <DashboardServiceGroup>[];
    for (final category in DashboardCategory.values) {
      final choices = category.services
          .where(
            (service) =>
                (_allowed == null || _allowed.contains(service)) &&
                normalizeQuery(_searchLabels[service] ?? '')
                    .contains(normalized),
          )
          .map(
            (service) => DashboardServiceChoice(
              service: service,
              canSelect: !_excluded.contains(service.id),
            ),
          )
          .toList();
      if (choices.isEmpty) continue;
      groups.add(
        DashboardServiceGroup(
          category: category,
          choices: choices,
          isCollapsed: normalized.isEmpty && collapsed.contains(category),
          canToggle: normalized.isEmpty && category == DashboardCategory.cards,
        ),
      );
    }
    return groups;
  }

  String normalizeQuery(String value) {
    return value
        .trim()
        .replaceAll('ي', 'ی')
        .replaceAll('ك', 'ک')
        .replaceAll('\u200c', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
