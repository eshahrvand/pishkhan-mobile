import 'package:equatable/equatable.dart';

class DashboardHomeData extends Equatable {
  DashboardHomeData({
    required this.walletBalance,
    Iterable<String> favorites = const [],
    Iterable<String> fixedServiceIds = const [],
    Iterable<String> suggestedServiceIds = const [],
  }) : favorites = List.unmodifiable(favorites),
       fixedServiceIds = List.unmodifiable(fixedServiceIds),
       suggestedServiceIds = List.unmodifiable(suggestedServiceIds);
  final String walletBalance;
  final List<String> favorites, fixedServiceIds, suggestedServiceIds;
  DashboardHomeData withFavorites(Iterable<String> values) => DashboardHomeData(
    walletBalance: walletBalance,
    favorites: values,
    fixedServiceIds: fixedServiceIds,
    suggestedServiceIds: suggestedServiceIds,
  );
  @override
  List<Object?> get props => [
    walletBalance,
    favorites,
    fixedServiceIds,
    suggestedServiceIds,
  ];
}
