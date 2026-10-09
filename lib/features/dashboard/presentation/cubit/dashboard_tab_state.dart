import 'package:equatable/equatable.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../domain/entities/dashboard_item.dart';

enum DashboardItemLayout { single, multiple }

sealed class DashboardTabState<T extends DashboardItem> extends Equatable {
  const DashboardTabState();
  DashboardTabLoaded<T>? get previous => null;
  @override
  List<Object?> get props => [];
}

final class DashboardTabInitial<T extends DashboardItem>
    extends DashboardTabState<T> {
  const DashboardTabInitial();
}

final class DashboardTabLoading<T extends DashboardItem>
    extends DashboardTabState<T> {
  const DashboardTabLoading({this.previous});
  @override
  final DashboardTabLoaded<T>? previous;
  @override
  List<Object?> get props => [previous];
}

final class DashboardTabEmpty<T extends DashboardItem>
    extends DashboardTabState<T> {
  const DashboardTabEmpty();
}

final class DashboardTabError<T extends DashboardItem>
    extends DashboardTabState<T> {
  const DashboardTabError(this.failure, {this.previous});
  final Failure failure;
  @override
  final DashboardTabLoaded<T>? previous;
  @override
  List<Object?> get props => [failure, previous];
}

class DashboardTabLoaded<T extends DashboardItem> extends DashboardTabState<T> {
  DashboardTabLoaded({required Iterable<T> items, required this.selectedId})
    : items = List.unmodifiable(items);
  final List<T> items;
  final String selectedId;
  int get selectedIndex => items.indexWhere((item) => item.id == selectedId);
  T get selected => items[selectedIndex];
  DashboardItemLayout get layout => items.length == 1
      ? DashboardItemLayout.single
      : DashboardItemLayout.multiple;
  bool get isSingle => layout == DashboardItemLayout.single;
  @override
  DashboardTabLoaded<T> get previous => this;
  @override
  List<Object?> get props => [items, selectedId];
}
