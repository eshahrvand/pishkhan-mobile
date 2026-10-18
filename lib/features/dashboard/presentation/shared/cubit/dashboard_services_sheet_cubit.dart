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

  void resolveServices(Map<DashboardService, String> searchLabels) {
    _searchLabels = Map.unmodifiable(searchLabels);
    emit(
      state.copyWith(
        groups: _filterGroups(state.query, state.collapsedCategories),
        isSearching: _normalizeQuery(state.query).isNotEmpty,
      ),
    );
  }

  void updateSearchQuery(String value) {
    emit(
      state.copyWith(
        query: value,
        isSearching: _normalizeQuery(value).isNotEmpty,
        groups: _filterGroups(value, state.collapsedCategories),
      ),
    );
  }

  void toggleCategory(DashboardCategory category) {
    final collapsed = Set<DashboardCategory>.of(state.collapsedCategories);
    if (!collapsed.remove(category)) collapsed.add(category);
    emit(
      state.copyWith(
        collapsedCategories: collapsed,
        groups: _filterGroups(state.query, collapsed),
      ),
    );
  }

  void selectService(DashboardService service) {
    emit(
      state.copyWith(
        selectedService: service,
        selectionId: state.selectionId + 1,
      ),
    );
  }

  List<DashboardServiceGroup> _filterGroups(
    String query,
    Set<DashboardCategory> collapsed,
  ) {
    final normalized = _normalizeQuery(query);
    final groups = <DashboardServiceGroup>[];
    for (final category in DashboardCategory.values) {
      final choices = category.services
          .where(
            (service) =>
                (_allowed == null || _allowed.contains(service)) &&
                _normalizeQuery(_searchLabels[service] ?? '')
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

  String _normalizeQuery(String value) {
    return value
        .trim()
        .replaceAll('ي', 'ی')
        .replaceAll('ك', 'ک')
        .replaceAll('\u200c', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
