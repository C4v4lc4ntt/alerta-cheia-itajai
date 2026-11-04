// =============================================================================
// notificador_servico_local_test.dart — RF02 (D14 e D15): a notificação real,
// com o pacote flutter_local_notifications.
//
// Escrito ANTES do código (etapa vermelha do TDD). O plugin é mock porque é
// uma borda do app; se a notificação aparece no celular é conferido no passo
// 49.
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/notificador_servico.dart';
import 'package:alerta_cheia_itajai/data/servicos/notificador_servico_local.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _PluginMock extends Mock implements FlutterLocalNotificationsPlugin {}

void main() {
  late _PluginMock plugin;
  late NotificadorServicoLocal notificador;

  setUpAll(() {
    // O mocktail precisa de um exemplo de cada tipo próprio usado em any().
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(const NotificationDetails());
  });

  setUp(() {
    plugin = _PluginMock();
    notificador = NotificadorServicoLocal(plugin: plugin);
    when(
      () => plugin.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: any(named: 'notificationDetails'),
      ),
    ).thenAnswer((_) async {});
    when(() => plugin.initialize(settings: any(named: 'settings')))
        .thenAnswer((_) async => true);
  });

  Future<void> avisar(String bairro) {
    final NotificadorServico servico = notificador;
    return servico.notificarMudanca(
      bairro: bairro,
      anterior: EstagioAlerta.monitoramento,
      atual: EstagioAlerta.atencao,
    );
  }

  // Os ids de todas as chamadas de show.
  List<Object?> capturarId() => verify(
    () => plugin.show(
      id: captureAny(named: 'id'),
      title: any(named: 'title'),
      body: any(named: 'body'),
      notificationDetails: any(named: 'notificationDetails'),
    ),
  ).captured;

  NotificationDetails capturarDetalhes() =>
      verify(
            () => plugin.show(
              id: any(named: 'id'),
              title: any(named: 'title'),
              body: any(named: 'body'),
              notificationDetails: captureAny(named: 'notificationDetails'),
            ),
          ).captured.single
          as NotificationDetails;

  group('NotificadorServicoLocal', () {
    test('mostra o título e o corpo aprovados', () async {
      await avisar('Murta');

      final capturados = verify(
        () => plugin.show(
          id: any(named: 'id'),
          title: captureAny(named: 'title'),
          body: captureAny(named: 'body'),
          notificationDetails: any(named: 'notificationDetails'),
        ),
      ).captured;
      expect(capturados, [
        'Murta: estágio mudou para Atenção',
        'De Monitoramento para Atenção, pelo estágio mais grave entre as '
            'estações. Não é alerta oficial. Emergência: 199, 193 ou 192.',
      ]);
    });

    // D15: cada bairro tem o próprio aviso na barra do celular.
    test('bairros diferentes → ids diferentes', () async {
      await avisar('Murta');
      await avisar('Centro');

      final ids = capturarId();
      expect(ids[0], isNot(ids[1]));
    });

    // Um aviso novo do mesmo bairro substitui o antigo, sem acumular.
    test('mesmo bairro → mesmo id', () async {
      await avisar('Murta');
      await avisar('Murta');

      final ids = capturarId();
      expect(ids[0], ids[1]);
    });

    test('usa o canal de mudança de estágio, com prioridade alta', () async {
      await avisar('Murta');

      final android = capturarDetalhes().android!;
      expect(android.channelId, 'mudanca_estagio');
      expect(android.channelName, 'Mudança de estágio');
      expect(android.importance, Importance.high);
      expect(android.priority, Priority.high);
    });

    // O texto é longo: sem este estilo, o Android corta o corpo.
    test('mostra o corpo inteiro ao abrir a notificação', () async {
      await avisar('Murta');

      final estilo = capturarDetalhes().android!.styleInformation;
      expect(estilo, isA<BigTextStyleInformation>());
    });

    test('iniciar usa o ícone do app e não pede permissão', () async {
      await notificador.iniciar();

      final ajustes =
          verify(
                () =>
                    plugin.initialize(settings: captureAny(named: 'settings')),
              ).captured.single
              as InitializationSettings;
      expect(ajustes.android!.defaultIcon, '@mipmap/ic_launcher');
      expect(ajustes.iOS!.requestAlertPermission, isFalse);
      expect(ajustes.iOS!.requestBadgePermission, isFalse);
      expect(ajustes.iOS!.requestSoundPermission, isFalse);
    });
  });
}
