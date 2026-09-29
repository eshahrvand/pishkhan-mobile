// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Resalat Virtual Counter';

  @override
  String get changeMobileTitle => 'Change mobile number';

  @override
  String get backLabel => 'Back';

  @override
  String get closeLabel => 'Close';

  @override
  String get servicesMenuLabel => 'Services menu';

  @override
  String get changeMobileDescription =>
      'Enter the following information to access the counter and change your mobile number';

  @override
  String get loginTitle => 'Sign in to the virtual counter';

  @override
  String get loginNationalIdHint =>
      'National ID | Identity number | Foreigner code';

  @override
  String get changeNationalIdHint =>
      'Enter your national ID or identity number';

  @override
  String get loginPhoneHint => 'Enter your mobile number';

  @override
  String get changePhoneHint => 'Enter your new mobile number';

  @override
  String get changePhoneAction => 'Change mobile number';

  @override
  String get requestTwoFactorCode => 'Request two-factor code';

  @override
  String get requestOtp => 'Request verification code';

  @override
  String get phoneOwnershipNotice =>
      'The number must match the account holder\'s national ID';

  @override
  String get captchaHint => 'Enter the code';

  @override
  String otpSentMessage(String phone) {
    return 'Enter the dynamic code sent to $phone.';
  }

  @override
  String get otpHint => 'Enter the code';

  @override
  String get submitRequest => 'Submit request';

  @override
  String get enterDashboard => 'Enter the counter';

  @override
  String get resendOtp => 'Resend';

  @override
  String get servicesList => 'Services list';

  @override
  String get guestServices => 'Services available without signing in';

  @override
  String get assetReport => 'Asset report';

  @override
  String get changeMobileService => 'Change mobile number';

  @override
  String get requestStatus => 'Request status';

  @override
  String get inheritance => 'Inheritance monopoly';

  @override
  String get relatedLinks => 'Related links';

  @override
  String get mobileBank => 'Mobile banking';

  @override
  String get internetBank => 'Internet banking';

  @override
  String get memberContactCenter => 'Member contact center';

  @override
  String get resalatApp => 'Resalat app';

  @override
  String get securityTips => 'Security tips';

  @override
  String get updateGuide => 'Update guide';
}
