import 'app_routes.dart';

/// Only implemented destinations are allowed after login; no external URLs.
String validatedReturnLocation(String? location) {
  final uri = location == null ? null : Uri.tryParse(location);
  if (uri == null || uri.hasScheme || uri.hasAuthority || uri.hasFragment) {
    return AppRoutes.home;
  }
  const paths = {
    AppRoutes.home,
    AppRoutes.allServices,
    AppRoutes.cardList,
    AppRoutes.depositList,
    AppRoutes.averageBalance,
    AppRoutes.financialCertificate,
    AppRoutes.introduceAgent,
    AppRoutes.agentSettings,
    AppRoutes.closeSurplusDeposits,
    AppRoutes.blockDeposit,
    AppRoutes.unblockDeposit,
    AppRoutes.cardIssuance,
    AppRoutes.virtualCardRequest,
    AppRoutes.changeCardDeposit,
    AppRoutes.expiredGiftBalance,
    AppRoutes.cardPasswords,
    AppRoutes.messages,
  };
  final messageSegments = Uri.parse(AppRoutes.messages).pathSegments;
  final detail =
      uri.pathSegments.length == 3 &&
      uri.pathSegments[0] == messageSegments[0] &&
      uri.pathSegments[1] == messageSegments[1] &&
      uri.pathSegments[2].isNotEmpty;
  if (!paths.contains(uri.path) && !detail) return AppRoutes.home;
  if (uri.hasQuery) {
    if (uri.path != AppRoutes.cardList ||
        uri.queryParametersAll.keys.any((k) => k != 'category') ||
        uri.queryParametersAll['category']?.length != 1 ||
        !const {
          'resalat',
          'gift',
          'virtual',
          'coupon',
          'family',
        }.contains(uri.queryParameters['category'])) {
      return AppRoutes.home;
    }
  }
  return uri.toString();
}
