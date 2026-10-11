import 'app_routes.dart';

/// Only implemented destinations are allowed after login; no external URLs.
String validatedReturnLocation(String? location) {
  final uri = location == null ? null : Uri.tryParse(location);
  if (uri == null || uri.hasScheme || uri.hasAuthority || uri.hasFragment) {
    return DashboardRoutes.home;
  }
  const paths = {
    DashboardRoutes.home,
    DashboardRoutes.allServices,
    CardsRoutes.list,
    CardsRoutes.issuance,
    CardsRoutes.virtualRequest,
    AuthRoutes.passwords,
    ProfileRoutes.messages,
  };
  final messageSegments = Uri.parse(ProfileRoutes.messages).pathSegments;
  final detail =
      uri.pathSegments.length == 3 &&
      uri.pathSegments[0] == messageSegments[0] &&
      uri.pathSegments[1] == messageSegments[1] &&
      uri.pathSegments[2].isNotEmpty;
  if (!paths.contains(uri.path) && !detail) return DashboardRoutes.home;
  if (uri.hasQuery) {
    if (uri.path != CardsRoutes.list ||
        uri.queryParametersAll.keys.any((k) => k != 'category') ||
        uri.queryParametersAll['category']?.length != 1 ||
        !const {
          'resalat',
          'gift',
          'virtual',
          'coupon',
          'family',
        }.contains(uri.queryParameters['category'])) {
      return DashboardRoutes.home;
    }
  }
  return uri.toString();
}
