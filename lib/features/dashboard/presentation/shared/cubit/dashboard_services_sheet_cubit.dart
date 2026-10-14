import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../dashboard_services.dart';

part 'dashboard_services_sheet_state.dart';
part 'dashboard_services_sheet_cubit.freezed.dart';

class DashboardServicesSheetCubit extends Cubit<DashboardServicesSheetState> {
  DashboardServicesSheetCubit({String initialQuery = ''})
    : super(DashboardServicesSheetState.initial(query: initialQuery));

  void updateQuery(String value) {
    emit(state.copyWith(query: value.trim()));
  }

  void toggleCategory(DashboardCategory category) {
    final collapsed = Set<DashboardCategory>.of(state.collapsedCategories);
    if (!collapsed.remove(category)) collapsed.add(category);
    emit(state.copyWith(collapsedCategories: collapsed));
  }

  List<DashboardService> searchServices(
    DashboardCategory category,
    List<DashboardService>? allowed,
  ) {
    return category.services
        .where(
          (service) =>
              (allowed == null || allowed.contains(service)) &&
              normalizeQuery(service.catalogLabel())
                  .contains(normalizeQuery(state.query)),
        )
        .toList();
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
