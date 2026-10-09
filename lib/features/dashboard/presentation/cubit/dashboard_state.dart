import 'package:equatable/equatable.dart';
import 'package:pishkhan_mobile/core/result/failure.dart';

import '../../domain/entities/dashboard_home_data.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();
  List<String> get favorites => const [];
  List<String>? get draft => null;
  bool get isEditing => draft != null;
  List<String> get visibleFavorites => draft ?? favorites;
  @override
  List<Object?> get props => [];
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardEmpty extends DashboardState {
  const DashboardEmpty();
}

final class DashboardError extends DashboardState {
  const DashboardError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

final class DashboardLoaded extends DashboardState {
  DashboardLoaded({required this.data, Iterable<String>? draft})
    : draft = draft == null ? null : List.unmodifiable(draft);
  final DashboardHomeData data;
  @override
  List<String> get favorites => data.favorites;
  @override
  final List<String>? draft;
  @override
  List<Object?> get props => [data, draft];
}
