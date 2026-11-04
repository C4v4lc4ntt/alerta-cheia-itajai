// =============================================================================
// notificador_servico_local.dart — notificação real do RF02, com o pacote
// flutter_local_notifications (D14 e D15).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/models/estagio_alerta.dart';
import '../../domain/regras/texto_notificacao.dart';
import 'notificador_servico.dart';

/// Implementação real de [NotificadorServico].
class NotificadorServicoLocal implements NotificadorServico {
  /// Cria o notificador com o [plugin] injetado.
  NotificadorServicoLocal({required this.plugin});

  /// Plugin que fala com o sistema do celular.
  final FlutterLocalNotificationsPlugin plugin;

  /// Prepara o plugin. A permissão é pedida depois, ao escolher um bairro.
  Future<void> iniciar() async {
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<void> notificarMudanca({
    required String bairro,
    required EstagioAlerta anterior,
    required EstagioAlerta atual,
  }) {
    final texto = textoDaNotificacao(
      bairro: bairro,
      anterior: anterior,
      atual: atual,
    );
    return plugin.show(
      id: _idDoBairro(bairro),
      title: texto.titulo,
      body: texto.corpo,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'mudanca_estagio',
          'Mudança de estágio',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(texto.corpo),
        ),
      ),
    );
  }

  // Número calculado pelo nome, igual em toda execução e sempre positivo.
  // String.hashCode não serve: o Dart não promete o mesmo valor entre execuções.
  static int _idDoBairro(String bairro) {
    return bairro.codeUnits.fold(
      0,
      (soma, letra) => (soma * 31 + letra) & 0x7fffffff,
    );
  }
}
