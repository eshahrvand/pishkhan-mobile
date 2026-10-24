sealed class AuthEffect {
  const AuthEffect();
}

final class AuthServicesRequested extends AuthEffect {
  const AuthServicesRequested();
}

final class AuthGuestServiceRequested extends AuthEffect {
  const AuthGuestServiceRequested(this.id);
  final String id;
}

final class AuthCompleted extends AuthEffect {
  const AuthCompleted();
}

final class AuthOtpRequested extends AuthEffect {
  const AuthOtpRequested();
}

final class AuthMessageRequested extends AuthEffect {
  const AuthMessageRequested();
}
