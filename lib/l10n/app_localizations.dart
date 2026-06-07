import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_ee.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ha.dart';
import 'app_localizations_ig.dart';
import 'app_localizations_ln.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_rw.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_tw.dart';
import 'app_localizations_wo.dart';
import 'app_localizations_yo.dart';
import 'app_localizations_zu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('ar'),
    Locale('ee'),
    Locale('en'),
    Locale('fr'),
    Locale('ha'),
    Locale('ig'),
    Locale('ln'),
    Locale('pt'),
    Locale('rw'),
    Locale('sw'),
    Locale('tw'),
    Locale('wo'),
    Locale('yo'),
    Locale('zu'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'WAWUBasket'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navServices;

  /// No description provided for @navTrade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get navTrade;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get actionSeeAll;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get commonError;

  /// No description provided for @commonEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get commonEmpty;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how WAWUBasket speaks to you.'**
  String get languageSubtitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @chatEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Send the first one below.'**
  String get chatEmpty;

  /// No description provided for @chatInboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'No order chats yet. They appear here once you have an active order.'**
  String get chatInboxEmpty;

  /// No description provided for @chatSupportPrompt.
  ///
  /// In en, this message translates to:
  /// **'Questions? Chat with our team.'**
  String get chatSupportPrompt;

  /// No description provided for @chatAttachmentFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the attachment.'**
  String get chatAttachmentFailed;

  /// No description provided for @kycSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application submitted. We\'ll review it and let you know.'**
  String get kycSubmitted;

  /// No description provided for @kycUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t upload the document. Try again.'**
  String get kycUploadFailed;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'One basket. Everything.'**
  String get splashTagline;

  /// No description provided for @splashHeadline.
  ///
  /// In en, this message translates to:
  /// **'One Basket,\nEverything'**
  String get splashHeadline;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'A couple of quick permissions'**
  String get onboardingPermissionsTitle;

  /// No description provided for @onboardingPermissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'They make the basket work better for you. You can change these anytime.'**
  String get onboardingPermissionsSubtitle;

  /// No description provided for @onboardingLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you cooking today?'**
  String get onboardingLocationTitle;

  /// No description provided for @onboardingLocationBody.
  ///
  /// In en, this message translates to:
  /// **'We need your location to show restaurants and markets near you. We never share your exact location with anyone.'**
  String get onboardingLocationBody;

  /// No description provided for @onboardingLocationPrimary.
  ///
  /// In en, this message translates to:
  /// **'While using app'**
  String get onboardingLocationPrimary;

  /// No description provided for @onboardingLocationSecondary.
  ///
  /// In en, this message translates to:
  /// **'Allow once'**
  String get onboardingLocationSecondary;

  /// No description provided for @onboardingLocationTertiary.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get onboardingLocationTertiary;

  /// No description provided for @onboardingNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t miss the good stuff'**
  String get onboardingNotificationsTitle;

  /// No description provided for @onboardingNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll tell you when your order is on its way, when your meat is freshly cut, and when there\'s a surprise waiting.'**
  String get onboardingNotificationsBody;

  /// No description provided for @onboardingNotificationsPrimary.
  ///
  /// In en, this message translates to:
  /// **'Yes, tell me'**
  String get onboardingNotificationsPrimary;

  /// No description provided for @onboardingNotificationsSecondary.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get onboardingNotificationsSecondary;

  /// No description provided for @onboardingQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s build your basket'**
  String get onboardingQuizTitle;

  /// No description provided for @onboardingQuizSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you love, and we\'ll make sure you see it first.'**
  String get onboardingQuizSubtitle;

  /// No description provided for @onboardingQuizWantsLabel.
  ///
  /// In en, this message translates to:
  /// **'What do you usually want?'**
  String get onboardingQuizWantsLabel;

  /// No description provided for @onboardingQuizWantOption1.
  ///
  /// In en, this message translates to:
  /// **'Cooked meals from restaurants'**
  String get onboardingQuizWantOption1;

  /// No description provided for @onboardingQuizWantOption2.
  ///
  /// In en, this message translates to:
  /// **'Fresh fruits and vegetables'**
  String get onboardingQuizWantOption2;

  /// No description provided for @onboardingQuizWantOption3.
  ///
  /// In en, this message translates to:
  /// **'Meat, chicken, and fish'**
  String get onboardingQuizWantOption3;

  /// No description provided for @onboardingQuizWantOption4.
  ///
  /// In en, this message translates to:
  /// **'Pots, pans, and pantry stuff'**
  String get onboardingQuizWantOption4;

  /// No description provided for @onboardingQuizSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'How fast do you need things?'**
  String get onboardingQuizSpeedLabel;

  /// No description provided for @onboardingQuizSpeedOption1.
  ///
  /// In en, this message translates to:
  /// **'Right now, I\'m hungry'**
  String get onboardingQuizSpeedOption1;

  /// No description provided for @onboardingQuizSpeedOption2.
  ///
  /// In en, this message translates to:
  /// **'Today sometime'**
  String get onboardingQuizSpeedOption2;

  /// No description provided for @onboardingQuizSpeedOption3.
  ///
  /// In en, this message translates to:
  /// **'I\'m planning ahead'**
  String get onboardingQuizSpeedOption3;

  /// No description provided for @onboardingQuizAvoidLabel.
  ///
  /// In en, this message translates to:
  /// **'Any foods we should avoid?'**
  String get onboardingQuizAvoidLabel;

  /// No description provided for @onboardingQuizAvoidPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. no shellfish, no beef'**
  String get onboardingQuizAvoidPlaceholder;

  /// No description provided for @onboardingQuizBuildButton.
  ///
  /// In en, this message translates to:
  /// **'Build my basket'**
  String get onboardingQuizBuildButton;

  /// No description provided for @onboardingQuizSkipLink.
  ///
  /// In en, this message translates to:
  /// **'I\'ll figure it out later'**
  String get onboardingQuizSkipLink;

  /// No description provided for @onboardingGiftTitle.
  ///
  /// In en, this message translates to:
  /// **'A little welcome gift'**
  String get onboardingGiftTitle;

  /// No description provided for @onboardingGiftBody.
  ///
  /// In en, this message translates to:
  /// **'Your first order comes with something extra. Just because you deserve it.'**
  String get onboardingGiftBody;

  /// No description provided for @onboardingGiftButton.
  ///
  /// In en, this message translates to:
  /// **'Let\'s see what\'s inside'**
  String get onboardingGiftButton;

  /// No description provided for @onboardingGiftFootnote.
  ///
  /// In en, this message translates to:
  /// **'Valid for first order only. Minimum order applies.'**
  String get onboardingGiftFootnote;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back. Pick up where you left off.'**
  String get loginSubtitle;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone or email'**
  String get loginPhoneLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSignupLink.
  ///
  /// In en, this message translates to:
  /// **'New to WAWUBasket?'**
  String get loginSignupLink;

  /// No description provided for @loginErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone/email and password.'**
  String get loginErrorEmpty;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your WhatsApp number?'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a code to make sure it\'s really you.'**
  String get signupSubtitle;

  /// No description provided for @signupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get signupNameLabel;

  /// No description provided for @signupPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number'**
  String get signupPhoneLabel;

  /// No description provided for @signupEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signupEmailLabel;

  /// No description provided for @signupPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signupPasswordLabel;

  /// No description provided for @signupPasswordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get signupPasswordPlaceholder;

  /// No description provided for @signupSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get signupSendCode;

  /// No description provided for @signupDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'No spam. No calls. Just your basket updates.'**
  String get signupDisclaimer;

  /// No description provided for @signupHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get signupHaveAccount;

  /// No description provided for @signupErrorName.
  ///
  /// In en, this message translates to:
  /// **'Fill in your name, number and email.'**
  String get signupErrorName;

  /// No description provided for @signupErrorPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get signupErrorPassword;

  /// No description provided for @signupErrorTerms.
  ///
  /// In en, this message translates to:
  /// **'Accept the Terms to continue.'**
  String get signupErrorTerms;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got a code!'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your WhatsApp. It\'s a short one.'**
  String get otpSubtitle;

  /// No description provided for @otpEditNumber.
  ///
  /// In en, this message translates to:
  /// **'Edit number'**
  String get otpEditNumber;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResend;

  /// No description provided for @otpVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify and go in'**
  String get otpVerifyButton;

  /// No description provided for @otpNewCode.
  ///
  /// In en, this message translates to:
  /// **'A new code is on its way.'**
  String get otpNewCode;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us where to send a verification code and we\'ll help you back in.'**
  String get forgotSubtitle;

  /// No description provided for @forgotSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get forgotSendCode;

  /// No description provided for @forgotErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number or email.'**
  String get forgotErrorEmpty;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make it different from your last one.'**
  String get resetSubtitle;

  /// No description provided for @resetPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get resetPasswordLabel;

  /// No description provided for @resetConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get resetConfirmLabel;

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get resetButton;

  /// No description provided for @resetErrorLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get resetErrorLength;

  /// No description provided for @resetErrorMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match.'**
  String get resetErrorMismatch;

  /// No description provided for @welcomeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get welcomeGetStarted;

  /// No description provided for @welcomeSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get welcomeSignIn;

  /// No description provided for @roleSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you use WAWUBasket?'**
  String get roleSelectTitle;

  /// No description provided for @roleSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick what you\'ll do most. You can switch roles anytime from your profile.'**
  String get roleSelectSubtitle;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your basket'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your basket is empty'**
  String get cartEmpty;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Want to fill it? We have ideas.'**
  String get cartEmptySubtitle;

  /// No description provided for @cartStartShopping.
  ///
  /// In en, this message translates to:
  /// **'Start shopping'**
  String get cartStartShopping;

  /// No description provided for @cartEta.
  ///
  /// In en, this message translates to:
  /// **'Arrives in 25–35 min'**
  String get cartEta;

  /// No description provided for @cartPromo.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get cartPromo;

  /// No description provided for @cartPromoApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get cartPromoApply;

  /// No description provided for @cartSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartSubtotal;

  /// No description provided for @cartDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get cartDeliveryFee;

  /// No description provided for @cartServiceFee.
  ///
  /// In en, this message translates to:
  /// **'Service fee'**
  String get cartServiceFee;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartTotal;

  /// No description provided for @cartCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to checkout'**
  String get cartCheckout;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutDeliverySection.
  ///
  /// In en, this message translates to:
  /// **'Where are we sending this?'**
  String get checkoutDeliverySection;

  /// No description provided for @checkoutNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No address saved — add one'**
  String get checkoutNoAddress;

  /// No description provided for @checkoutChangeAddress.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get checkoutChangeAddress;

  /// No description provided for @checkoutTimingSection.
  ///
  /// In en, this message translates to:
  /// **'When do you want it?'**
  String get checkoutTimingSection;

  /// No description provided for @checkoutNow.
  ///
  /// In en, this message translates to:
  /// **'Order now'**
  String get checkoutNow;

  /// No description provided for @checkoutNowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Arrives in 25–35 min'**
  String get checkoutNowSubtitle;

  /// No description provided for @checkoutSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get checkoutSchedule;

  /// No description provided for @checkoutPaymentSection.
  ///
  /// In en, this message translates to:
  /// **'How will you pay?'**
  String get checkoutPaymentSection;

  /// No description provided for @checkoutBasketSection.
  ///
  /// In en, this message translates to:
  /// **'Your basket'**
  String get checkoutBasketSection;

  /// No description provided for @checkoutPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get checkoutPlaceOrder;

  /// No description provided for @checkoutWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment…'**
  String get checkoutWaiting;

  /// No description provided for @checkoutWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'Complete payment in the browser. We\'ll move you to order tracking automatically.'**
  String get checkoutWaitingBody;

  /// No description provided for @checkoutTimeout.
  ///
  /// In en, this message translates to:
  /// **'Payment not confirmed'**
  String get checkoutTimeout;

  /// No description provided for @checkoutTimeoutBody.
  ///
  /// In en, this message translates to:
  /// **'We didn\'t receive a payment confirmation. Tap below to check again, or go back.'**
  String get checkoutTimeoutBody;

  /// No description provided for @checkoutCheckStatus.
  ///
  /// In en, this message translates to:
  /// **'Check payment status'**
  String get checkoutCheckStatus;

  /// No description provided for @checkoutGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get checkoutGoBack;

  /// No description provided for @checkoutScheduleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm time slot'**
  String get checkoutScheduleConfirm;

  /// No description provided for @confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Woohoo!'**
  String get confirmTitle;

  /// No description provided for @confirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your order is confirmed and the kitchen is on it.'**
  String get confirmSubtitle;

  /// No description provided for @confirmNotification.
  ///
  /// In en, this message translates to:
  /// **'We\'ll ping you when your basket moves.'**
  String get confirmNotification;

  /// No description provided for @confirmTracking.
  ///
  /// In en, this message translates to:
  /// **'Watch it travel to your door in real time.'**
  String get confirmTracking;

  /// No description provided for @confirmTrackButton.
  ///
  /// In en, this message translates to:
  /// **'Track my order'**
  String get confirmTrackButton;

  /// No description provided for @confirmBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get confirmBackHome;

  /// No description provided for @trackingNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get trackingNeedHelp;

  /// No description provided for @trackingDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered. Enjoy your basket!'**
  String get trackingDelivered;

  /// No description provided for @trackingDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ll update you as your order moves.'**
  String get trackingDefaultMessage;

  /// No description provided for @trackingJourney.
  ///
  /// In en, this message translates to:
  /// **'Your order is on a journey'**
  String get trackingJourney;

  /// No description provided for @trackingStep1.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed'**
  String get trackingStep1;

  /// No description provided for @trackingStep2.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get trackingStep2;

  /// No description provided for @trackingStep3.
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get trackingStep3;

  /// No description provided for @trackingStep4.
  ///
  /// In en, this message translates to:
  /// **'En route'**
  String get trackingStep4;

  /// No description provided for @trackingStep5.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get trackingStep5;

  /// No description provided for @trackingRate.
  ///
  /// In en, this message translates to:
  /// **'Rate your order'**
  String get trackingRate;

  /// No description provided for @deliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivered. Enjoy your basket!'**
  String get deliveryTitle;

  /// No description provided for @deliverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How was your experience? Your feedback helps vendors and riders do better.'**
  String get deliverySubtitle;

  /// No description provided for @deliveryRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate this order'**
  String get deliveryRateTitle;

  /// No description provided for @deliveryRatingBad.
  ///
  /// In en, this message translates to:
  /// **'Not great'**
  String get deliveryRatingBad;

  /// No description provided for @deliveryRatingFair.
  ///
  /// In en, this message translates to:
  /// **'Could be better'**
  String get deliveryRatingFair;

  /// No description provided for @deliveryRatingOkay.
  ///
  /// In en, this message translates to:
  /// **'It was okay'**
  String get deliveryRatingOkay;

  /// No description provided for @deliveryRatingGood.
  ///
  /// In en, this message translates to:
  /// **'Pretty good!'**
  String get deliveryRatingGood;

  /// No description provided for @deliveryRatingLove.
  ///
  /// In en, this message translates to:
  /// **'Loved it!'**
  String get deliveryRatingLove;

  /// No description provided for @deliveryFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us more (optional)'**
  String get deliveryFeedbackTitle;

  /// No description provided for @deliveryFeedbackPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'What made it great or not so great?'**
  String get deliveryFeedbackPlaceholder;

  /// No description provided for @deliverySubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit rating'**
  String get deliverySubmit;

  /// No description provided for @deliverySkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get deliverySkip;

  /// No description provided for @deliveryThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thanks for the feedback!'**
  String get deliveryThankYou;

  /// No description provided for @deliveryThankYouBody.
  ///
  /// In en, this message translates to:
  /// **'Your rating helps the whole basket get better. See you next time.'**
  String get deliveryThankYouBody;

  /// No description provided for @deliveryBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get deliveryBackHome;

  /// No description provided for @deliveryRateError.
  ///
  /// In en, this message translates to:
  /// **'Tap a star to rate your order.'**
  String get deliveryRateError;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search jollof, tomatoes, chicken…'**
  String get searchPlaceholder;

  /// No description provided for @searchRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecentTitle;

  /// No description provided for @searchRecentClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchRecentClear;

  /// No description provided for @searchRecentCleared.
  ///
  /// In en, this message translates to:
  /// **'Recent searches cleared'**
  String get searchRecentCleared;

  /// No description provided for @productAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add to basket'**
  String get productAddButton;

  /// No description provided for @productAddedToBasket.
  ///
  /// In en, this message translates to:
  /// **'Added to basket'**
  String get productAddedToBasket;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found.'**
  String get productNotFound;

  /// No description provided for @homeSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for jollof, tomatoes, chicken, pots…'**
  String get homeSearchPlaceholder;

  /// No description provided for @homeBulkMarketsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk markets'**
  String get homeBulkMarketsTitle;

  /// No description provided for @homeBulkMarketsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wholesale lots & corridor prices, direct from farms'**
  String get homeBulkMarketsSubtitle;

  /// No description provided for @homeOffersThisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get homeOffersThisWeek;

  /// No description provided for @homeOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Free delivery on orders over ₦5,000'**
  String get homeOfferTitle;

  /// No description provided for @homeOfferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Until Sunday. No code needed.'**
  String get homeOfferSubtitle;

  /// No description provided for @homeOfferButton.
  ///
  /// In en, this message translates to:
  /// **'Order now'**
  String get homeOfferButton;

  /// No description provided for @homeAddAddress.
  ///
  /// In en, this message translates to:
  /// **'Add a delivery address'**
  String get homeAddAddress;

  /// No description provided for @homeDeliveringTo.
  ///
  /// In en, this message translates to:
  /// **'Delivering to {address}'**
  String homeDeliveringTo(String address);

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About WAWUBasket'**
  String get aboutTitle;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'We\'re WAWUBasket — offspring of WAWAfrica.'**
  String get aboutTagline;

  /// No description provided for @aboutSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get aboutSendFeedback;

  /// No description provided for @aboutSendFeedbackSub.
  ///
  /// In en, this message translates to:
  /// **'Help us improve'**
  String get aboutSendFeedbackSub;

  /// No description provided for @aboutTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get aboutTerms;

  /// No description provided for @aboutTermsSub.
  ///
  /// In en, this message translates to:
  /// **'The rules of the basket'**
  String get aboutTermsSub;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get aboutPrivacy;

  /// No description provided for @aboutPrivacySub.
  ///
  /// In en, this message translates to:
  /// **'How we handle your info'**
  String get aboutPrivacySub;

  /// No description provided for @aboutHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'Three steps to a full basket'**
  String get aboutHowItWorks;

  /// No description provided for @aboutSellOn.
  ///
  /// In en, this message translates to:
  /// **'Sell on WAWUBasket'**
  String get aboutSellOn;

  /// No description provided for @aboutStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get aboutStep1Title;

  /// No description provided for @aboutStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Pick what you want from restaurants, produce, livestock, or essentials.'**
  String get aboutStep1Body;

  /// No description provided for @aboutStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get aboutStep2Title;

  /// No description provided for @aboutStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Choose when you want it and how you\'ll pay.'**
  String get aboutStep2Body;

  /// No description provided for @aboutStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get aboutStep3Title;

  /// No description provided for @aboutStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Watch your basket come to life, then enjoy.'**
  String get aboutStep3Body;

  /// No description provided for @aboutVendorStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get aboutVendorStep1Title;

  /// No description provided for @aboutVendorStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your business. Let\'s have some documents sorted.'**
  String get aboutVendorStep1Body;

  /// No description provided for @aboutVendorStep2Title.
  ///
  /// In en, this message translates to:
  /// **'List your products'**
  String get aboutVendorStep2Title;

  /// No description provided for @aboutVendorStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Add photos, prices, and descriptions.'**
  String get aboutVendorStep2Body;

  /// No description provided for @aboutVendorStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Start selling'**
  String get aboutVendorStep3Title;

  /// No description provided for @aboutVendorStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Get orders, prepare food, and grow.'**
  String get aboutVendorStep3Body;

  /// No description provided for @addAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get addAddressTitle;

  /// No description provided for @addAddressEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get addAddressEditTitle;

  /// No description provided for @addAddressLabelSection.
  ///
  /// In en, this message translates to:
  /// **'LABEL'**
  String get addAddressLabelSection;

  /// No description provided for @addAddressLabelHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get addAddressLabelHome;

  /// No description provided for @addAddressLabelOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get addAddressLabelOffice;

  /// No description provided for @addAddressLabelOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get addAddressLabelOther;

  /// No description provided for @addAddressLine.
  ///
  /// In en, this message translates to:
  /// **'Address line'**
  String get addAddressLine;

  /// No description provided for @addAddressLinePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Street, area, city'**
  String get addAddressLinePlaceholder;

  /// No description provided for @addAddressApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment / unit'**
  String get addAddressApartment;

  /// No description provided for @addAddressApartmentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get addAddressApartmentPlaceholder;

  /// No description provided for @addAddressNote.
  ///
  /// In en, this message translates to:
  /// **'Note for the rider'**
  String get addAddressNote;

  /// No description provided for @addAddressNotePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Use the gate on Akin Adesola'**
  String get addAddressNotePlaceholder;

  /// No description provided for @addAddressDefault.
  ///
  /// In en, this message translates to:
  /// **'Make this my default address'**
  String get addAddressDefault;

  /// No description provided for @addAddressSave.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get addAddressSave;

  /// No description provided for @addAddressSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get addAddressSaveChanges;

  /// No description provided for @addAddressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Address updated'**
  String get addAddressUpdated;

  /// No description provided for @addAddressSaved.
  ///
  /// In en, this message translates to:
  /// **'Address saved'**
  String get addAddressSaved;

  /// No description provided for @addAddressEnterLine.
  ///
  /// In en, this message translates to:
  /// **'Enter the address line.'**
  String get addAddressEnterLine;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatTitle;

  /// No description provided for @chatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Talk to support and anyone on your active orders.'**
  String get chatSubtitle;

  /// No description provided for @chatMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatMessageHint;

  /// No description provided for @chatLiveChat.
  ///
  /// In en, this message translates to:
  /// **'Live chat'**
  String get chatLiveChat;

  /// No description provided for @chatRepliesIn.
  ///
  /// In en, this message translates to:
  /// **'Replies usually in under 2 min'**
  String get chatRepliesIn;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaving us?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re sad to see you go. Before you leave:'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountCheck1.
  ///
  /// In en, this message translates to:
  /// **'Use your wallet balance, it will be lost'**
  String get deleteAccountCheck1;

  /// No description provided for @deleteAccountCheck2.
  ///
  /// In en, this message translates to:
  /// **'Complete any active orders'**
  String get deleteAccountCheck2;

  /// No description provided for @deleteAccountCheck3.
  ///
  /// In en, this message translates to:
  /// **'Download your receipts, you won\'t access them after'**
  String get deleteAccountCheck3;

  /// No description provided for @deleteAccountWhyLeaving.
  ///
  /// In en, this message translates to:
  /// **'Why are you leaving? (optional)'**
  String get deleteAccountWhyLeaving;

  /// No description provided for @deleteAccountReasonExpensive.
  ///
  /// In en, this message translates to:
  /// **'Too expensive'**
  String get deleteAccountReasonExpensive;

  /// No description provided for @deleteAccountReasonSlow.
  ///
  /// In en, this message translates to:
  /// **'Delivery too slow'**
  String get deleteAccountReasonSlow;

  /// No description provided for @deleteAccountReasonOptions.
  ///
  /// In en, this message translates to:
  /// **'Not enough options'**
  String get deleteAccountReasonOptions;

  /// No description provided for @deleteAccountReasonTech.
  ///
  /// In en, this message translates to:
  /// **'Technical issues'**
  String get deleteAccountReasonTech;

  /// No description provided for @deleteAccountReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get deleteAccountReasonOther;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account permanently?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteAccountConfirmBody;

  /// No description provided for @deleteAccountYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, delete my account'**
  String get deleteAccountYes;

  /// No description provided for @deleteAccountNo.
  ///
  /// In en, this message translates to:
  /// **'No, I want to stay'**
  String get deleteAccountNo;

  /// No description provided for @dietaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Dietary preferences'**
  String get dietaryTitle;

  /// No description provided for @dietarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Things you\'d rather not eat.'**
  String get dietarySubtitle;

  /// No description provided for @dietaryNoBeef.
  ///
  /// In en, this message translates to:
  /// **'No beef'**
  String get dietaryNoBeef;

  /// No description provided for @dietaryNoPork.
  ///
  /// In en, this message translates to:
  /// **'No pork'**
  String get dietaryNoPork;

  /// No description provided for @dietaryNoShellfish.
  ///
  /// In en, this message translates to:
  /// **'No shellfish'**
  String get dietaryNoShellfish;

  /// No description provided for @dietaryHalal.
  ///
  /// In en, this message translates to:
  /// **'Halal only'**
  String get dietaryHalal;

  /// No description provided for @dietaryVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get dietaryVegetarian;

  /// No description provided for @dietaryVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get dietaryVegan;

  /// No description provided for @dietaryNoDairy.
  ///
  /// In en, this message translates to:
  /// **'No dairy'**
  String get dietaryNoDairy;

  /// No description provided for @dietaryNoNuts.
  ///
  /// In en, this message translates to:
  /// **'No nuts'**
  String get dietaryNoNuts;

  /// No description provided for @dietaryLowSugar.
  ///
  /// In en, this message translates to:
  /// **'Low sugar'**
  String get dietaryLowSugar;

  /// No description provided for @dietaryAnythingElse.
  ///
  /// In en, this message translates to:
  /// **'Anything else?'**
  String get dietaryAnythingElse;

  /// No description provided for @dietaryCustomPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. no MSG, no palm oil'**
  String get dietaryCustomPlaceholder;

  /// No description provided for @dietarySave.
  ///
  /// In en, this message translates to:
  /// **'Save preferences'**
  String get dietarySave;

  /// No description provided for @dietarySaved.
  ///
  /// In en, this message translates to:
  /// **'Dietary preferences saved'**
  String get dietarySaved;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesVendorsTab.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get favoritesVendorsTab;

  /// No description provided for @favoritesDishesTab.
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get favoritesDishesTab;

  /// No description provided for @favoritesNoVendors.
  ///
  /// In en, this message translates to:
  /// **'No favorite vendors yet. Tap the heart on a storefront.'**
  String get favoritesNoVendors;

  /// No description provided for @favoritesNoDishes.
  ///
  /// In en, this message translates to:
  /// **'No favorite dishes yet. Tap the heart on a dish.'**
  String get favoritesNoDishes;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsAllRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked read'**
  String get notificationsAllRead;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up — no notifications yet.'**
  String get notificationsEmpty;

  /// No description provided for @orderHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your past baskets'**
  String get orderHistoryTitle;

  /// No description provided for @orderHistoryTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get orderHistoryTabAll;

  /// No description provided for @orderHistoryTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get orderHistoryTabActive;

  /// No description provided for @orderHistoryTabPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get orderHistoryTabPast;

  /// No description provided for @orderHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet. Time to change that.'**
  String get orderHistoryEmpty;

  /// No description provided for @orderHistoryTrack.
  ///
  /// In en, this message translates to:
  /// **'Track order'**
  String get orderHistoryTrack;

  /// No description provided for @orderHistoryReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get orderHistoryReceipt;

  /// No description provided for @orderHistoryReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get orderHistoryReorder;

  /// No description provided for @orderHistoryReordered.
  ///
  /// In en, this message translates to:
  /// **'Items added to your basket'**
  String get orderHistoryReordered;

  /// No description provided for @personalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfoTitle;

  /// No description provided for @personalInfoTapPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get personalInfoTapPhoto;

  /// No description provided for @personalInfoFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get personalInfoFullName;

  /// No description provided for @personalInfoEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get personalInfoEmail;

  /// No description provided for @personalInfoPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get personalInfoPhone;

  /// No description provided for @personalInfoDob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get personalInfoDob;

  /// No description provided for @personalInfoSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get personalInfoSave;

  /// No description provided for @personalInfoSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get personalInfoSaved;

  /// No description provided for @personalInfoNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name.'**
  String get personalInfoNameRequired;

  /// No description provided for @personalInfoPhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Photo updated'**
  String get personalInfoPhotoUpdated;

  /// No description provided for @personalInfoPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t upload that photo.'**
  String get personalInfoPhotoFailed;

  /// No description provided for @profileWalletMenu.
  ///
  /// In en, this message translates to:
  /// **'Wallet & payment methods'**
  String get profileWalletMenu;

  /// No description provided for @profileWalletSub.
  ///
  /// In en, this message translates to:
  /// **'Cards, bank, and mobile money'**
  String get profileWalletSub;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get profilePersonalInfo;

  /// No description provided for @profilePersonalInfoSub.
  ///
  /// In en, this message translates to:
  /// **'Name, email, phone, verified ✓'**
  String get profilePersonalInfoSub;

  /// No description provided for @profileSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved addresses'**
  String get profileSavedAddresses;

  /// No description provided for @profileSavedAddressesSub.
  ///
  /// In en, this message translates to:
  /// **'Where you live, work, and hang out'**
  String get profileSavedAddressesSub;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileNotificationsSub.
  ///
  /// In en, this message translates to:
  /// **'What we tell you about'**
  String get profileNotificationsSub;

  /// No description provided for @profileBulkOrders.
  ///
  /// In en, this message translates to:
  /// **'Bulk orders'**
  String get profileBulkOrders;

  /// No description provided for @profileBulkOrdersSub.
  ///
  /// In en, this message translates to:
  /// **'Escrow-protected purchases from /trade'**
  String get profileBulkOrdersSub;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileDietary.
  ///
  /// In en, this message translates to:
  /// **'Dietary preferences'**
  String get profileDietary;

  /// No description provided for @profileDietarySub.
  ///
  /// In en, this message translates to:
  /// **'Things you\'d rather not eat'**
  String get profileDietarySub;

  /// No description provided for @profileRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get profileRateApp;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About WAWUBasket'**
  String get profileAbout;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

  /// No description provided for @profileChangePasswordSub.
  ///
  /// In en, this message translates to:
  /// **'Keep your account safe'**
  String get profileChangePasswordSub;

  /// No description provided for @profileTwoFactor.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication'**
  String get profileTwoFactor;

  /// No description provided for @profileTwoFactorSub.
  ///
  /// In en, this message translates to:
  /// **'Extra layer of protection'**
  String get profileTwoFactorSub;

  /// No description provided for @profileHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get profileHelpCenter;

  /// No description provided for @profileHelpCenterSub.
  ///
  /// In en, this message translates to:
  /// **'Answers to common questions'**
  String get profileHelpCenterSub;

  /// No description provided for @profileChatWithUs.
  ///
  /// In en, this message translates to:
  /// **'Chat with us'**
  String get profileChatWithUs;

  /// No description provided for @profileChatWithUsSub.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help'**
  String get profileChatWithUsSub;

  /// No description provided for @profileReportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get profileReportProblem;

  /// No description provided for @profileReportProblemSub.
  ///
  /// In en, this message translates to:
  /// **'Tell us what went wrong'**
  String get profileReportProblemSub;

  /// No description provided for @profileTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get profileTerms;

  /// No description provided for @profileTermsSub.
  ///
  /// In en, this message translates to:
  /// **'The rules of the basket'**
  String get profileTermsSub;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get profilePrivacy;

  /// No description provided for @profilePrivacySub.
  ///
  /// In en, this message translates to:
  /// **'How we handle your info'**
  String get profilePrivacySub;

  /// No description provided for @profileSwitchRole.
  ///
  /// In en, this message translates to:
  /// **'Switch role'**
  String get profileSwitchRole;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountSub.
  ///
  /// In en, this message translates to:
  /// **'We\'ll be sad to see you go'**
  String get profileDeleteAccountSub;

  /// No description provided for @profileRateWawu.
  ///
  /// In en, this message translates to:
  /// **'Rate WAWUBasket'**
  String get profileRateWawu;

  /// No description provided for @profileRateFeedback.
  ///
  /// In en, this message translates to:
  /// **'How are we doing? Your feedback shapes the app.'**
  String get profileRateFeedback;

  /// No description provided for @profileRateTapStar.
  ///
  /// In en, this message translates to:
  /// **'Tap a star to rate'**
  String get profileRateTapStar;

  /// No description provided for @profileRateSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get profileRateSubmit;

  /// No description provided for @profileRateThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks, you rated us {stars} stars'**
  String profileRateThanks(String stars);

  /// No description provided for @profileSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to place new orders.'**
  String get profileSignOutBody;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose a profile photo'**
  String get profileChoosePhoto;

  /// No description provided for @receiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receiptTitle;

  /// No description provided for @receiptSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get receiptSubtotal;

  /// No description provided for @receiptDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get receiptDelivery;

  /// No description provided for @receiptServiceFee.
  ///
  /// In en, this message translates to:
  /// **'Service fee'**
  String get receiptServiceFee;

  /// No description provided for @receiptTotalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get receiptTotalPaid;

  /// No description provided for @receiptReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get receiptReorder;

  /// No description provided for @receiptReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get receiptReportIssue;

  /// No description provided for @receiptNotFound.
  ///
  /// In en, this message translates to:
  /// **'Receipt not found.'**
  String get receiptNotFound;

  /// No description provided for @savedAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved addresses'**
  String get savedAddressesTitle;

  /// No description provided for @savedAddressesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get savedAddressesAdd;

  /// No description provided for @savedAddressesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses yet. Add your first above.'**
  String get savedAddressesEmpty;

  /// No description provided for @savedAddressesDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get savedAddressesDefault;

  /// No description provided for @savedAddressesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get savedAddressesEdit;

  /// No description provided for @savedAddressesMakeDefault.
  ///
  /// In en, this message translates to:
  /// **'Make default'**
  String get savedAddressesMakeDefault;

  /// No description provided for @savedAddressesSetDefault.
  ///
  /// In en, this message translates to:
  /// **'{label} set as default'**
  String savedAddressesSetDefault(String label);

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityTitle;

  /// No description provided for @securitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your account safe.'**
  String get securitySubtitle;

  /// No description provided for @securityChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get securityChangePassword;

  /// No description provided for @securityChangePasswordSub.
  ///
  /// In en, this message translates to:
  /// **'Keep your account safe'**
  String get securityChangePasswordSub;

  /// No description provided for @securityTwoFactor.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication'**
  String get securityTwoFactor;

  /// No description provided for @securityTwoFactorSub.
  ///
  /// In en, this message translates to:
  /// **'Extra layer of protection'**
  String get securityTwoFactorSub;

  /// No description provided for @securityCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get securityCurrentPassword;

  /// No description provided for @securityNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get securityNewPassword;

  /// No description provided for @securityConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get securityConfirmNewPassword;

  /// No description provided for @securityUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get securityUpdatePassword;

  /// No description provided for @securityPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get securityPasswordMismatch;

  /// No description provided for @securityPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 8 characters.'**
  String get securityPasswordShort;

  /// No description provided for @securityPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get securityPasswordUpdated;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get supportTitle;

  /// No description provided for @supportSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search help articles'**
  String get supportSearchPlaceholder;

  /// No description provided for @supportContactUs.
  ///
  /// In en, this message translates to:
  /// **'CONTACT US'**
  String get supportContactUs;

  /// No description provided for @supportLiveChat.
  ///
  /// In en, this message translates to:
  /// **'Live chat'**
  String get supportLiveChat;

  /// No description provided for @supportLiveChatSub.
  ///
  /// In en, this message translates to:
  /// **'Usually replies in under 2 min'**
  String get supportLiveChatSub;

  /// No description provided for @supportLiveChatCta.
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get supportLiveChatCta;

  /// No description provided for @supportCall.
  ///
  /// In en, this message translates to:
  /// **'Call us'**
  String get supportCall;

  /// No description provided for @supportCallSub.
  ///
  /// In en, this message translates to:
  /// **'07050622222'**
  String get supportCallSub;

  /// No description provided for @supportCallCta.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get supportCallCta;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'Email us'**
  String get supportEmail;

  /// No description provided for @supportEmailSub.
  ///
  /// In en, this message translates to:
  /// **'basket@wawuafrica.com'**
  String get supportEmailSub;

  /// No description provided for @supportEmailCta.
  ///
  /// In en, this message translates to:
  /// **'Send email'**
  String get supportEmailCta;

  /// No description provided for @supportCommonQuestions.
  ///
  /// In en, this message translates to:
  /// **'Common questions'**
  String get supportCommonQuestions;

  /// No description provided for @supportOpenTicket.
  ///
  /// In en, this message translates to:
  /// **'OPEN TICKET'**
  String get supportOpenTicket;

  /// No description provided for @supportViewTicket.
  ///
  /// In en, this message translates to:
  /// **'View ticket'**
  String get supportViewTicket;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @walletAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE BALANCE'**
  String get walletAvailableBalance;

  /// No description provided for @walletEscrowHeld.
  ///
  /// In en, this message translates to:
  /// **'{amount} held in escrow, releases on delivery'**
  String walletEscrowHeld(String amount);

  /// No description provided for @walletTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get walletTopUp;

  /// No description provided for @walletSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get walletSend;

  /// No description provided for @walletWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get walletWithdraw;

  /// No description provided for @walletCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get walletCards;

  /// No description provided for @walletRecentTxns.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get walletRecentTxns;

  /// No description provided for @walletNoTxns.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.'**
  String get walletNoTxns;

  /// No description provided for @walletTopUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Top up wallet'**
  String get walletTopUpTitle;

  /// No description provided for @walletSendTitle.
  ///
  /// In en, this message translates to:
  /// **'Send money'**
  String get walletSendTitle;

  /// No description provided for @walletWithdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get walletWithdrawTitle;

  /// No description provided for @walletPaymentMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get walletPaymentMethodsTitle;

  /// No description provided for @walletAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get walletAmountLabel;

  /// No description provided for @walletEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get walletEnterAmount;

  /// No description provided for @walletPayWith.
  ///
  /// In en, this message translates to:
  /// **'PAY WITH'**
  String get walletPayWith;

  /// No description provided for @walletWithdrawTo.
  ///
  /// In en, this message translates to:
  /// **'WITHDRAW TO'**
  String get walletWithdrawTo;

  /// No description provided for @walletDebitCard.
  ///
  /// In en, this message translates to:
  /// **'Debit card'**
  String get walletDebitCard;

  /// No description provided for @walletBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get walletBankTransfer;

  /// No description provided for @walletMobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile money'**
  String get walletMobileMoney;

  /// No description provided for @walletEnterAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get walletEnterAmountHint;

  /// No description provided for @walletTopUpHint.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get walletTopUpHint;

  /// No description provided for @walletAddNewMethod.
  ///
  /// In en, this message translates to:
  /// **'Add new method'**
  String get walletAddNewMethod;

  /// No description provided for @walletMethodRemoved.
  ///
  /// In en, this message translates to:
  /// **'Method removed'**
  String get walletMethodRemoved;

  /// No description provided for @operatorSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get operatorSignOutTitle;

  /// No description provided for @operatorSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to use this dashboard.'**
  String get operatorSignOutBody;

  /// No description provided for @operatorSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get operatorSignOut;

  /// No description provided for @operatorPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get operatorPersonalInfo;

  /// No description provided for @operatorPersonalInfoSub.
  ///
  /// In en, this message translates to:
  /// **'Name, email, phone, verified ✓'**
  String get operatorPersonalInfoSub;

  /// No description provided for @operatorSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Saved addresses'**
  String get operatorSavedAddresses;

  /// No description provided for @operatorSavedAddressesSub.
  ///
  /// In en, this message translates to:
  /// **'Where deliveries pick up and drop off'**
  String get operatorSavedAddressesSub;

  /// No description provided for @operatorNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get operatorNotifications;

  /// No description provided for @operatorNotificationsSub.
  ///
  /// In en, this message translates to:
  /// **'New orders, payouts, alerts'**
  String get operatorNotificationsSub;

  /// No description provided for @operatorLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get operatorLanguage;

  /// No description provided for @operatorAbout.
  ///
  /// In en, this message translates to:
  /// **'About WAWUBasket'**
  String get operatorAbout;

  /// No description provided for @operatorHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get operatorHelpSupport;

  /// No description provided for @operatorHelpSupportSub.
  ///
  /// In en, this message translates to:
  /// **'Chat to a real human'**
  String get operatorHelpSupportSub;

  /// No description provided for @operatorSwitchRole.
  ///
  /// In en, this message translates to:
  /// **'Switch role'**
  String get operatorSwitchRole;

  /// No description provided for @operatorChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose a profile photo'**
  String get operatorChoosePhoto;

  /// No description provided for @vendorAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get vendorAlertsTitle;

  /// No description provided for @vendorAlertsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No alerts right now. Enjoy the breather.'**
  String get vendorAlertsEmpty;

  /// No description provided for @vendorAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'How you\'re doing'**
  String get vendorAnalyticsTitle;

  /// No description provided for @vendorAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The numbers don\'t lie.'**
  String get vendorAnalyticsSubtitle;

  /// No description provided for @vendorAnalyticsOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get vendorAnalyticsOrders;

  /// No description provided for @vendorAnalyticsRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get vendorAnalyticsRevenue;

  /// No description provided for @vendorAnalyticsAvgOrder.
  ///
  /// In en, this message translates to:
  /// **'Avg order'**
  String get vendorAnalyticsAvgOrder;

  /// No description provided for @vendorAnalyticsRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get vendorAnalyticsRating;

  /// No description provided for @vendorAnalyticsSalesTrend.
  ///
  /// In en, this message translates to:
  /// **'Sales trend'**
  String get vendorAnalyticsSalesTrend;

  /// No description provided for @vendorAnalyticsPeakHours.
  ///
  /// In en, this message translates to:
  /// **'Peak hours'**
  String get vendorAnalyticsPeakHours;

  /// No description provided for @vendorAnalyticsCancellations.
  ///
  /// In en, this message translates to:
  /// **'Cancellations'**
  String get vendorAnalyticsCancellations;

  /// No description provided for @vendorAnalyticsTopSellers.
  ///
  /// In en, this message translates to:
  /// **'Top sellers'**
  String get vendorAnalyticsTopSellers;

  /// No description provided for @vendorAnalyticsExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get vendorAnalyticsExport;

  /// No description provided for @vendorAnalyticsNoSales.
  ///
  /// In en, this message translates to:
  /// **'No sales in this range yet.'**
  String get vendorAnalyticsNoSales;

  /// No description provided for @vendorAnalyticsLast7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get vendorAnalyticsLast7;

  /// No description provided for @vendorAnalyticsLast30.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get vendorAnalyticsLast30;

  /// No description provided for @vendorAnalyticsLast90.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get vendorAnalyticsLast90;

  /// No description provided for @vendorHomeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get vendorHomeGoodMorning;

  /// No description provided for @vendorHomeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get vendorHomeOpen;

  /// No description provided for @vendorHomeClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get vendorHomeClosed;

  /// No description provided for @vendorHomeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get vendorHomeQuickActions;

  /// No description provided for @vendorHomeAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get vendorHomeAddItem;

  /// No description provided for @vendorHomeAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get vendorHomeAnalytics;

  /// No description provided for @vendorHomePayouts.
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get vendorHomePayouts;

  /// No description provided for @vendorHomeFreshOrders.
  ///
  /// In en, this message translates to:
  /// **'Fresh orders'**
  String get vendorHomeFreshOrders;

  /// No description provided for @vendorHomeInKitchen.
  ///
  /// In en, this message translates to:
  /// **'In the kitchen'**
  String get vendorHomeInKitchen;

  /// No description provided for @vendorHomeMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get vendorHomeMore;

  /// No description provided for @vendorHomeInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get vendorHomeInventory;

  /// No description provided for @vendorHomeInventorySub.
  ///
  /// In en, this message translates to:
  /// **'Stock levels & batches'**
  String get vendorHomeInventorySub;

  /// No description provided for @vendorHomeReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get vendorHomeReviews;

  /// No description provided for @vendorHomeReviewsSub.
  ///
  /// In en, this message translates to:
  /// **'What customers say'**
  String get vendorHomeReviewsSub;

  /// No description provided for @vendorHomeAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get vendorHomeAlerts;

  /// No description provided for @vendorHomeAlertsSub.
  ///
  /// In en, this message translates to:
  /// **'Low stock, late orders, replies waiting'**
  String get vendorHomeAlertsSub;

  /// No description provided for @vendorHomeSettings.
  ///
  /// In en, this message translates to:
  /// **'Store settings'**
  String get vendorHomeSettings;

  /// No description provided for @vendorHomeSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Hours, prep time, holiday mode, staff'**
  String get vendorHomeSettingsSub;

  /// No description provided for @vendorHomeDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get vendorHomeDecline;

  /// No description provided for @vendorHomeAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get vendorHomeAccept;

  /// No description provided for @vendorHomeNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No new orders. Drop a promo to bring them in.'**
  String get vendorHomeNoOrders;

  /// No description provided for @vendorInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s in stock?'**
  String get vendorInventoryTitle;

  /// No description provided for @vendorKycReviewNote.
  ///
  /// In en, this message translates to:
  /// **'We\'ll review your documents and get you live.'**
  String get vendorKycReviewNote;

  /// No description provided for @vendorOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find that order'**
  String get vendorOrderNotFound;

  /// No description provided for @vendorReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'What they\'re saying'**
  String get vendorReviewsTitle;

  /// No description provided for @vendorMenuPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t upload that photo.'**
  String get vendorMenuPhotoFailed;

  /// No description provided for @agentHomeOnline.
  ///
  /// In en, this message translates to:
  /// **'You\'re online, transactions sync as you record them.'**
  String get agentHomeOnline;

  /// No description provided for @agentRegisterSetUp.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get them set up.'**
  String get agentRegisterSetUp;

  /// No description provided for @agentRegisterOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline-capable, we\'ll sync when you have connection.'**
  String get agentRegisterOffline;

  /// No description provided for @agentTraderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Trader not found'**
  String get agentTraderNotFound;

  /// No description provided for @agentTradersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No traders registered yet. Tap \"Register\" to add one.'**
  String get agentTradersEmpty;

  /// No description provided for @riderHomeOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get riderHomeOffline;

  /// No description provided for @riderKycPhotoId.
  ///
  /// In en, this message translates to:
  /// **'Photo of ID'**
  String get riderKycPhotoId;

  /// No description provided for @driverKycVerifyNote.
  ///
  /// In en, this message translates to:
  /// **'We verify with your transport union before you bid.'**
  String get driverKycVerifyNote;

  /// No description provided for @driverKycLicenceName.
  ///
  /// In en, this message translates to:
  /// **'Drivers\' licence name, please.'**
  String get driverKycLicenceName;

  /// No description provided for @driverKycVehicleType.
  ///
  /// In en, this message translates to:
  /// **'What you\'ll move loads with.'**
  String get driverKycVehicleType;

  /// No description provided for @traderListingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No listings yet. Tap \"Post\" to add your first.'**
  String get traderListingsEmpty;

  /// No description provided for @traderListingPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t upload that photo.'**
  String get traderListingPhotoFailed;

  /// No description provided for @exportListingNotFound.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find that listing'**
  String get exportListingNotFound;

  /// No description provided for @exportEnquirySent.
  ///
  /// In en, this message translates to:
  /// **'Enquiry sent, the trader will reach out.'**
  String get exportEnquirySent;

  /// No description provided for @bulkCheckoutListingNotFound.
  ///
  /// In en, this message translates to:
  /// **'Listing not found'**
  String get bulkCheckoutListingNotFound;

  /// No description provided for @bulkCheckoutEscrowNote.
  ///
  /// In en, this message translates to:
  /// **'We hold your funds until you confirm delivery. Dispute anytime if something\'s off.'**
  String get bulkCheckoutEscrowNote;

  /// No description provided for @escrowDisputeOpened.
  ///
  /// In en, this message translates to:
  /// **'Dispute opened. We\'ll review within 48 hours.'**
  String get escrowDisputeOpened;

  /// No description provided for @escrowDisputeOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get escrowDisputeOrderNotFound;

  /// No description provided for @escrowDisputeDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us specifics, what arrived vs what you expected?'**
  String get escrowDisputeDetailsHint;

  /// No description provided for @escrowOrdersEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t placed any bulk orders yet. Head to Trade to start.'**
  String get escrowOrdersEmpty;

  /// No description provided for @escrowStatusNotFound.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find that order'**
  String get escrowStatusNotFound;

  /// No description provided for @escrowStatusReviewNote.
  ///
  /// In en, this message translates to:
  /// **'We\'ll review evidence and resolve within 48 hours.'**
  String get escrowStatusReviewNote;

  /// No description provided for @recipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Cook tonight'**
  String get recipesTitle;

  /// No description provided for @recipesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real ingredients. Real vendors. One basket.'**
  String get recipesSubtitle;

  /// No description provided for @recipeDetailIngredients.
  ///
  /// In en, this message translates to:
  /// **'What\'s in the basket'**
  String get recipeDetailIngredients;

  /// No description provided for @recipeDetailServes.
  ///
  /// In en, this message translates to:
  /// **'Serves'**
  String get recipeDetailServes;

  /// No description provided for @recipeDetailCookingTime.
  ///
  /// In en, this message translates to:
  /// **'{mins} min cook'**
  String recipeDetailCookingTime(int mins);

  /// No description provided for @recipeSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get recipeSizeSmall;

  /// No description provided for @recipeSizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get recipeSizeMedium;

  /// No description provided for @recipeSizeFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get recipeSizeFamily;

  /// No description provided for @recipeSizeParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get recipeSizeParty;

  /// No description provided for @recipeAddToBasket.
  ///
  /// In en, this message translates to:
  /// **'Add to basket — ₦{price}'**
  String recipeAddToBasket(String price);

  /// No description provided for @recipeUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Some ingredients are missing'**
  String get recipeUnavailableTitle;

  /// No description provided for @recipeUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'These aren\'t available in your area right now: {items}'**
  String recipeUnavailableBody(String items);

  /// No description provided for @recipeEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet. Check back soon.'**
  String get recipeEmptyState;

  /// No description provided for @recipeCartSection.
  ///
  /// In en, this message translates to:
  /// **'Recipe combos'**
  String get recipeCartSection;

  /// No description provided for @recipeCartFromVendors.
  ///
  /// In en, this message translates to:
  /// **'{count} ingredients from {vendors} vendors'**
  String recipeCartFromVendors(int count, int vendors);

  /// No description provided for @recipeRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this recipe?'**
  String get recipeRemoveTitle;

  /// No description provided for @recipeRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Your basket will lose this combo.'**
  String get recipeRemoveBody;

  /// No description provided for @homeCookTonight.
  ///
  /// In en, this message translates to:
  /// **'Cook tonight'**
  String get homeCookTonight;

  /// No description provided for @homeCookTonightSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeCookTonightSeeAll;

  /// No description provided for @recipeFromPrice.
  ///
  /// In en, this message translates to:
  /// **'From ₦{amount}'**
  String recipeFromPrice(String amount);

  /// No description provided for @trackingRecipeMultiPickup.
  ///
  /// In en, this message translates to:
  /// **'Picking up from {count} vendors'**
  String trackingRecipeMultiPickup(int count);

  /// No description provided for @recipeIngredientsSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all ingredients'**
  String get recipeIngredientsSeeAll;

  /// No description provided for @recipeIngredientsCollapse.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get recipeIngredientsCollapse;

  /// No description provided for @recipeAddedToBasket.
  ///
  /// In en, this message translates to:
  /// **'Added to basket.'**
  String get recipeAddedToBasket;

  /// No description provided for @recipeAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add to basket. Try again.'**
  String get recipeAddFailed;

  /// No description provided for @recipeMatchFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t fetch price. Try a different size.'**
  String get recipeMatchFailed;

  /// No description provided for @recipeDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that recipe.'**
  String get recipeDetailNotFound;

  /// No description provided for @recipeDetailDescription.
  ///
  /// In en, this message translates to:
  /// **'About this dish'**
  String get recipeDetailDescription;

  /// No description provided for @recipeDetailCuisine.
  ///
  /// In en, this message translates to:
  /// **'Cuisine'**
  String get recipeDetailCuisine;

  /// No description provided for @recipeLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load recipes. Pull to retry.'**
  String get recipeLoadFailed;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @recipeOrderChildVendors.
  ///
  /// In en, this message translates to:
  /// **'Sourced from these vendors'**
  String get recipeOrderChildVendors;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning{name}. What\'s cooking?'**
  String homeGreetingMorning(String name);

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Hey{name}. Lunch break?'**
  String homeGreetingAfternoon(String name);

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening{name}. Dinner plans?'**
  String homeGreetingEvening(String name);

  /// No description provided for @homeGreetingNight.
  ///
  /// In en, this message translates to:
  /// **'Late night craving{name}? We see you.'**
  String homeGreetingNight(String name);

  /// No description provided for @homeQuickMealKits.
  ///
  /// In en, this message translates to:
  /// **'Meal Kits'**
  String get homeQuickMealKits;

  /// No description provided for @homeQuickTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get homeQuickTrack;

  /// No description provided for @homeQuickChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get homeQuickChat;

  /// No description provided for @homeQuickReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get homeQuickReorder;

  /// No description provided for @catRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get catRestaurants;

  /// No description provided for @catFreshMarket.
  ///
  /// In en, this message translates to:
  /// **'Fresh Market'**
  String get catFreshMarket;

  /// No description provided for @catLivestock.
  ///
  /// In en, this message translates to:
  /// **'Livestock'**
  String get catLivestock;

  /// No description provided for @catKitchenEssentials.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Essentials'**
  String get catKitchenEssentials;

  /// No description provided for @catGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get catGroceries;

  /// No description provided for @catFarmProduce.
  ///
  /// In en, this message translates to:
  /// **'Farm Produce'**
  String get catFarmProduce;

  /// No description provided for @catDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get catDrinks;

  /// No description provided for @catSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get catSnacks;

  /// No description provided for @catPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get catPharmacy;

  /// No description provided for @catTagRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Hot meals. Fast.'**
  String get catTagRestaurants;

  /// No description provided for @catTagFreshMarket.
  ///
  /// In en, this message translates to:
  /// **'Straight from the farm.'**
  String get catTagFreshMarket;

  /// No description provided for @catTagLivestock.
  ///
  /// In en, this message translates to:
  /// **'Cut exactly how you want.'**
  String get catTagLivestock;

  /// No description provided for @catTagKitchenEssentials.
  ///
  /// In en, this message translates to:
  /// **'Pots, pans, and everything else.'**
  String get catTagKitchenEssentials;

  /// No description provided for @catTagGroceries.
  ///
  /// In en, this message translates to:
  /// **'Pantry · Daily essentials'**
  String get catTagGroceries;

  /// No description provided for @catTagFarmProduce.
  ///
  /// In en, this message translates to:
  /// **'Bulk · Wholesale · Direct from farm'**
  String get catTagFarmProduce;

  /// No description provided for @catTagDrinks.
  ///
  /// In en, this message translates to:
  /// **'Soft drinks · Water · Juice'**
  String get catTagDrinks;

  /// No description provided for @catTagSnacks.
  ///
  /// In en, this message translates to:
  /// **'Bakery · Treats'**
  String get catTagSnacks;

  /// No description provided for @catTagPharmacy.
  ///
  /// In en, this message translates to:
  /// **'Wellness · OTC'**
  String get catTagPharmacy;

  /// No description provided for @subcatAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get subcatAll;

  /// No description provided for @subcatFastFood.
  ///
  /// In en, this message translates to:
  /// **'Fast Food'**
  String get subcatFastFood;

  /// No description provided for @subcatLocalCuisine.
  ///
  /// In en, this message translates to:
  /// **'Local Cuisine'**
  String get subcatLocalCuisine;

  /// No description provided for @subcatFineDining.
  ///
  /// In en, this message translates to:
  /// **'Fine Dining'**
  String get subcatFineDining;

  /// No description provided for @subcatGrillsBbq.
  ///
  /// In en, this message translates to:
  /// **'Grills & BBQ'**
  String get subcatGrillsBbq;

  /// No description provided for @subcatSeafood.
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get subcatSeafood;

  /// No description provided for @subcatBreakfastBrunch.
  ///
  /// In en, this message translates to:
  /// **'Breakfast & Brunch'**
  String get subcatBreakfastBrunch;

  /// No description provided for @subcatCafes.
  ///
  /// In en, this message translates to:
  /// **'Cafés'**
  String get subcatCafes;

  /// No description provided for @subcatShawarma.
  ///
  /// In en, this message translates to:
  /// **'Shawarma'**
  String get subcatShawarma;

  /// No description provided for @subcatPizza.
  ///
  /// In en, this message translates to:
  /// **'Pizza'**
  String get subcatPizza;

  /// No description provided for @subcatBurgers.
  ///
  /// In en, this message translates to:
  /// **'Burgers'**
  String get subcatBurgers;

  /// No description provided for @subcatSmallChops.
  ///
  /// In en, this message translates to:
  /// **'Small Chops'**
  String get subcatSmallChops;

  /// No description provided for @subcatRiceDishes.
  ///
  /// In en, this message translates to:
  /// **'Rice Dishes'**
  String get subcatRiceDishes;

  /// No description provided for @subcatTomatoes.
  ///
  /// In en, this message translates to:
  /// **'Tomatoes'**
  String get subcatTomatoes;

  /// No description provided for @subcatPepper.
  ///
  /// In en, this message translates to:
  /// **'Pepper'**
  String get subcatPepper;

  /// No description provided for @subcatOnion.
  ///
  /// In en, this message translates to:
  /// **'Onion'**
  String get subcatOnion;

  /// No description provided for @subcatYam.
  ///
  /// In en, this message translates to:
  /// **'Yam'**
  String get subcatYam;

  /// No description provided for @subcatPlantain.
  ///
  /// In en, this message translates to:
  /// **'Plantain'**
  String get subcatPlantain;

  /// No description provided for @subcatVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get subcatVegetables;

  /// No description provided for @subcatFreshFish.
  ///
  /// In en, this message translates to:
  /// **'Fresh fish'**
  String get subcatFreshFish;

  /// No description provided for @subcatFreshMeat.
  ///
  /// In en, this message translates to:
  /// **'Fresh meat'**
  String get subcatFreshMeat;

  /// No description provided for @subcatFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get subcatFruits;

  /// No description provided for @subcatChicken.
  ///
  /// In en, this message translates to:
  /// **'Chicken'**
  String get subcatChicken;

  /// No description provided for @subcatBeef.
  ///
  /// In en, this message translates to:
  /// **'Beef'**
  String get subcatBeef;

  /// No description provided for @subcatGoat.
  ///
  /// In en, this message translates to:
  /// **'Goat'**
  String get subcatGoat;

  /// No description provided for @subcatFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get subcatFish;

  /// No description provided for @subcatCookware.
  ///
  /// In en, this message translates to:
  /// **'Cookware'**
  String get subcatCookware;

  /// No description provided for @subcatUtensils.
  ///
  /// In en, this message translates to:
  /// **'Utensils'**
  String get subcatUtensils;

  /// No description provided for @subcatSpicesOil.
  ///
  /// In en, this message translates to:
  /// **'Spices & Oil'**
  String get subcatSpicesOil;

  /// No description provided for @subcatPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get subcatPantry;

  /// No description provided for @subcatCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get subcatCleaning;

  /// No description provided for @subcatRice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get subcatRice;

  /// No description provided for @subcatBeans.
  ///
  /// In en, this message translates to:
  /// **'Beans'**
  String get subcatBeans;

  /// No description provided for @subcatGarri.
  ///
  /// In en, this message translates to:
  /// **'Garri'**
  String get subcatGarri;

  /// No description provided for @subcatOil.
  ///
  /// In en, this message translates to:
  /// **'Oil'**
  String get subcatOil;

  /// No description provided for @subcatSugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get subcatSugar;

  /// No description provided for @subcatMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get subcatMilk;

  /// No description provided for @subcatBread.
  ///
  /// In en, this message translates to:
  /// **'Bread'**
  String get subcatBread;

  /// No description provided for @subcatEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get subcatEggs;

  /// No description provided for @subcatSpices.
  ///
  /// In en, this message translates to:
  /// **'Spices'**
  String get subcatSpices;

  /// No description provided for @subcatRiceBags.
  ///
  /// In en, this message translates to:
  /// **'Bags of rice'**
  String get subcatRiceBags;

  /// No description provided for @subcatCassava.
  ///
  /// In en, this message translates to:
  /// **'Cassava'**
  String get subcatCassava;

  /// No description provided for @subcatPalmOil.
  ///
  /// In en, this message translates to:
  /// **'Palm oil'**
  String get subcatPalmOil;

  /// No description provided for @subcatCocoa.
  ///
  /// In en, this message translates to:
  /// **'Cocoa'**
  String get subcatCocoa;

  /// No description provided for @subcatMaize.
  ///
  /// In en, this message translates to:
  /// **'Maize'**
  String get subcatMaize;

  /// No description provided for @subcatFeed.
  ///
  /// In en, this message translates to:
  /// **'Livestock feed'**
  String get subcatFeed;

  /// No description provided for @subcatFertilizer.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer'**
  String get subcatFertilizer;

  /// No description provided for @subcatBulkVeg.
  ///
  /// In en, this message translates to:
  /// **'Bulk vegetables'**
  String get subcatBulkVeg;

  /// No description provided for @subcatSoftDrinks.
  ///
  /// In en, this message translates to:
  /// **'Soft drinks'**
  String get subcatSoftDrinks;

  /// No description provided for @subcatWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get subcatWater;

  /// No description provided for @subcatJuice.
  ///
  /// In en, this message translates to:
  /// **'Juice'**
  String get subcatJuice;

  /// No description provided for @subcatEnergyDrinks.
  ///
  /// In en, this message translates to:
  /// **'Energy drinks'**
  String get subcatEnergyDrinks;

  /// No description provided for @subcatCakes.
  ///
  /// In en, this message translates to:
  /// **'Cakes'**
  String get subcatCakes;

  /// No description provided for @subcatPastries.
  ///
  /// In en, this message translates to:
  /// **'Pastries'**
  String get subcatPastries;

  /// No description provided for @subcatCookies.
  ///
  /// In en, this message translates to:
  /// **'Cookies'**
  String get subcatCookies;

  /// No description provided for @subcatSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get subcatSnacks;

  /// No description provided for @subcatOtcMeds.
  ///
  /// In en, this message translates to:
  /// **'OTC medication'**
  String get subcatOtcMeds;

  /// No description provided for @subcatWellness.
  ///
  /// In en, this message translates to:
  /// **'Wellness'**
  String get subcatWellness;

  /// No description provided for @subcatVitamins.
  ///
  /// In en, this message translates to:
  /// **'Vitamins'**
  String get subcatVitamins;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get navActive;

  /// No description provided for @navEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get navEarnings;

  /// No description provided for @navMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @navRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get navRecord;

  /// No description provided for @navPayout.
  ///
  /// In en, this message translates to:
  /// **'Payout'**
  String get navPayout;

  /// No description provided for @navListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get navListings;

  /// No description provided for @navPrices.
  ///
  /// In en, this message translates to:
  /// **'Prices'**
  String get navPrices;

  /// No description provided for @navLoads.
  ///
  /// In en, this message translates to:
  /// **'Loads'**
  String get navLoads;

  /// No description provided for @navTrip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get navTrip;

  /// No description provided for @roleSwitcherTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch role'**
  String get roleSwitcherTitle;

  /// No description provided for @roleSwitcherSub.
  ///
  /// In en, this message translates to:
  /// **'Approved roles let you jump in. Tap an unverified one to start verification.'**
  String get roleSwitcherSub;

  /// No description provided for @roleStatusAlwaysOn.
  ///
  /// In en, this message translates to:
  /// **'Always on'**
  String get roleStatusAlwaysOn;

  /// No description provided for @roleStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get roleStatusApproved;

  /// No description provided for @roleStatusPending.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get roleStatusPending;

  /// No description provided for @roleStatusGetVerified.
  ///
  /// In en, this message translates to:
  /// **'Get verified'**
  String get roleStatusGetVerified;

  /// No description provided for @roleStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get roleStatusActive;

  /// No description provided for @deleteAccountLeavingTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaving us?'**
  String get deleteAccountLeavingTitle;

  /// No description provided for @deleteAccountLeavingBody.
  ///
  /// In en, this message translates to:
  /// **'We\'re sad to see you go. Before you leave:'**
  String get deleteAccountLeavingBody;

  /// No description provided for @deleteAccountConfirmPermanent.
  ///
  /// In en, this message translates to:
  /// **'Delete your account permanently?'**
  String get deleteAccountConfirmPermanent;

  /// No description provided for @deleteAccountCannotUndo.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteAccountCannotUndo;

  /// No description provided for @profilePhotoError.
  ///
  /// In en, this message translates to:
  /// **'Could not update photo. Try again.'**
  String get profilePhotoError;

  /// No description provided for @profilePreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferences;

  /// No description provided for @profileVersionSub.
  ///
  /// In en, this message translates to:
  /// **'v2.1.0'**
  String get profileVersionSub;

  /// No description provided for @profileLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get profileLegal;

  /// No description provided for @profileStatsOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get profileStatsOrders;

  /// No description provided for @profileStatsBulk.
  ///
  /// In en, this message translates to:
  /// **'Bulk'**
  String get profileStatsBulk;

  /// No description provided for @profileStatsFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileStatsFavorites;

  /// No description provided for @profileLanguageSub.
  ///
  /// In en, this message translates to:
  /// **'English · Français · Hausa · Yorùbá · Igbo'**
  String get profileLanguageSub;

  /// No description provided for @profileGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re browsing as a guest'**
  String get profileGuestTitle;

  /// No description provided for @profileGuestBody.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your profile, orders, wallet and favorites.'**
  String get profileGuestBody;

  /// No description provided for @profileCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get profileCreateAccount;

  /// No description provided for @operatorAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get operatorAccountTitle;

  /// No description provided for @operatorOperationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get operatorOperationsTitle;

  /// No description provided for @operatorVersionSub.
  ///
  /// In en, this message translates to:
  /// **'v2.1.0'**
  String get operatorVersionSub;

  /// No description provided for @forgotSmsLabel.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get forgotSmsLabel;

  /// No description provided for @forgotSmsSub.
  ///
  /// In en, this message translates to:
  /// **'To your phone'**
  String get forgotSmsSub;

  /// No description provided for @forgotEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgotEmailLabel;

  /// No description provided for @forgotEmailSub.
  ///
  /// In en, this message translates to:
  /// **'To your inbox'**
  String get forgotEmailSub;

  /// No description provided for @vendorOrderAccepted.
  ///
  /// In en, this message translates to:
  /// **'Order accepted'**
  String get vendorOrderAccepted;

  /// No description provided for @vendorOrderDeclined.
  ///
  /// In en, this message translates to:
  /// **'Order declined'**
  String get vendorOrderDeclined;

  /// No description provided for @vendorLiveOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Live orders'**
  String get vendorLiveOrdersTitle;

  /// No description provided for @vendorDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vendor dashboard'**
  String get vendorDashboardSubtitle;

  /// No description provided for @vendorCallingCustomer.
  ///
  /// In en, this message translates to:
  /// **'Calling customer…'**
  String get vendorCallingCustomer;

  /// No description provided for @vendorTicketSent.
  ///
  /// In en, this message translates to:
  /// **'Ticket sent to printer'**
  String get vendorTicketSent;

  /// No description provided for @vendorIssueSent.
  ///
  /// In en, this message translates to:
  /// **'Issue reported to support'**
  String get vendorIssueSent;

  /// No description provided for @vendorSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get vendorSettingsSaved;

  /// No description provided for @vendorSettingsStoreHours.
  ///
  /// In en, this message translates to:
  /// **'Store hours'**
  String get vendorSettingsStoreHours;

  /// No description provided for @vendorNotifPushEmail.
  ///
  /// In en, this message translates to:
  /// **'Push + email'**
  String get vendorNotifPushEmail;

  /// No description provided for @vendorNotifPushOnly.
  ///
  /// In en, this message translates to:
  /// **'Push only'**
  String get vendorNotifPushOnly;

  /// No description provided for @vendorMenuAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get vendorMenuAdd;

  /// No description provided for @vendorMenuSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Find a dish…'**
  String get vendorMenuSearchPlaceholder;

  /// No description provided for @vendorMenuEditDish.
  ///
  /// In en, this message translates to:
  /// **'Edit dish'**
  String get vendorMenuEditDish;

  /// No description provided for @vendorMenuDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get vendorMenuDuplicate;

  /// No description provided for @vendorMenuDuplicated.
  ///
  /// In en, this message translates to:
  /// **'{name} duplicated'**
  String vendorMenuDuplicated(String name);

  /// No description provided for @vendorMenuDeleteDish.
  ///
  /// In en, this message translates to:
  /// **'Delete dish'**
  String get vendorMenuDeleteDish;

  /// No description provided for @vendorMenuDishRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String vendorMenuDishRemoved(String name);

  /// No description provided for @vendorMenuDishRequired.
  ///
  /// In en, this message translates to:
  /// **'Dish name and price are required.'**
  String get vendorMenuDishRequired;

  /// No description provided for @vendorMenuDishUpdated.
  ///
  /// In en, this message translates to:
  /// **'{name} updated'**
  String vendorMenuDishUpdated(String name);

  /// No description provided for @vendorMenuDishAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added to the menu'**
  String vendorMenuDishAdded(String name);

  /// No description provided for @vendorMenuDishNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Dish name'**
  String get vendorMenuDishNameLabel;

  /// No description provided for @vendorMenuDishNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Jollof rice'**
  String get vendorMenuDishNamePlaceholder;

  /// No description provided for @vendorMenuDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get vendorMenuDescLabel;

  /// No description provided for @vendorMenuDescPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tasty, spicy, fresh…'**
  String get vendorMenuDescPlaceholder;

  /// No description provided for @vendorMenuPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (₦)'**
  String get vendorMenuPriceLabel;

  /// No description provided for @vendorMenuCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get vendorMenuCategoryLabel;

  /// No description provided for @vendorMenuAddGroup.
  ///
  /// In en, this message translates to:
  /// **'Add group'**
  String get vendorMenuAddGroup;

  /// No description provided for @vendorMenuGroupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get vendorMenuGroupNameLabel;

  /// No description provided for @vendorMenuOptionLabelPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Option label'**
  String get vendorMenuOptionLabelPlaceholder;

  /// No description provided for @vendorMenuOptionPricePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'+₦0'**
  String get vendorMenuOptionPricePlaceholder;

  /// No description provided for @vendorReviewReplyPosted.
  ///
  /// In en, this message translates to:
  /// **'Reply posted to {reviewer}'**
  String vendorReviewReplyPosted(String reviewer);

  /// No description provided for @vendorReviewRepliedLabel.
  ///
  /// In en, this message translates to:
  /// **'Replied'**
  String get vendorReviewRepliedLabel;

  /// No description provided for @vendorReviewYourReply.
  ///
  /// In en, this message translates to:
  /// **'Your reply'**
  String get vendorReviewYourReply;

  /// No description provided for @vendorReviewReplyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Thanks for the feedback, we hear you...'**
  String get vendorReviewReplyPlaceholder;

  /// No description provided for @vendorReviewPostReply.
  ///
  /// In en, this message translates to:
  /// **'Post reply'**
  String get vendorReviewPostReply;

  /// No description provided for @vendorAnalyticsCsvStarted.
  ///
  /// In en, this message translates to:
  /// **'CSV export started'**
  String get vendorAnalyticsCsvStarted;

  /// No description provided for @vendorAnalyticsOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get vendorAnalyticsOutOfStock;

  /// No description provided for @vendorAnalyticsWrongAddress.
  ///
  /// In en, this message translates to:
  /// **'Wrong address'**
  String get vendorAnalyticsWrongAddress;

  /// No description provided for @vendorAnalyticsCustomerChange.
  ///
  /// In en, this message translates to:
  /// **'Customer change'**
  String get vendorAnalyticsCustomerChange;

  /// No description provided for @vendorAnalyticsOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get vendorAnalyticsOther;

  /// No description provided for @vendorInventoryItemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get vendorInventoryItemName;

  /// No description provided for @vendorInventoryQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get vendorInventoryQuantity;

  /// No description provided for @vendorInventoryUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit (kg / bags…)'**
  String get vendorInventoryUnit;

  /// No description provided for @vendorInventoryThreshold.
  ///
  /// In en, this message translates to:
  /// **'Low-stock threshold'**
  String get vendorInventoryThreshold;

  /// No description provided for @vendorInventoryAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get vendorInventoryAddItem;

  /// No description provided for @vendorInventoryNewBatch.
  ///
  /// In en, this message translates to:
  /// **'New batch'**
  String get vendorInventoryNewBatch;

  /// No description provided for @vendorInventoryUpdateStock.
  ///
  /// In en, this message translates to:
  /// **'Update stock'**
  String get vendorInventoryUpdateStock;

  /// No description provided for @vendorInventoryItemUpdated.
  ///
  /// In en, this message translates to:
  /// **'{name} updated'**
  String vendorInventoryItemUpdated(String name);

  /// No description provided for @vendorInventoryBatchLogged.
  ///
  /// In en, this message translates to:
  /// **'New batch logged for {name}'**
  String vendorInventoryBatchLogged(String name);

  /// No description provided for @vendorAlertsRestockSub.
  ///
  /// In en, this message translates to:
  /// **'Restock to keep accepting orders'**
  String get vendorAlertsRestockSub;

  /// No description provided for @vendorPayoutsEarnings.
  ///
  /// In en, this message translates to:
  /// **'Your earnings'**
  String get vendorPayoutsEarnings;

  /// No description provided for @agentTxnTraderRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick a trader to log this sale against.'**
  String get agentTxnTraderRequired;

  /// No description provided for @agentTxnFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Product, quantity and unit price are required.'**
  String get agentTxnFieldsRequired;

  /// No description provided for @agentTxnSavedOffline.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved offline'**
  String get agentTxnSavedOffline;

  /// No description provided for @agentTxnTraderLabel.
  ///
  /// In en, this message translates to:
  /// **'Trader'**
  String get agentTxnTraderLabel;

  /// No description provided for @agentTxnProductLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get agentTxnProductLabel;

  /// No description provided for @agentTxnQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity (kg)'**
  String get agentTxnQuantityLabel;

  /// No description provided for @agentTxnUnitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit price (₦)'**
  String get agentTxnUnitPriceLabel;

  /// No description provided for @agentTxnSave.
  ///
  /// In en, this message translates to:
  /// **'Save transaction'**
  String get agentTxnSave;

  /// No description provided for @agentPayoutTraderRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick a trader to record this payout against.'**
  String get agentPayoutTraderRequired;

  /// No description provided for @agentPayoutAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than ₦0.'**
  String get agentPayoutAmountRequired;

  /// No description provided for @agentPayoutRecorded.
  ///
  /// In en, this message translates to:
  /// **'Payout recorded · reimbursement queued'**
  String get agentPayoutRecorded;

  /// No description provided for @agentPayoutNotePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Payout for tomato sale'**
  String get agentPayoutNotePlaceholder;

  /// No description provided for @agentSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync with WAWU'**
  String get agentSyncTitle;

  /// No description provided for @agentSyncPendingTraders.
  ///
  /// In en, this message translates to:
  /// **'Pending traders'**
  String get agentSyncPendingTraders;

  /// No description provided for @agentSyncPendingTxns.
  ///
  /// In en, this message translates to:
  /// **'Pending transactions'**
  String get agentSyncPendingTxns;

  /// No description provided for @agentSyncPendingPayouts.
  ///
  /// In en, this message translates to:
  /// **'Pending payouts'**
  String get agentSyncPendingPayouts;

  /// No description provided for @agentSyncLastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get agentSyncLastSync;

  /// No description provided for @agentSyncOfflineCopy.
  ///
  /// In en, this message translates to:
  /// **'Your offline copy'**
  String get agentSyncOfflineCopy;

  /// No description provided for @agentSyncServer.
  ///
  /// In en, this message translates to:
  /// **'WAWU server'**
  String get agentSyncServer;

  /// No description provided for @agentSyncKeepThis.
  ///
  /// In en, this message translates to:
  /// **'Keep this version'**
  String get agentSyncKeepThis;

  /// No description provided for @agentRegNamePhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Name and phone are required.'**
  String get agentRegNamePhoneRequired;

  /// No description provided for @agentRegSavedOffline.
  ///
  /// In en, this message translates to:
  /// **'Trader saved offline · will sync next'**
  String get agentRegSavedOffline;

  /// No description provided for @agentRegNewTraderTitle.
  ///
  /// In en, this message translates to:
  /// **'New trader'**
  String get agentRegNewTraderTitle;

  /// No description provided for @agentRegFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get agentRegFullNameLabel;

  /// No description provided for @agentRegFullNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Full name as on ID'**
  String get agentRegFullNamePlaceholder;

  /// No description provided for @agentRegPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get agentRegPhoneLabel;

  /// No description provided for @agentRegPhonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'812 345 6789'**
  String get agentRegPhonePlaceholder;

  /// No description provided for @agentRegLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get agentRegLocationLabel;

  /// No description provided for @agentRegLocationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Market or village name'**
  String get agentRegLocationPlaceholder;

  /// No description provided for @agentRegPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Trader photo'**
  String get agentRegPhotoLabel;

  /// No description provided for @agentRegIdLabel.
  ///
  /// In en, this message translates to:
  /// **'ID document'**
  String get agentRegIdLabel;

  /// No description provided for @agentTradersPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Your traders'**
  String get agentTradersPageTitle;

  /// No description provided for @agentTradersSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone…'**
  String get agentTradersSearchPlaceholder;

  /// No description provided for @tradeSuppliersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No suppliers listed yet.'**
  String get tradeSuppliersEmpty;

  /// No description provided for @tradeBulkEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bulk lots listed yet.'**
  String get tradeBulkEmpty;

  /// No description provided for @bulkUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get bulkUnitPrice;

  /// No description provided for @bulkLotSize.
  ///
  /// In en, this message translates to:
  /// **'Lot size'**
  String get bulkLotSize;

  /// No description provided for @bulkMoq.
  ///
  /// In en, this message translates to:
  /// **'MOQ'**
  String get bulkMoq;

  /// No description provided for @bulkLeadTime.
  ///
  /// In en, this message translates to:
  /// **'Lead time'**
  String get bulkLeadTime;

  /// No description provided for @bulkOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get bulkOrigin;

  /// No description provided for @bulkShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get bulkShipping;

  /// No description provided for @bulkQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get bulkQuality;

  /// No description provided for @bulkRequestQuote.
  ///
  /// In en, this message translates to:
  /// **'Request quote'**
  String get bulkRequestQuote;

  /// No description provided for @bulkThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get bulkThisWeek;

  /// No description provided for @bulkWithin2Wks.
  ///
  /// In en, this message translates to:
  /// **'Within 2 wks'**
  String get bulkWithin2Wks;

  /// No description provided for @bulkThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get bulkThisMonth;

  /// No description provided for @bulkDeliveryHint.
  ///
  /// In en, this message translates to:
  /// **'Delivery address, packing notes…'**
  String get bulkDeliveryHint;

  /// No description provided for @bulkSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get bulkSendRequest;

  /// No description provided for @exportQtyAvailable.
  ///
  /// In en, this message translates to:
  /// **'Quantity available'**
  String get exportQtyAvailable;

  /// No description provided for @exportPricePerKg.
  ///
  /// In en, this message translates to:
  /// **'Price per kg'**
  String get exportPricePerKg;

  /// No description provided for @exportHarvestDate.
  ///
  /// In en, this message translates to:
  /// **'Harvest date'**
  String get exportHarvestDate;

  /// No description provided for @exportCorridor.
  ///
  /// In en, this message translates to:
  /// **'Corridor'**
  String get exportCorridor;

  /// No description provided for @exportEnquire.
  ///
  /// In en, this message translates to:
  /// **'Enquire'**
  String get exportEnquire;

  /// No description provided for @supplierConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get supplierConnect;

  /// No description provided for @traderEditListing.
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get traderEditListing;

  /// No description provided for @traderStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'{produce} status updated'**
  String traderStatusUpdated(String produce);

  /// No description provided for @traderDeleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete listing'**
  String get traderDeleteListing;

  /// No description provided for @traderListingRemoved.
  ///
  /// In en, this message translates to:
  /// **'{produce} removed'**
  String traderListingRemoved(String produce);

  /// No description provided for @traderPostListing.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get traderPostListing;

  /// No description provided for @traderFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get traderFilterAll;

  /// No description provided for @traderFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Produce, quantity and price are required.'**
  String get traderFieldsRequired;

  /// No description provided for @traderFarmRequired.
  ///
  /// In en, this message translates to:
  /// **'Farm name and region are required.'**
  String get traderFarmRequired;

  /// No description provided for @traderListingUpdated.
  ///
  /// In en, this message translates to:
  /// **'{produce} updated'**
  String traderListingUpdated(String produce);

  /// No description provided for @traderListingPosted.
  ///
  /// In en, this message translates to:
  /// **'{produce} listed'**
  String traderListingPosted(String produce);

  /// No description provided for @traderHarvestDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Harvest date'**
  String get traderHarvestDateLabel;

  /// No description provided for @traderCorridorOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin corridor'**
  String get traderCorridorOrigin;

  /// No description provided for @traderCorridorDest.
  ///
  /// In en, this message translates to:
  /// **'Destination corridor'**
  String get traderCorridorDest;

  /// No description provided for @traderMarketCategory.
  ///
  /// In en, this message translates to:
  /// **'Marketplace category'**
  String get traderMarketCategory;

  /// No description provided for @traderMarketCategoryNote.
  ///
  /// In en, this message translates to:
  /// **'Optional — pick a category so this listing appears in the customer marketplace.'**
  String get traderMarketCategoryNote;

  /// No description provided for @traderClearCategory.
  ///
  /// In en, this message translates to:
  /// **'Clear category'**
  String get traderClearCategory;

  /// No description provided for @traderEditListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get traderEditListingTitle;

  /// No description provided for @traderNewListingTitle.
  ///
  /// In en, this message translates to:
  /// **'New export listing'**
  String get traderNewListingTitle;

  /// No description provided for @traderChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get traderChangePhoto;

  /// No description provided for @traderUploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get traderUploadPhoto;

  /// No description provided for @traderPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Shot of the lot ready for shipping'**
  String get traderPhotoHint;

  /// No description provided for @traderProducePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Tomatoes'**
  String get traderProducePlaceholder;

  /// No description provided for @traderFarmPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Hauwa & Sons Farm'**
  String get traderFarmPlaceholder;

  /// No description provided for @traderRegionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Kano'**
  String get traderRegionPlaceholder;

  /// No description provided for @traderFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get traderFromLabel;

  /// No description provided for @traderToLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get traderToLabel;

  /// No description provided for @traderCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Marketplace category (optional)'**
  String get traderCategoryLabel;

  /// No description provided for @traderNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get traderNoCategories;

  /// No description provided for @traderNoneSelected.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get traderNoneSelected;

  /// No description provided for @traderSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get traderSaveChanges;

  /// No description provided for @traderPostListingBtn.
  ///
  /// In en, this message translates to:
  /// **'Post listing'**
  String get traderPostListingBtn;

  /// No description provided for @traderDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trader dashboard'**
  String get traderDashboardSubtitle;

  /// No description provided for @searchVendors.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get searchVendors;

  /// No description provided for @searchDishes.
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get searchDishes;

  /// No description provided for @productAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get productAddNote;

  /// No description provided for @productNotePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'E.g. less spicy, no onions…'**
  String get productNotePlaceholder;

  /// No description provided for @shoppingViewBasket.
  ///
  /// In en, this message translates to:
  /// **'View basket'**
  String get shoppingViewBasket;

  /// No description provided for @escrowAddDropOff.
  ///
  /// In en, this message translates to:
  /// **'Add a drop-off address.'**
  String get escrowAddDropOff;

  /// No description provided for @escrowDropOffPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Where should the lot land?'**
  String get escrowDropOffPlaceholder;

  /// No description provided for @escrowBulkOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk orders'**
  String get escrowBulkOrdersTitle;

  /// No description provided for @escrowDisputeTitle.
  ///
  /// In en, this message translates to:
  /// **'Open a dispute'**
  String get escrowDisputeTitle;

  /// No description provided for @escrowPhotoUploadSoon.
  ///
  /// In en, this message translates to:
  /// **'Photo upload coming soon'**
  String get escrowPhotoUploadSoon;

  /// No description provided for @escrowPhotoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t upload the photo. Try again.'**
  String get escrowPhotoUploadFailed;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// No description provided for @livestockSameDay.
  ///
  /// In en, this message translates to:
  /// **'Same day'**
  String get livestockSameDay;

  /// No description provided for @livestockVacuumPacked.
  ///
  /// In en, this message translates to:
  /// **'Vacuum packed'**
  String get livestockVacuumPacked;

  /// No description provided for @driverOpenLoads.
  ///
  /// In en, this message translates to:
  /// **'Open loads'**
  String get driverOpenLoads;

  /// No description provided for @driverToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get driverToday;

  /// No description provided for @driverBid.
  ///
  /// In en, this message translates to:
  /// **'Bid'**
  String get driverBid;

  /// No description provided for @driverAddPriceEta.
  ///
  /// In en, this message translates to:
  /// **'Add a price and an ETA.'**
  String get driverAddPriceEta;

  /// No description provided for @driverBidTitle.
  ///
  /// In en, this message translates to:
  /// **'Place your bid'**
  String get driverBidTitle;

  /// No description provided for @driverPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (₦)'**
  String get driverPriceLabel;

  /// No description provided for @driverEtaLabel.
  ///
  /// In en, this message translates to:
  /// **'ETA to destination (hours)'**
  String get driverEtaLabel;

  /// No description provided for @driverNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get driverNotesLabel;

  /// No description provided for @driverNotesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'I run this route every week.'**
  String get driverNotesPlaceholder;

  /// No description provided for @driverOtherBids.
  ///
  /// In en, this message translates to:
  /// **'{count} other bids'**
  String driverOtherBids(int count);

  /// No description provided for @driverSubmitBid.
  ///
  /// In en, this message translates to:
  /// **'Submit bid'**
  String get driverSubmitBid;

  /// No description provided for @driverBrowseLoads.
  ///
  /// In en, this message translates to:
  /// **'Browse loads'**
  String get driverBrowseLoads;

  /// No description provided for @driverHeadingTo.
  ///
  /// In en, this message translates to:
  /// **'Heading to {destination}'**
  String driverHeadingTo(String destination);

  /// No description provided for @driverCallLabel.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get driverCallLabel;

  /// No description provided for @driverCallingTrader.
  ///
  /// In en, this message translates to:
  /// **'Calling {name}…'**
  String driverCallingTrader(String name);

  /// No description provided for @riderSupportNotified.
  ///
  /// In en, this message translates to:
  /// **'Support has been notified'**
  String get riderSupportNotified;

  /// No description provided for @catStandardLabel.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get catStandardLabel;

  /// No description provided for @catStandardSub.
  ///
  /// In en, this message translates to:
  /// **'Everyday good'**
  String get catStandardSub;

  /// No description provided for @catPremiumLabel.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get catPremiumLabel;

  /// No description provided for @catPremiumSub.
  ///
  /// In en, this message translates to:
  /// **'Larger, riper'**
  String get catPremiumSub;

  /// No description provided for @catJollofBundleTitle.
  ///
  /// In en, this message translates to:
  /// **'Jollof bundle'**
  String get catJollofBundleTitle;

  /// No description provided for @catJollofBundleSub.
  ///
  /// In en, this message translates to:
  /// **'Everything you need · save 15%'**
  String get catJollofBundleSub;

  /// No description provided for @catBundleAdded.
  ///
  /// In en, this message translates to:
  /// **'Bundle added to basket'**
  String get catBundleAdded;

  /// No description provided for @catFarmerTitle.
  ///
  /// In en, this message translates to:
  /// **'Meet the farmer'**
  String get catFarmerTitle;

  /// No description provided for @catFarmerSub.
  ///
  /// In en, this message translates to:
  /// **'Behind your tomatoes'**
  String get catFarmerSub;

  /// No description provided for @catFarmerSoon.
  ///
  /// In en, this message translates to:
  /// **'Farmer spotlight coming soon'**
  String get catFarmerSoon;

  /// No description provided for @catReorderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get catReorderLabel;

  /// No description provided for @catLastBasketReordered.
  ///
  /// In en, this message translates to:
  /// **'Last basket reordered'**
  String get catLastBasketReordered;

  /// No description provided for @catBodyChooseCut.
  ///
  /// In en, this message translates to:
  /// **'Choose your cut'**
  String get catBodyChooseCut;

  /// No description provided for @catBodyPopularNearYou.
  ///
  /// In en, this message translates to:
  /// **'Popular near you'**
  String get catBodyPopularNearYou;

  /// No description provided for @catBodyTrendingToday.
  ///
  /// In en, this message translates to:
  /// **'Trending dishes today'**
  String get catBodyTrendingToday;

  /// No description provided for @catBodyFeaturedRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Featured restaurants'**
  String get catBodyFeaturedRestaurants;

  /// No description provided for @catBodyPopularDishes.
  ///
  /// In en, this message translates to:
  /// **'Popular dishes'**
  String get catBodyPopularDishes;

  /// No description provided for @catBodyTopPicks.
  ///
  /// In en, this message translates to:
  /// **'Top picks'**
  String get catBodyTopPicks;

  /// No description provided for @catBodyTopBulkLots.
  ///
  /// In en, this message translates to:
  /// **'Top bulk lots'**
  String get catBodyTopBulkLots;

  /// No description provided for @catBodyFeaturedSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Featured suppliers'**
  String get catBodyFeaturedSuppliers;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login error: {error}'**
  String loginError(String error);

  /// No description provided for @topUpMethodSoon.
  ///
  /// In en, this message translates to:
  /// **'Method picker, coming soon'**
  String get topUpMethodSoon;

  /// No description provided for @trackingRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get trackingRetry;

  /// No description provided for @vendorSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your store settings'**
  String get vendorSettingsTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'am',
    'ar',
    'ee',
    'en',
    'fr',
    'ha',
    'ig',
    'ln',
    'pt',
    'rw',
    'sw',
    'tw',
    'wo',
    'yo',
    'zu',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'ar':
      return AppLocalizationsAr();
    case 'ee':
      return AppLocalizationsEe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ha':
      return AppLocalizationsHa();
    case 'ig':
      return AppLocalizationsIg();
    case 'ln':
      return AppLocalizationsLn();
    case 'pt':
      return AppLocalizationsPt();
    case 'rw':
      return AppLocalizationsRw();
    case 'sw':
      return AppLocalizationsSw();
    case 'tw':
      return AppLocalizationsTw();
    case 'wo':
      return AppLocalizationsWo();
    case 'yo':
      return AppLocalizationsYo();
    case 'zu':
      return AppLocalizationsZu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
