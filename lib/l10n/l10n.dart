import 'package:flutter/widgets.dart';
import 'package:pishkhan_mobile/l10n/generated/app_localizations.dart';

export 'generated/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
