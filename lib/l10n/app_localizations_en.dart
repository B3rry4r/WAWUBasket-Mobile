// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'WAWUBasket';

  @override
  String get navHome => 'Home';

  @override
  String get navTrade => 'Trade';

  @override
  String get navOrders => 'Orders';

  @override
  String get navAccount => 'Account';

  @override
  String get navSearch => 'Search';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDone => 'Done';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionNext => 'Next';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionSeeAll => 'See all';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonError => 'Something went wrong.';

  @override
  String get commonEmpty => 'Nothing here yet.';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Choose how WAWUBasket speaks to you.';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get logOut => 'Log out';

  @override
  String get chatEmpty => 'No messages yet. Send the first one below.';

  @override
  String get chatInboxEmpty =>
      'No order chats yet. They appear here once you have an active order.';

  @override
  String get chatSupportPrompt => 'Questions? Chat with our team.';

  @override
  String get chatAttachmentFailed => 'Couldn\'t send the attachment.';

  @override
  String get kycSubmitted =>
      'Application submitted. We\'ll review it and let you know.';

  @override
  String get kycUploadFailed => 'Couldn\'t upload the document. Try again.';
}
