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
  String get navSearch => 'Recherche';

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
  String get actionSeeAll => 'Voir tout';

  @override
  String get commonLoading => 'Chargement…';

  @override
  String get commonError => 'Une erreur s\'est produite.';

  @override
  String get commonEmpty => 'Rien ici pour l\'instant.';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSubtitle => 'Choisissez la langue de WAWUBasket.';

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
      'Aucune conversation de commande. Elles apparaîtront ici dès que vous aurez une commande active.';

  @override
  String get chatSupportPrompt => 'Des questions ? Discutez avec notre équipe.';

  @override
  String get chatAttachmentFailed => 'Impossible d\'envoyer la pièce jointe.';

  @override
  String get kycSubmitted =>
      'Demande envoyée. Nous l\'examinerons et vous tiendrons informé.';

  @override
  String get kycUploadFailed =>
      'Impossible de téléverser le document. Réessayez.';
}
