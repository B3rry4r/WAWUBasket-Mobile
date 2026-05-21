// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'WAWUBasket';

  @override
  String get navHome => 'Início';

  @override
  String get navTrade => 'Comércio';

  @override
  String get navOrders => 'Pedidos';

  @override
  String get navAccount => 'Conta';

  @override
  String get navSearch => 'Pesquisar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDone => 'Concluído';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionNext => 'Seguinte';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionSeeAll => 'Ver tudo';

  @override
  String get commonLoading => 'A carregar…';

  @override
  String get commonError => 'Algo correu mal.';

  @override
  String get commonEmpty => 'Ainda não há nada aqui.';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSubtitle => 'Escolha como o WAWUBasket fala consigo.';

  @override
  String get signIn => 'Entrar';

  @override
  String get signUp => 'Criar conta';

  @override
  String get logOut => 'Terminar sessão';

  @override
  String get chatEmpty => 'Ainda não há mensagens. Envie a primeira abaixo.';

  @override
  String get chatInboxEmpty =>
      'Ainda não há conversas de pedidos. Aparecem aqui quando tiver um pedido ativo.';

  @override
  String get chatSupportPrompt => 'Dúvidas? Fale com a nossa equipa.';

  @override
  String get chatAttachmentFailed => 'Não foi possível enviar o anexo.';

  @override
  String get kycSubmitted => 'Pedido enviado. Vamos analisá-lo e avisá-lo.';

  @override
  String get kycUploadFailed =>
      'Não foi possível carregar o documento. Tente novamente.';
}
