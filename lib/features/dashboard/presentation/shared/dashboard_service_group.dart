import 'package:equatable/equatable.dart';

import 'dashboard_services.dart';

class DashboardServiceChoice extends Equatable {
  const DashboardServiceChoice({
    required this.service,
    required this.canSelect,
  });

  final DashboardService service;
  final bool canSelect;

  @override
  List<Object?> get props => [service, canSelect];
}

class DashboardServiceGroup extends Equatable {
  DashboardServiceGroup({
    required this.category,
    required Iterable<DashboardServiceChoice> choices,
    required this.isCollapsed,
    required this.canToggle,
  }) : choices = List.unmodifiable(choices);

  final DashboardCategory category;
  final List<DashboardServiceChoice> choices;
  final bool isCollapsed;
  final bool canToggle;

  @override
  List<Object?> get props => [category, choices, isCollapsed, canToggle];
}
