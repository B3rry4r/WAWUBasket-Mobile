import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

extension WBL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
