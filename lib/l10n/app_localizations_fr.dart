// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'WAWUBasket';

  @override
  String get navHome => 'Accueil';

  @override
  String get navTrade => 'Commerce';

  @override
  String get navOrders => 'Commandes';

  @override
  String get navAccount => 'Compte';

  @override
  String get navSearch => 'Rechercher';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionNext => 'Suivant';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionSeeAll => 'Tout voir';

  @override
  String get commonLoading => 'Chargement…';

  @override
  String get commonError => 'Une erreur s\'est produite.';

  @override
  String get commonEmpty => 'Rien ici pour l\'instant.';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSubtitle => 'Choisissez comment WAWUBasket vous parle.';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'Créer un compte';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get chatEmpty =>
      'Aucun message pour l\'instant. Envoyez le premier ci-dessous.';

  @override
  String get chatInboxEmpty =>
      'Pas encore de discussions de commande. Elles apparaissent ici une fois que vous avez une commande active.';

  @override
  String get chatSupportPrompt => 'Des questions ? Discutez avec notre équipe.';

  @override
  String get chatAttachmentFailed => 'Impossible d\'envoyer la pièce jointe.';

  @override
  String get kycSubmitted =>
      'Candidature soumise. Nous l\'examinerons et vous ferons savoir.';

  @override
  String get kycUploadFailed =>
      'Impossible de téléverser le document. Réessayez.';

  @override
  String get splashTagline => 'Un panier. Tout.';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingPermissionsTitle => 'Quelques autorisations rapides';

  @override
  String get onboardingPermissionsSubtitle =>
      'Elles améliorent le panier pour vous. Vous pouvez les modifier à tout moment.';

  @override
  String get onboardingLocationTitle => 'Où cuisinez-vous aujourd\'hui ?';

  @override
  String get onboardingLocationBody =>
      'Nous avons besoin de votre localisation pour vous montrer les restaurants et marchés près de chez vous. Nous ne partageons jamais votre position exacte avec quiconque.';

  @override
  String get onboardingLocationPrimary => 'Pendant l\'utilisation';

  @override
  String get onboardingLocationSecondary => 'Autoriser une fois';

  @override
  String get onboardingLocationTertiary => 'Pas maintenant';

  @override
  String get onboardingNotificationsTitle => 'Ne manquez pas les bonnes choses';

  @override
  String get onboardingNotificationsBody =>
      'Nous vous dirons quand votre commande est en route, quand votre viande est fraîchement découpée, et quand il y a une surprise qui attend.';

  @override
  String get onboardingNotificationsPrimary => 'Oui, dites-moi';

  @override
  String get onboardingNotificationsSecondary => 'Peut-être plus tard';

  @override
  String get onboardingQuizTitle => 'Construisons votre panier';

  @override
  String get onboardingQuizSubtitle =>
      'Dites-nous ce que vous aimez, et nous ferons en sorte que vous le voyiez en premier.';

  @override
  String get onboardingQuizWantsLabel => 'Que voulez-vous habituellement ?';

  @override
  String get onboardingQuizWantOption1 => 'Repas cuisinés des restaurants';

  @override
  String get onboardingQuizWantOption2 => 'Fruits et légumes frais';

  @override
  String get onboardingQuizWantOption3 => 'Viande, poulet et poisson';

  @override
  String get onboardingQuizWantOption4 => 'Casseroles, poêles et garde-manger';

  @override
  String get onboardingQuizSpeedLabel =>
      'À quelle vitesse avez-vous besoin des choses ?';

  @override
  String get onboardingQuizSpeedOption1 => 'Maintenant, j\'ai faim';

  @override
  String get onboardingQuizSpeedOption2 => 'Aujourd\'hui à un moment';

  @override
  String get onboardingQuizSpeedOption3 => 'Je planifie à l\'avance';

  @override
  String get onboardingQuizAvoidLabel =>
      'Des aliments que nous devrions éviter ?';

  @override
  String get onboardingQuizAvoidPlaceholder =>
      'ex. pas de crustacés, pas de bœuf';

  @override
  String get onboardingQuizBuildButton => 'Construire mon panier';

  @override
  String get onboardingQuizSkipLink => 'Je verrai ça plus tard';

  @override
  String get onboardingGiftTitle => 'Un petit cadeau de bienvenue';

  @override
  String get onboardingGiftBody =>
      'Votre première commande vient avec quelque chose en plus. Juste parce que vous le méritez.';

  @override
  String get onboardingGiftButton => 'Voyons ce qu\'il y a à l\'intérieur';

  @override
  String get onboardingGiftFootnote =>
      'Valable pour la première commande uniquement. Commande minimum applicable.';

  @override
  String get loginTitle => 'Se connecter';

  @override
  String get loginSubtitle =>
      'Bon retour. Reprenez là où vous vous êtes arrêté.';

  @override
  String get loginPhoneLabel => 'Téléphone ou e-mail';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginBiometric => 'Utiliser Face ID';

  @override
  String get loginSignupLink => 'Nouveau sur WAWUBasket ?';

  @override
  String get loginErrorEmpty =>
      'Entrez votre téléphone/e-mail et mot de passe.';

  @override
  String get loginBiometricOfferTitle => 'Connexion plus rapide';

  @override
  String get loginBiometricOfferBody =>
      'Utiliser Face ID ou votre empreinte pour vous connecter la prochaine fois ?';

  @override
  String get loginBiometricNotNow => 'Pas maintenant';

  @override
  String get loginBiometricEnable => 'Activer';

  @override
  String get loginBiometricNotAvailable =>
      'Le déverrouillage biométrique n\'est pas configuré sur cet appareil.';

  @override
  String get signupTitle => 'Quel est votre numéro WhatsApp ?';

  @override
  String get signupSubtitle =>
      'Nous enverrons un code pour nous assurer que c\'est bien vous.';

  @override
  String get signupNameLabel => 'Nom complet';

  @override
  String get signupPhoneLabel => 'Numéro WhatsApp';

  @override
  String get signupEmailLabel => 'E-mail';

  @override
  String get signupPasswordLabel => 'Mot de passe';

  @override
  String get signupPasswordPlaceholder => 'Au moins 8 caractères';

  @override
  String get signupSendCode => 'Envoyer le code';

  @override
  String get signupDisclaimer =>
      'Pas de spam. Pas d\'appels. Juste vos mises à jour de panier.';

  @override
  String get signupHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get signupErrorName => 'Remplissez votre nom, numéro et e-mail.';

  @override
  String get signupErrorPassword =>
      'Le mot de passe doit comporter au moins 8 caractères.';

  @override
  String get signupErrorTerms => 'Acceptez les Conditions pour continuer.';

  @override
  String get otpTitle => 'Vous avez un code !';

  @override
  String get otpSubtitle => 'Vérifiez votre WhatsApp. C\'est court.';

  @override
  String get otpEditNumber => 'Modifier le numéro';

  @override
  String get otpResend => 'Renvoyer le code';

  @override
  String get otpVerifyButton => 'Vérifier et entrer';

  @override
  String get otpNewCode => 'Un nouveau code est en route.';

  @override
  String get forgotTitle => 'Réinitialiser le mot de passe';

  @override
  String get forgotSubtitle =>
      'Dites-nous où envoyer un code de vérification et nous vous aiderons à revenir.';

  @override
  String get forgotSendCode => 'Envoyer le code';

  @override
  String get forgotErrorEmpty => 'Entrez votre numéro de téléphone ou e-mail.';

  @override
  String get resetTitle => 'Choisissez un nouveau mot de passe';

  @override
  String get resetSubtitle => 'Rendez-le différent du dernier.';

  @override
  String get resetPasswordLabel => 'Nouveau mot de passe';

  @override
  String get resetConfirmLabel => 'Confirmer le mot de passe';

  @override
  String get resetButton => 'Enregistrer le mot de passe';

  @override
  String get resetErrorLength =>
      'Le mot de passe doit comporter au moins 8 caractères.';

  @override
  String get resetErrorMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get welcomeGetStarted => 'Commencer';

  @override
  String get welcomeSignIn => 'Se connecter';

  @override
  String get roleSelectTitle => 'Comment utiliserez-vous WAWUBasket ?';

  @override
  String get roleSelectSubtitle =>
      'Choisissez ce que vous ferez le plus. Vous pouvez changer de rôle à tout moment depuis votre profil.';

  @override
  String get cartTitle => 'Votre panier';

  @override
  String get cartEmpty => 'Votre panier est vide';

  @override
  String get cartEmptySubtitle =>
      'Vous voulez le remplir ? Nous avons des idées.';

  @override
  String get cartStartShopping => 'Commencer à magasiner';

  @override
  String get cartEta => 'Arrive dans 25–35 min';

  @override
  String get cartPromo => 'Code promo';

  @override
  String get cartPromoApply => 'Appliquer';

  @override
  String get cartSubtotal => 'Sous-total';

  @override
  String get cartDeliveryFee => 'Frais de livraison';

  @override
  String get cartServiceFee => 'Frais de service';

  @override
  String get cartTotal => 'Total';

  @override
  String get cartCheckout => 'Passer à la caisse';

  @override
  String get checkoutTitle => 'Caisse';

  @override
  String get checkoutDeliverySection => 'Où envoyons-nous cela ?';

  @override
  String get checkoutNoAddress => 'Aucune adresse enregistrée — en ajouter une';

  @override
  String get checkoutChangeAddress => 'Modifier';

  @override
  String get checkoutTimingSection => 'Quand le voulez-vous ?';

  @override
  String get checkoutNow => 'Commander maintenant';

  @override
  String get checkoutNowSubtitle => 'Arrive dans 25–35 min';

  @override
  String get checkoutSchedule => 'Planifier';

  @override
  String get checkoutPaymentSection => 'Comment allez-vous payer ?';

  @override
  String get checkoutBasketSection => 'Votre panier';

  @override
  String get checkoutPlaceOrder => 'Passer la commande';

  @override
  String get checkoutWaiting => 'En attente du paiement…';

  @override
  String get checkoutWaitingBody =>
      'Effectuez le paiement dans le navigateur. Nous vous amènerons automatiquement au suivi de commande.';

  @override
  String get checkoutTimeout => 'Paiement non confirmé';

  @override
  String get checkoutTimeoutBody =>
      'Nous n\'avons pas reçu de confirmation de paiement. Appuyez ci-dessous pour vérifier à nouveau, ou revenez en arrière.';

  @override
  String get checkoutCheckStatus => 'Vérifier le statut du paiement';

  @override
  String get checkoutGoBack => 'Retour';

  @override
  String get checkoutScheduleConfirm => 'Confirmer le créneau horaire';

  @override
  String get confirmTitle => 'Super !';

  @override
  String get confirmSubtitle =>
      'Votre commande est confirmée et la cuisine s\'en occupe.';

  @override
  String get confirmNotification =>
      'Nous vous avertirons quand votre panier bougera.';

  @override
  String get confirmTracking =>
      'Regardez-le voyager jusqu\'à votre porte en temps réel.';

  @override
  String get confirmTrackButton => 'Suivre ma commande';

  @override
  String get confirmBackHome => 'Retour à l\'accueil';

  @override
  String get trackingNeedHelp => 'Besoin d\'aide ?';

  @override
  String get trackingDelivered => 'Livré. Profitez de votre panier !';

  @override
  String get trackingDefaultMessage =>
      'Nous vous tiendrons informé au fur et à mesure que votre commande avance.';

  @override
  String get trackingJourney => 'Votre commande est en voyage';

  @override
  String get trackingStep1 => 'Commande confirmée';

  @override
  String get trackingStep2 => 'En préparation';

  @override
  String get trackingStep3 => 'Récupéré';

  @override
  String get trackingStep4 => 'En route';

  @override
  String get trackingStep5 => 'Livré';

  @override
  String get trackingRate => 'Évaluer votre commande';

  @override
  String get deliveryTitle => 'Livré. Profitez de votre panier !';

  @override
  String get deliverySubtitle =>
      'Comment était votre expérience ? Vos retours aident les vendeurs et les livreurs à faire mieux.';

  @override
  String get deliveryRateTitle => 'Évaluer cette commande';

  @override
  String get deliveryRatingBad => 'Pas terrible';

  @override
  String get deliveryRatingFair => 'Peut mieux faire';

  @override
  String get deliveryRatingOkay => 'C\'était correct';

  @override
  String get deliveryRatingGood => 'Plutôt bien !';

  @override
  String get deliveryRatingLove => 'J\'ai adoré !';

  @override
  String get deliveryFeedbackTitle => 'Dites-nous en plus (facultatif)';

  @override
  String get deliveryFeedbackPlaceholder =>
      'Qu\'est-ce qui l\'a rendu super ou pas si super ?';

  @override
  String get deliverySubmit => 'Soumettre l\'évaluation';

  @override
  String get deliverySkip => 'Passer pour l\'instant';

  @override
  String get deliveryThankYou => 'Merci pour votre retour !';

  @override
  String get deliveryThankYouBody =>
      'Votre évaluation aide tout le panier à s\'améliorer. À la prochaine.';

  @override
  String get deliveryBackHome => 'Retour à l\'accueil';

  @override
  String get deliveryRateError =>
      'Appuyez sur une étoile pour évaluer votre commande.';

  @override
  String get searchPlaceholder => 'Rechercher jollof, tomates, poulet…';

  @override
  String get searchRecentTitle => 'Recherches récentes';

  @override
  String get searchRecentClear => 'Effacer';

  @override
  String get searchRecentCleared => 'Recherches récentes effacées';

  @override
  String get productAddButton => 'Ajouter au panier';

  @override
  String get productNotFound => 'Produit introuvable.';

  @override
  String get homeSearchPlaceholder =>
      'Rechercher jollof, tomates, poulet, casseroles…';

  @override
  String get homeBulkMarketsTitle => 'Marchés en gros';

  @override
  String get homeBulkMarketsSubtitle =>
      'Lots en gros et prix de corridor, directement des fermes';

  @override
  String get homeOffersThisWeek => 'CETTE SEMAINE';

  @override
  String get homeOfferTitle =>
      'Livraison gratuite pour les commandes de plus de ₦5 000';

  @override
  String get homeOfferSubtitle => 'Jusqu\'à dimanche. Aucun code nécessaire.';

  @override
  String get homeOfferButton => 'Commander maintenant';

  @override
  String get homeAddAddress => 'Ajouter une adresse de livraison';

  @override
  String homeDeliveringTo(String address) {
    return 'Livraison à $address';
  }

  @override
  String get aboutTitle => 'À propos de WAWUBasket';

  @override
  String get aboutTagline => 'Nous sommes WAWUBasket — fils de WAWAfrica.';

  @override
  String get aboutSendFeedback => 'Envoyer des commentaires';

  @override
  String get aboutSendFeedbackSub => 'Aidez-nous à nous améliorer';

  @override
  String get aboutTerms => 'Conditions d\'utilisation';

  @override
  String get aboutTermsSub => 'Les règles du panier';

  @override
  String get aboutPrivacy => 'Politique de confidentialité';

  @override
  String get aboutPrivacySub => 'Comment nous gérons vos informations';

  @override
  String get aboutHowItWorks => 'Trois étapes pour un panier plein';

  @override
  String get aboutSellOn => 'Vendez sur WAWUBasket';

  @override
  String get aboutStep1Title => 'Parcourir';

  @override
  String get aboutStep1Body =>
      'Choisissez ce que vous voulez parmi les restaurants, les produits, le bétail ou les essentiels.';

  @override
  String get aboutStep2Title => 'Caisse';

  @override
  String get aboutStep2Body =>
      'Choisissez quand vous le voulez et comment vous paierez.';

  @override
  String get aboutStep3Title => 'Suivre';

  @override
  String get aboutStep3Body =>
      'Regardez votre panier prendre vie, puis profitez.';

  @override
  String get aboutVendorStep1Title => 'S\'inscrire';

  @override
  String get aboutVendorStep1Body =>
      'Parlez-nous de votre entreprise. Ayons quelques documents triés.';

  @override
  String get aboutVendorStep2Title => 'Lister vos produits';

  @override
  String get aboutVendorStep2Body =>
      'Ajoutez des photos, des prix et des descriptions.';

  @override
  String get aboutVendorStep3Title => 'Commencer à vendre';

  @override
  String get aboutVendorStep3Body =>
      'Recevez des commandes, préparez des repas et développez-vous.';

  @override
  String get addAddressTitle => 'Ajouter une adresse';

  @override
  String get addAddressEditTitle => 'Modifier l\'adresse';

  @override
  String get addAddressLabelSection => 'ÉTIQUETTE';

  @override
  String get addAddressLabelHome => 'Maison';

  @override
  String get addAddressLabelOffice => 'Bureau';

  @override
  String get addAddressLabelOther => 'Autre';

  @override
  String get addAddressLine => 'Ligne d\'adresse';

  @override
  String get addAddressLinePlaceholder => 'Rue, quartier, ville';

  @override
  String get addAddressApartment => 'Appartement / unité';

  @override
  String get addAddressApartmentPlaceholder => 'Facultatif';

  @override
  String get addAddressNote => 'Note pour le livreur';

  @override
  String get addAddressNotePlaceholder =>
      'Utilisez le portail sur Akin Adesola';

  @override
  String get addAddressDefault => 'Définir comme adresse par défaut';

  @override
  String get addAddressSave => 'Enregistrer l\'adresse';

  @override
  String get addAddressSaveChanges => 'Enregistrer les modifications';

  @override
  String get addAddressUpdated => 'Adresse mise à jour';

  @override
  String get addAddressSaved => 'Adresse enregistrée';

  @override
  String get addAddressEnterLine => 'Entrez la ligne d\'adresse.';

  @override
  String get chatTitle => 'Discussions';

  @override
  String get chatSubtitle =>
      'Discutez avec le support et toute personne sur vos commandes actives.';

  @override
  String get chatMessageHint => 'Message';

  @override
  String get chatLiveChat => 'Chat en direct';

  @override
  String get chatRepliesIn => 'Réponses généralement en moins de 2 min';

  @override
  String get deleteAccountTitle => 'Vous nous quittez ?';

  @override
  String get deleteAccountSubtitle =>
      'Nous sommes tristes de vous voir partir. Avant de partir :';

  @override
  String get deleteAccountCheck1 =>
      'Utilisez votre solde de portefeuille, il sera perdu';

  @override
  String get deleteAccountCheck2 => 'Complétez toutes les commandes actives';

  @override
  String get deleteAccountCheck3 =>
      'Téléchargez vos reçus, vous n\'y aurez plus accès après';

  @override
  String get deleteAccountWhyLeaving => 'Pourquoi partez-vous ? (facultatif)';

  @override
  String get deleteAccountReasonExpensive => 'Trop cher';

  @override
  String get deleteAccountReasonSlow => 'Livraison trop lente';

  @override
  String get deleteAccountReasonOptions => 'Pas assez d\'options';

  @override
  String get deleteAccountReasonTech => 'Problèmes techniques';

  @override
  String get deleteAccountReasonOther => 'Autre';

  @override
  String get deleteAccountConfirmTitle =>
      'Supprimer votre compte définitivement ?';

  @override
  String get deleteAccountConfirmBody => 'Cette action est irréversible.';

  @override
  String get deleteAccountYes => 'Oui, supprimer mon compte';

  @override
  String get deleteAccountNo => 'Non, je veux rester';

  @override
  String get dietaryTitle => 'Préférences alimentaires';

  @override
  String get dietarySubtitle =>
      'Les choses que vous préféreriez ne pas manger.';

  @override
  String get dietaryNoBeef => 'Pas de bœuf';

  @override
  String get dietaryNoPork => 'Pas de porc';

  @override
  String get dietaryNoShellfish => 'Pas de crustacés';

  @override
  String get dietaryHalal => 'Halal uniquement';

  @override
  String get dietaryVegetarian => 'Végétarien';

  @override
  String get dietaryVegan => 'Végétalien';

  @override
  String get dietaryNoDairy => 'Pas de produits laitiers';

  @override
  String get dietaryNoNuts => 'Pas de noix';

  @override
  String get dietaryLowSugar => 'Faible en sucre';

  @override
  String get dietaryAnythingElse => 'Autre chose ?';

  @override
  String get dietaryCustomPlaceholder =>
      'ex. pas de MSG, pas d\'huile de palme';

  @override
  String get dietarySave => 'Enregistrer les préférences';

  @override
  String get dietarySaved => 'Préférences alimentaires enregistrées';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get favoritesVendorsTab => 'Vendeurs';

  @override
  String get favoritesDishesTab => 'Plats';

  @override
  String get favoritesNoVendors =>
      'Pas encore de vendeurs favoris. Appuyez sur le cœur sur un commerce.';

  @override
  String get favoritesNoDishes =>
      'Pas encore de plats favoris. Appuyez sur le cœur sur un plat.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Tout marquer comme lu';

  @override
  String get notificationsAllRead =>
      'Toutes les notifications marquées comme lues';

  @override
  String get notificationsEmpty =>
      'Vous êtes à jour — aucune notification pour l\'instant.';

  @override
  String get orderHistoryTitle => 'Vos paniers passés';

  @override
  String get orderHistoryTabAll => 'Tous';

  @override
  String get orderHistoryTabActive => 'Actif';

  @override
  String get orderHistoryTabPast => 'Passé';

  @override
  String get orderHistoryEmpty =>
      'Pas encore de commandes. Il est temps de changer ça.';

  @override
  String get orderHistoryTrack => 'Suivre la commande';

  @override
  String get orderHistoryReceipt => 'Reçu';

  @override
  String get orderHistoryReorder => 'Commander à nouveau';

  @override
  String get orderHistoryReordered => 'Articles ajoutés à votre panier';

  @override
  String get personalInfoTitle => 'Informations personnelles';

  @override
  String get personalInfoTapPhoto => 'Appuyer pour changer la photo';

  @override
  String get personalInfoFullName => 'Nom complet';

  @override
  String get personalInfoEmail => 'E-mail';

  @override
  String get personalInfoPhone => 'Numéro de téléphone';

  @override
  String get personalInfoDob => 'Date de naissance';

  @override
  String get personalInfoSave => 'Enregistrer les modifications';

  @override
  String get personalInfoSaved => 'Modifications enregistrées';

  @override
  String get personalInfoNameRequired => 'Entrez votre nom complet.';

  @override
  String get personalInfoPhotoUpdated => 'Photo mise à jour';

  @override
  String get personalInfoPhotoFailed => 'Impossible de téléverser cette photo.';

  @override
  String get profileWalletMenu => 'Portefeuille et moyens de paiement';

  @override
  String get profileWalletSub => 'Cartes, banque et mobile money';

  @override
  String get profilePersonalInfo => 'Informations personnelles';

  @override
  String get profilePersonalInfoSub => 'Nom, e-mail, téléphone, vérifié ✓';

  @override
  String get profileSavedAddresses => 'Adresses enregistrées';

  @override
  String get profileSavedAddressesSub => 'Où vous vivez, travaillez et sortez';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileNotificationsSub => 'Ce que nous vous disons';

  @override
  String get profileBulkOrders => 'Commandes en gros';

  @override
  String get profileBulkOrdersSub =>
      'Achats protégés par entiercement depuis /commerce';

  @override
  String get profileWawuPlus => 'Abonnement WAWU+';

  @override
  String get profileWawuPlusSub => 'Livraison réduite et plus encore';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileDietary => 'Préférences alimentaires';

  @override
  String get profileDietarySub =>
      'Les choses que vous préféreriez ne pas manger';

  @override
  String get profileRateApp => 'Noter l\'application';

  @override
  String get profileAbout => 'À propos de WAWUBasket';

  @override
  String get profileChangePassword => 'Changer le mot de passe';

  @override
  String get profileChangePasswordSub => 'Gardez votre compte en sécurité';

  @override
  String get profileBiometricLogin => 'Connexion biométrique';

  @override
  String get profileBiometricLoginSub =>
      'Utilisez votre visage ou votre empreinte';

  @override
  String get profileTwoFactor => 'Authentification à deux facteurs';

  @override
  String get profileTwoFactorSub => 'Couche de protection supplémentaire';

  @override
  String get profileHelpCenter => 'Centre d\'aide';

  @override
  String get profileHelpCenterSub => 'Réponses aux questions courantes';

  @override
  String get profileChatWithUs => 'Discutez avec nous';

  @override
  String get profileChatWithUsSub => 'Nous sommes là pour vous aider';

  @override
  String get profileReportProblem => 'Signaler un problème';

  @override
  String get profileReportProblemSub => 'Dites-nous ce qui s\'est mal passé';

  @override
  String get profileTerms => 'Conditions d\'utilisation';

  @override
  String get profileTermsSub => 'Les règles du panier';

  @override
  String get profilePrivacy => 'Politique de confidentialité';

  @override
  String get profilePrivacySub => 'Comment nous gérons vos informations';

  @override
  String get profileSwitchRole => 'Changer de rôle';

  @override
  String get profileDeleteAccount => 'Supprimer le compte';

  @override
  String get profileDeleteAccountSub =>
      'Nous serons tristes de vous voir partir';

  @override
  String get profileRateWawu => 'Noter WAWUBasket';

  @override
  String get profileRateFeedback =>
      'Comment nous en sortons-nous ? Vos retours façonnent l\'application.';

  @override
  String get profileRateTapStar => 'Appuyer sur une étoile pour noter';

  @override
  String get profileRateSubmit => 'Soumettre';

  @override
  String profileRateThanks(String stars) {
    return 'Merci, vous nous avez donné $stars étoiles';
  }

  @override
  String get profileSignOutTitle => 'Se déconnecter ?';

  @override
  String get profileSignOutBody =>
      'Vous devrez vous reconnecter pour passer de nouvelles commandes.';

  @override
  String get profileSignOut => 'Se déconnecter';

  @override
  String get profileChoosePhoto => 'Choisir une photo de profil';

  @override
  String get receiptTitle => 'Reçu';

  @override
  String get receiptSubtotal => 'Sous-total';

  @override
  String get receiptDelivery => 'Livraison';

  @override
  String get receiptServiceFee => 'Frais de service';

  @override
  String get receiptTotalPaid => 'Total payé';

  @override
  String get receiptReorder => 'Commander à nouveau';

  @override
  String get receiptReportIssue => 'Signaler un problème';

  @override
  String get receiptNotFound => 'Reçu introuvable.';

  @override
  String get savedAddressesTitle => 'Adresses enregistrées';

  @override
  String get savedAddressesAdd => 'Ajouter une adresse';

  @override
  String get savedAddressesEmpty =>
      'Pas encore d\'adresses enregistrées. Ajoutez la première ci-dessus.';

  @override
  String get savedAddressesDefault => 'Par défaut';

  @override
  String get savedAddressesEdit => 'Modifier';

  @override
  String get savedAddressesMakeDefault => 'Définir par défaut';

  @override
  String savedAddressesSetDefault(String label) {
    return '$label défini comme par défaut';
  }

  @override
  String get securityTitle => 'Sécurité';

  @override
  String get securitySubtitle => 'Gardez votre compte en sécurité.';

  @override
  String get securityChangePassword => 'Changer le mot de passe';

  @override
  String get securityChangePasswordSub => 'Gardez votre compte en sécurité';

  @override
  String get securityBiometric => 'Connexion biométrique';

  @override
  String get securityBiometricSub => 'Utilisez votre visage ou votre empreinte';

  @override
  String get securityTwoFactor => 'Authentification à deux facteurs';

  @override
  String get securityTwoFactorSub => 'Couche de protection supplémentaire';

  @override
  String get securityCurrentPassword => 'Mot de passe actuel';

  @override
  String get securityNewPassword => 'Nouveau mot de passe';

  @override
  String get securityConfirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get securityUpdatePassword => 'Mettre à jour le mot de passe';

  @override
  String get securityPasswordMismatch =>
      'Les mots de passe ne correspondent pas.';

  @override
  String get securityPasswordShort =>
      'Le nouveau mot de passe doit comporter au moins 8 caractères.';

  @override
  String get securityPasswordUpdated => 'Mot de passe mis à jour avec succès.';

  @override
  String get supportTitle => 'Aide et assistance';

  @override
  String get supportSearchPlaceholder => 'Rechercher des articles d\'aide';

  @override
  String get supportContactUs => 'NOUS CONTACTER';

  @override
  String get supportLiveChat => 'Chat en direct';

  @override
  String get supportLiveChatSub => 'Répond généralement en moins de 2 min';

  @override
  String get supportLiveChatCta => 'Démarrer le chat';

  @override
  String get supportCall => 'Nous appeler';

  @override
  String get supportCallSub => '+234 800 WAWUBasket';

  @override
  String get supportCallCta => 'Appeler';

  @override
  String get supportEmail => 'Nous envoyer un e-mail';

  @override
  String get supportEmailSub => 'support@wawu.africa';

  @override
  String get supportEmailCta => 'Envoyer un e-mail';

  @override
  String get supportCommonQuestions => 'Questions courantes';

  @override
  String get supportOpenTicket => 'TICKET OUVERT';

  @override
  String get supportViewTicket => 'Voir le ticket';

  @override
  String get walletTitle => 'Portefeuille';

  @override
  String get walletAvailableBalance => 'SOLDE DISPONIBLE';

  @override
  String walletEscrowHeld(String amount) {
    return '$amount en entiercement, libéré à la livraison';
  }

  @override
  String get walletTopUp => 'Recharger';

  @override
  String get walletSend => 'Envoyer';

  @override
  String get walletWithdraw => 'Retirer';

  @override
  String get walletCards => 'Cartes';

  @override
  String get walletRecentTxns => 'Transactions récentes';

  @override
  String get walletNoTxns => 'Pas encore de transactions.';

  @override
  String get walletTopUpTitle => 'Recharger le portefeuille';

  @override
  String get walletSendTitle => 'Envoyer de l\'argent';

  @override
  String get walletWithdrawTitle => 'Retirer';

  @override
  String get walletPaymentMethodsTitle => 'Moyens de paiement';

  @override
  String get walletAmountLabel => 'MONTANT';

  @override
  String get walletEnterAmount => 'Entrez le montant';

  @override
  String get walletPayWith => 'PAYER AVEC';

  @override
  String get walletWithdrawTo => 'RETIRER VERS';

  @override
  String get walletDebitCard => 'Carte de débit';

  @override
  String get walletBankTransfer => 'Virement bancaire';

  @override
  String get walletMobileMoney => 'Mobile money';

  @override
  String get walletEnterAmountHint => 'Entrez un montant';

  @override
  String get walletTopUpHint => 'Recharger';

  @override
  String get walletAddNewMethod => 'Ajouter un nouveau moyen';

  @override
  String get walletMethodRemoved => 'Moyen supprimé';

  @override
  String get wawuPlusTitle => 'WAWU+';

  @override
  String get wawuPlusHero => 'Passez au plus. Obtenez plus.';

  @override
  String get wawuPlusSubtitle =>
      'Livraison réduite. Offres exclusives. Assistance prioritaire.';

  @override
  String get wawuPlusMembers => 'Rejoignez 12 400 autres paniers heureux';

  @override
  String get wawuPlusIncluded => 'Ce qui est inclus';

  @override
  String get wawuPlusBenefit1 => 'Livraison réduite sur chaque commande';

  @override
  String get wawuPlusBenefit2 => 'Offres réservées aux membres chaque semaine';

  @override
  String get wawuPlusBenefit3 =>
      'Assistance prioritaire, passez devant la file';

  @override
  String get wawuPlusBenefit4 => 'Retours gratuits sur les articles incorrects';

  @override
  String get wawuPlusBenefit5 => 'Accès anticipé aux nouvelles fonctionnalités';

  @override
  String get wawuPlusPickPlan => 'Choisir un plan';

  @override
  String get wawuPlusYearly => 'Annuel';

  @override
  String get wawuPlusYearlyNote => 'Économisez 20 % · facturé une fois';

  @override
  String get wawuPlusMonthly => 'Mensuel';

  @override
  String get wawuPlusMonthlyNote => 'Annulez à tout moment';

  @override
  String get wawuPlusStartTrial => 'Démarrer l\'essai gratuit, 7 jours';

  @override
  String get wawuPlusActiveMember => 'Vous êtes membre WAWU+';

  @override
  String get wawuPlusWebOnly =>
      'Ouvrez WAWUBasket sur votre téléphone pour rejoindre WAWU+.';

  @override
  String get wawuPlusWelcome => 'Bienvenue dans WAWU+ !';

  @override
  String get operatorSignOutTitle => 'Se déconnecter ?';

  @override
  String get operatorSignOutBody =>
      'Vous devrez vous reconnecter pour utiliser ce tableau de bord.';

  @override
  String get operatorSignOut => 'Se déconnecter';

  @override
  String get operatorPersonalInfo => 'Informations personnelles';

  @override
  String get operatorPersonalInfoSub => 'Nom, e-mail, téléphone, vérifié ✓';

  @override
  String get operatorSavedAddresses => 'Adresses enregistrées';

  @override
  String get operatorSavedAddressesSub =>
      'Où les livraisons partent et arrivent';

  @override
  String get operatorNotifications => 'Notifications';

  @override
  String get operatorNotificationsSub =>
      'Nouvelles commandes, paiements, alertes';

  @override
  String get operatorLanguage => 'Langue';

  @override
  String get operatorAbout => 'À propos de WAWUBasket';

  @override
  String get operatorHelpSupport => 'Aide et assistance';

  @override
  String get operatorHelpSupportSub => 'Discutez avec un vrai humain';

  @override
  String get operatorSwitchRole => 'Changer de rôle';

  @override
  String get operatorChoosePhoto => 'Choisir une photo de profil';

  @override
  String get vendorAlertsTitle => 'Alertes';

  @override
  String get vendorAlertsEmpty =>
      'Pas d\'alertes en ce moment. Profitez du calme.';

  @override
  String get vendorAnalyticsTitle => 'Comment vous vous en sortez';

  @override
  String get vendorAnalyticsSubtitle => 'Les chiffres ne mentent pas.';

  @override
  String get vendorAnalyticsOrders => 'Commandes';

  @override
  String get vendorAnalyticsRevenue => 'Revenus';

  @override
  String get vendorAnalyticsAvgOrder => 'Commande moy.';

  @override
  String get vendorAnalyticsRating => 'Note';

  @override
  String get vendorAnalyticsSalesTrend => 'Tendance des ventes';

  @override
  String get vendorAnalyticsPeakHours => 'Heures de pointe';

  @override
  String get vendorAnalyticsCancellations => 'Annulations';

  @override
  String get vendorAnalyticsTopSellers => 'Meilleures ventes';

  @override
  String get vendorAnalyticsExport => 'Exporter';

  @override
  String get vendorAnalyticsNoSales =>
      'Pas de ventes dans cette période encore.';

  @override
  String get vendorAnalyticsLast7 => '7 derniers jours';

  @override
  String get vendorAnalyticsLast30 => '30 derniers jours';

  @override
  String get vendorAnalyticsLast90 => '90 derniers jours';

  @override
  String get vendorHomeGoodMorning => 'Bonjour,';

  @override
  String get vendorHomeOpen => 'Ouvert';

  @override
  String get vendorHomeClosed => 'Fermé';

  @override
  String get vendorHomeQuickActions => 'Actions rapides';

  @override
  String get vendorHomeAddItem => 'Ajouter un article';

  @override
  String get vendorHomeAnalytics => 'Analytique';

  @override
  String get vendorHomePayouts => 'Paiements';

  @override
  String get vendorHomeFreshOrders => 'Nouvelles commandes';

  @override
  String get vendorHomeInKitchen => 'En cuisine';

  @override
  String get vendorHomeMore => 'Plus';

  @override
  String get vendorHomeInventory => 'Inventaire';

  @override
  String get vendorHomeInventorySub => 'Niveaux de stock et lots';

  @override
  String get vendorHomeReviews => 'Avis';

  @override
  String get vendorHomeReviewsSub => 'Ce que disent les clients';

  @override
  String get vendorHomeAlerts => 'Alertes';

  @override
  String get vendorHomeAlertsSub =>
      'Stock faible, commandes tardives, réponses en attente';

  @override
  String get vendorHomeSettings => 'Paramètres du magasin';

  @override
  String get vendorHomeSettingsSub =>
      'Horaires, temps de préparation, mode vacances, personnel';

  @override
  String get vendorHomeDecline => 'Refuser';

  @override
  String get vendorHomeAccept => 'Accepter';

  @override
  String get vendorHomeNoOrders =>
      'Pas de nouvelles commandes. Lancez une promo pour les attirer.';

  @override
  String get vendorInventoryTitle => 'Qu\'est-ce qui est en stock ?';

  @override
  String get vendorKycReviewNote =>
      'Nous examinerons vos documents et vous mettrons en ligne.';

  @override
  String get vendorOrderNotFound => 'Commande introuvable';

  @override
  String get vendorReviewsTitle => 'Ce qu\'ils disent';

  @override
  String get vendorMenuPhotoFailed => 'Impossible de téléverser cette photo.';

  @override
  String get agentHomeOnline =>
      'Vous êtes en ligne, les transactions se synchronisent au fur et à mesure que vous les enregistrez.';

  @override
  String get agentRegisterSetUp => 'Mettons-les en place.';

  @override
  String get agentRegisterOffline =>
      'Compatible hors ligne, nous synchroniserons lorsque vous aurez une connexion.';

  @override
  String get agentTraderNotFound => 'Commerçant introuvable';

  @override
  String get agentTradersEmpty =>
      'Pas encore de commerçants enregistrés. Appuyez sur \"Enregistrer\" pour en ajouter un.';

  @override
  String get riderHomeOffline => 'Vous êtes hors ligne';

  @override
  String get riderKycPhotoId => 'Photo de la pièce d\'identité';

  @override
  String get driverKycVerifyNote =>
      'Nous vérifions avec votre syndicat de transport avant que vous enchérissiez.';

  @override
  String get driverKycLicenceName =>
      'Nom sur le permis de conduire, s\'il vous plaît.';

  @override
  String get driverKycVehicleType =>
      'Ce avec quoi vous transporterez les charges.';

  @override
  String get traderListingsEmpty =>
      'Pas encore d\'annonces. Appuyez sur \"Publier\" pour ajouter la première.';

  @override
  String get traderListingPhotoFailed =>
      'Impossible de téléverser cette photo.';

  @override
  String get exportListingNotFound => 'Impossible de trouver cette annonce';

  @override
  String get exportEnquirySent =>
      'Demande envoyée, le commerçant vous contactera.';

  @override
  String get bulkCheckoutListingNotFound => 'Annonce introuvable';

  @override
  String get bulkCheckoutEscrowNote =>
      'Nous retenons vos fonds jusqu\'à ce que vous confirmiez la livraison. Contestez à tout moment si quelque chose ne va pas.';

  @override
  String get escrowDisputeOpened =>
      'Litige ouvert. Nous examinerons dans les 48 heures.';

  @override
  String get escrowDisputeOrderNotFound => 'Commande introuvable';

  @override
  String get escrowDisputeDetailsHint =>
      'Dites-nous les détails, ce qui est arrivé par rapport à ce que vous attendiez ?';

  @override
  String get escrowOrdersEmpty =>
      'Vous n\'avez pas encore passé de commandes en gros. Rendez-vous sur Commerce pour commencer.';

  @override
  String get escrowStatusNotFound => 'Impossible de trouver cette commande';

  @override
  String get escrowStatusReviewNote =>
      'Nous examinerons les preuves et résoudrons dans les 48 heures.';
}
