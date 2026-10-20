/// Route paths and URL builders. This file has no feature dependencies.
abstract final class AppRoutes {
  static const splash = '/launch/splash';

  static const home = '/dashboard/home';
  static const allServices = '/dashboard/services';

  static const login = '/auth/login';

  static const cardPasswords = '/cards/password-services';
  static const cardList = '/cards/list';
  static const cardIssuance = '/cards/issuance';
  static const virtualCardRequest = '/cards/virtual-request';
  static const changeCardDeposit = '/cards/change-deposit';
  static const expiredGiftBalance = '/cards/expired-gift-balance';

  static const depositList = '/deposits/list';
  static const averageBalance = '/deposits/average-balance';
  static const financialCertificate = '/deposits/financial-certificate';
  static const introduceAgent = '/deposits/introduce-representative';
  static const agentSettings = '/deposits/representation-settings';
  static const closeSurplusDeposits = '/deposits/close-surplus-deposits';
  static const blockDeposit = '/deposits/block';
  static const unblockDeposit = '/deposits/unblock';
  static const proxyDeposit = '/deposits/proxy';

  static const onSiteTransfer = '/transfers/on-site';

  static const chequeCancellation = '/cheque/cancellation';
  static const chequeBook = '/cheque/book-issuance';
  static const chequeClearance = '/cheque/clearance';

  static const messages = '/profile/messages';
  static const messageDetail = '/profile/messages/:messageId';

  static String cardListLocation(String category) =>
      Uri(path: cardList, queryParameters: {'category': category}).toString();

  static String messageDetailLocation(String id) =>
      '$messages/${Uri.encodeComponent(id)}';
}
