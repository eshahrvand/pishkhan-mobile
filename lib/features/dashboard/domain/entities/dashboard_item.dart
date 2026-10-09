import 'package:equatable/equatable.dart';

abstract class DashboardItem extends Equatable {
  const DashboardItem();
  String get id;

  /// Detach mutable input collections before an item enters state.
  DashboardItem snapshot();
}
