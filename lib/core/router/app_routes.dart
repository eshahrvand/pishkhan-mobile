abstract final class LaunchRoutes {
  static const splash = '/launch/splash';
}

abstract final class DashboardRoutes {
  static const home = '/dashboard/home';
  static const allServices = '/dashboard/services';
}

abstract final class AuthRoutes {
  static const login = '/auth/login';
}

abstract final class CardsRoutes {
  static const passwords = '/cards/password-services';
  static const list = '/cards/list';
  static const issuance = '/cards/issuance';
  static const virtualRequest = '/cards/virtual-request';
  static const changeDeposit = '/cards/change-deposit';
  static const expiredGiftBalance = '/cards/expired-gift-balance';
}

abstract final class ProfileRoutes {
  static const messages = '/profile/messages';
  static const messageDetail = '/profile/messages/:messageId';
}

abstract final class DepositsRoutes {
  static const list = '/deposits/list';
  static const averageBalance = '/deposits/average-balance';
  static const financialCertificate = '/deposits/financial-certificate';
}
